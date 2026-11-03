import 'package:bfban/provider/captcha_provider.dart';
import 'package:bfban/provider/chat_provider.dart';
import 'package:bfban/provider/dir_provider.dart';
import 'package:bfban/provider/log_provider.dart';
import 'package:bfban/provider/package_provider.dart';
import 'package:bfban/provider/theme_provider.dart';
import 'package:bfban/provider/translation_provider.dart';
import 'package:bfban/provider/userinfo_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter_i18n/flutter_i18n_delegate.dart';
import 'package:bfban/component/_lang/delegate_custom.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';

import 'package:bfban/router/router.dart';
import 'package:bfban/constants/api.dart';
import 'package:bfban/utils/index.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.prod.dart' as prod;

const String appGroupId = 'com.cabbagelol.bfban';

void main() => prod.main();

// 入口
void runMain() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  SharedPreferences.setPrefix('APP.');

  // 路由初始
  Routes.configureRoutes(FluroRouter());

  // 设置系统
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const BfBanApp());

  FlutterNativeSplash.remove();
}

class BfBanApp extends StatefulWidget {
  const BfBanApp({super.key});

  @override
  AppState createState() => AppState();
}

class AppState extends State<BfBanApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppInfoProvider()),
        ChangeNotifierProvider(create: (context) => UserInfoProvider()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
        ChangeNotifierProvider(create: (context) => PackageProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => TranslationProvider()),
        ChangeNotifierProvider(create: (context) => PublicApiTranslationProvider()),
        ChangeNotifierProvider(create: (context) => CaptchaProvider()),
        ChangeNotifierProvider(create: (context) => DirProvider()),
        ChangeNotifierProvider(create: (context) => LogProvider()),
      ],
      child: Consumer3<ThemeProvider, TranslationProvider, AppInfoProvider>(builder: (BuildContext context, ThemeProvider themeData, TranslationProvider langData, AppInfoProvider appData, Widget? child) {
        return MaterialApp(
          debugShowCheckedModeBanner: Config.env == Env.DEV,
          theme: themeData.currentThemeData,
          themeAnimationDuration: Duration.zero,
          initialRoute: '/splash',
          supportedLocales: const [
            Locale('zh', 'CN'),
            Locale('zh', 'TW'),
            Locale('zh'),
            Locale('en', 'US'),
            Locale('en'),
            Locale('ja', 'JP'),
            Locale('ja'),
            Locale('ru', 'RU'),
            Locale('ru'),
            Locale('de', 'DE'),
            Locale('fr', 'FR'),
            Locale('tr', 'TR'),
            Locale('it', 'IT'),
            Locale('es', 'ES'),
          ],
          localeResolutionCallback: (Locale? locale, Iterable<Locale> supportedLocales) {
            if (locale == null) return const Locale('zh', 'CN');
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale.languageCode && supportedLocale.countryCode == locale.countryCode) {
                return supportedLocale;
              }
            }
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale.languageCode) {
                return supportedLocale;
              }
            }
            return const Locale('zh', 'CN');
          },
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            const FallbackCupertinoLocalizationsDelegate(),
            FlutterI18nDelegate(
              translationLoader: AppTranslationLoader(
                namespaces: ["app"],
                basePath: "assets/lang",
                baseUri: Uri.https(Config.apiHost["web_site"]?.host ?? "bfban.gametools.network", "lang"),
                useCountryCode: false,
                fallback: langData.defaultLang,
                forcedLocale: Locale(langData.currentLang.isEmpty ? langData.defaultLang : langData.currentLang),
              ),
            )
          ],
          builder: (BuildContext context, Widget? widget) {
            ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
              return WidgetError(errorDetails: errorDetails);
            };

            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(themeData.theme.textScaleFactor as double)),
              child: widget!,
            );
          },
          onGenerateRoute: Routes.router.generator,
        );
      }),
    );
  }
}

class WidgetError extends StatelessWidget {
  final FlutterErrorDetails? errorDetails;

  const WidgetError({
    super.key,
    required this.errorDetails,
  }) : assert(errorDetails != null);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.error,
      margin: EdgeInsets.zero,
      child: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Icon(Icons.error),
      ),
    );
  }
}

/**
 * Cupertino 本地化备用委托
 * 当特定地区语言缺少 Cupertino 官方翻译实现时提供默认后备，防止抛出未支持异常
 */
class FallbackCupertinoLocalizationsDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) => DefaultCupertinoLocalizations.load(locale);

  @override
  bool shouldReload(FallbackCupertinoLocalizationsDelegate old) => false;
}

