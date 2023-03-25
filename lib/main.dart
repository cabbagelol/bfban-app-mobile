/// 程序入口

import 'dart:async';

import 'package:bfban/provider/lang_provider.dart';
import 'package:bfban/provider/message_provider.dart';
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
import 'package:sentry/sentry.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';

import 'package:bfban/router/router.dart';
import 'package:bfban/constants/api.dart';
import 'package:bfban/utils/index.dart';

import 'component/_lang/delegate_custom.dart';

// 入口
void runMain() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 路由初始
  Routes.configureRoutes(FluroRouter());

  // 相机初始
  Camera.camera = await availableCameras();

  // 设置系统状态栏
  SystemUiOverlayStyle systemUiOverlayStyle = const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.light,
  );
  SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);

  runZonedGuarded(
    () async {
      await Sentry.init(
        (options) {
          options.dsn = Config.apiHost["sentry"];
        },
      );

      runApp(const BfBanApp());
    },
    (exception, stackTrace) async {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
    },
  );
}

class BfBanApp extends StatefulWidget {
  const BfBanApp({Key? key}) : super(key: key);

  @override
  _BfBanAppState createState() => _BfBanAppState();
}

class _BfBanAppState extends State<BfBanApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppInfoProvider()),
        ChangeNotifierProvider(create: (context) => UserInfoProvider()),
        ChangeNotifierProvider(create: (context) => MessageProvider()),
        ChangeNotifierProvider(create: (context) => PackageProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => TranslationProvider()),
        ChangeNotifierProvider(create: (context) => LangProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (BuildContext? themeContext, themeData, Widget? child) {
          return Consumer<LangProvider>(
            builder: (BuildContext? context, langData, Widget? child) {
              return MaterialApp(
                theme: themeData.currentThemeData,
                darkTheme: themeData.list!["default"]!.themeData!,
                initialRoute: '/splash',
                localizationsDelegates: [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  FlutterI18nDelegate(
                    translationLoader: CustomTranslationLoader(
                      namespaces: ["app"],
                      basePath: "assets/lang",
                      baseUri: Uri.https(Config.apiHost["web_site"].toString().replaceAll("https://", ""), "lang"),
                      useCountryCode: false,
                      fallback: "zh_CN",
                      forcedLocale: Locale(langData.currentLang.isEmpty ? "zh_CN" : langData.currentLang),
                    ),
                  )
                ],
                builder: (BuildContext context, Widget? widget) {
                  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
                    return CustomError(errorDetails: errorDetails);
                  };
                  return widget!;
                },
                onGenerateRoute: Routes.router!.generator,
              );
            },
          );
        },
      ),
    );
  }
}

class CustomError extends StatelessWidget {
  final FlutterErrorDetails? errorDetails;

  const CustomError({
    Key? key,
    required this.errorDetails,
  })  : assert(errorDetails != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          errorDetails!.library.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
