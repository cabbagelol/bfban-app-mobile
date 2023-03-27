import 'dart:async';
import 'package:flutter/cupertino.dart';

import 'package:fluro/fluro.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:bfban/router/router.dart';

class UrlUtil {
  /// 唤起内置游览器，并访问
  Future<Map> onPeUrl(String url, {LaunchMode mode = LaunchMode.inAppWebView}) async {
    try {
      Uri _url = Uri.parse(url);

      if (url.isEmpty) throw "Url empty";

      if (!await launchUrl(_url, mode: mode)) {
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
      if (await canLaunch(url)) {
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
    } catch (E) {
      return {
        "code": -1,
        "msg": E,
      };
    }
  }

  /// 打开页面
  Future opEnPage(
    BuildContext context,
    String url, {
    TransitionType transition = TransitionType.cupertino,
    clearStack = false,
    rootNavigator = false,
  }) async {
    if (url.isEmpty) return;

    return await Routes.router!.navigateTo(
      context,
      url,
      transition: transition,
      rootNavigator: rootNavigator,
      clearStack: clearStack,
    );
  }

  /// 返回页面
  Future popPage(BuildContext context) async {
    return Routes.router!.pop(context);
  }
}