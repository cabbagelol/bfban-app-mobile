import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';

import 'package:fluro/fluro.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:bfban/router/router.dart';

import '../provider/appBuildContent.dart';

class UrlUtil {
  /// default mode
  LaunchMode get defaultMode {
    switch (Platform.operatingSystem) {
      case "ios":
      case "macos":
        // Circumventing IOS audits, Guideline 4.0
        return LaunchMode.inAppWebView;
      default:
        return LaunchMode.externalApplication;
    }
  }

  /// 唤起内置游览器，并访问
  Future<Map> onPeUrl(
    String url, {
    LaunchMode? mode,
    WebViewConfiguration? webViewConfiguration,
  }) async {
    try {
      Uri uri = Uri.parse(url);
      mode ??= defaultMode;

      if (url.isEmpty) throw "Url empty";

      if (!await launchUrl(uri, mode: mode)) {
        throw 'Could not launch $url';
      }

      return {"code": 0};
    } catch (error) {
      return {"code": -1, "msg": error};
    }
  }

  /// 唤起内部webview，访问地址
  Future<Map> opEnWebView(String url) async {
    try {
      if (await canLaunchUrl(Uri(path: url))) {
        await launch(
          url,
          forceSafariVC: true,
          forceWebView: true,
          headers: <String, String>{
            "webview_type": "bfban",
          },
          statusBarBrightness: Brightness.dark,
          webOnlyWindowName: url.toString(),
        );
      } else {
        throw 'Could not launch $url';
      }

      return {
        "code": 0,
      };
    } catch (err) {
      return {
        "code": -1,
        "msg": err,
      };
    }
  }

  /// 打开页面
  Future opEnPage(
    BuildContext context,
    String url, {
    replace = false,
    TransitionType transition = TransitionType.cupertino,
    clearStack = false,
    rootNavigator = false,
    opaque = false,
  }) async {
    if (url.isEmpty && url == "/" && context == null) return;

    return await Routes.router.navigateTo(
      context,
      url,
      replace: replace,
      transition: transition,
      rootNavigator: rootNavigator,
      clearStack: clearStack,
      opaque: opaque,
    );
  }

  Future opEnPage2(
    String url, {
    TransitionType transition = TransitionType.cupertino,
    clearStack = false,
    rootNavigator = false,
  }) async {
    try {
      if (url.isEmpty) return;

      return await Routes.router.navigateTo(
        AppStatus.context!,
        url,
        transition: transition,
        rootNavigator: rootNavigator,
        clearStack: clearStack,
      );
    } finally {}
  }

  /// 返回页面
  Future popPage(BuildContext context) async {
    return Routes.router!.pop(context);
  }
}
