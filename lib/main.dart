import 'dart:async';

import 'package:bfban/provider/captcha_provider.dart';
import 'package:bfban/provider/chat_provider.dart';
import 'package:bfban/provider/dir_provider.dart';
import 'package:bfban/provider/log_provider.dart';
import 'package:bfban/provider/package_provider.dart';
import 'package:bfban/provider/theme_provider.dart';
import 'package:bfban/provider/translation_provider.dart';
import 'package:bfban/provider/userinfo_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter_i18n/flutter_i18n_delegate.dart';
import 'package:bfban/component/_lang/delegate_custom.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:sentry/sentry.dart';
import 'package:provider/provider.dart';

import 'package:bfban/router/router.dart';
import 'package:bfban/constants/api.dart';
import 'package:bfban/utils/index.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String appGroupId = 'com.cabbagelol.bfban';

// 入口
void runMain() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  SharedPreferences.setPrefix('APP.');

  // 路由初始
  Routes.configureRoutes(FluroRouter());

  // 设置系统状态栏
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

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
            Locale('zh', 'CH'),
            Locale('en', 'US'),
          ],
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            FlutterI18nDelegate(
              translationLoader: AppTranslationLoader(
                namespaces: ["app"],
                basePath: "assets/lang",
                baseUri: Uri.https(Config.apiHost["web_site"]!.host as String, "lang"),
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
