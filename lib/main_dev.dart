/**
 * 开发环境容器
 * 载入开发配置
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluro/fluro.dart';

import 'package:bfban/router/router.dart';
import 'package:bfban/constants/config.dart';
import 'package:bfban/constants/api.dart';
import 'package:bfban/main.dart';

void main() async {
  final routers  = new Router();
  Routes.configureRoutes(routers);

  Config.env = Env.PROD;

  var configuredApp = new AppConfig(
    debug: false,
    appName: '优e家 dev',
    flavorName: 'development',
    apiBaseUrl: 'http://192.168.1.5:6081',
    child: new MyApp(),
  );

  // 设置系统演示
  SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light
  );
  SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);

  runApp(
    configuredApp,
  );
}