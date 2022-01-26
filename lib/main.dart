/// 程序入口

import 'dart:async';

import 'package:bfban/provider/message_provider.dart';
import 'package:bfban/provider/package_provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluro/fluro.dart';
import 'package:sentry/sentry.dart';
import 'package:provider/provider.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_i18n/flutter_i18n_delegate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:bfban/provider/userinfo_provider.dart';

import 'package:bfban/router/router.dart';
import 'package:bfban/constants/api.dart';
import 'package:bfban/pages/index/index.dart';
import 'package:bfban/utils/index.dart';

// 入口
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 路由初始
  Routes.configureRoutes(FluroRouter());

  // 应用版本模式
  Config.env = Env.PROD;

  // 相机初始
  Camera.camera = await availableCameras();

  // 设置系统演示
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
      ],
      child: Consumer<AppInfoProvider>(
        builder: (BuildContext? context, appInfo, Widget? child) {
          return MaterialApp(
            theme: appInfo.currentThemeData,
            initialRoute: '/',
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            onGenerateRoute: Routes.router!.generator,
            routes: {
              '/': (context) => child!,
            },
            debugShowCheckedModeBanner: true,
          );
        },
        child: const IndexPage(),
      ),
    );
  }
}
