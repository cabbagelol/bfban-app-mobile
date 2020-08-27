/// 开发环境容器
/// 载入开发配置

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluro/fluro.dart';
import 'package:sentry/sentry.dart';

import 'package:bfban/router/router.dart';
import 'package:bfban/constants/config.dart';
import 'package:bfban/constants/api.dart';
import 'package:bfban/main.dart';

void main() async {
  final SentryClient sentry = new SentryClient(dsn: Config.apiHost["sentry"]);
  final routers = new Router();

  Routes.configureRoutes(routers);

  Config.env = Env.PROD;

  AppConfig configuredApp = new AppConfig(
    debug: false,
    appName: 'BFBAN dev',
    flavorName: 'com.cabbagelol.bfban',
    apiBaseUrl: 'http://192.168.1.5:6081',
    child: new MyApp(),
  );

  /// 设置系统演示
  SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.light,
  );
  SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);

  runZonedGuarded(
    () => runApp(configuredApp),
    (error, stackTrace) async {
      await sentry.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
    },
  );

//  FlutterError.onError = (details, {bool forceReport = false}) async {
//    sentry.captureException(
//      exception: details.exception,
//      stackTrace: details.stack,
//    );
//  };
}
