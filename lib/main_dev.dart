/// 开发环境容器
/// 载入开发配置

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluro/fluro.dart';
import 'package:sentry/sentry.dart';

import 'package:bfban/router/router.dart';
import 'package:bfban/constants/api.dart';
import 'package:bfban/main.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  final SentryClient sentry = new SentryClient(dsn: Config.apiHost["sentry"]);
  final routers = new FluroRouter();

  Routes.configureRoutes(routers);

  Config.env = Env.PROD;

  /// 设置系统演示
  SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.light,
  );
  SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);

  SharedPreferences.setMockInitialValues({
    "name": "bfban"
  });

  runZonedGuarded(
    () => runApp(MyApp()),
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
