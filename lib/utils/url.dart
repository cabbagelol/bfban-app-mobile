import 'dart:async';
import 'package:flutter/cupertino.dart';

import 'package:fluro/fluro.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:bfban/router/router.dart';

class UrlUtil {
  /// 唤起内置游览器，并访问
  Future<void> onPeUrl(String url) async {
    try {
      if (url.length < 0) {
        return {
          "code": -2,
        };
      }

      if (await canLaunch(url)) {
        await launch(
          url,
          forceSafariVC: false,
          forceWebView: false,
          headers: <String, String>{'my_header_key': 'my_header_value'},
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

  /// 唤起内部webview，访问地址
  Future<void> opEnWebView(String url) async {
    try {
      if (await canLaunch(url)) {
        await launch(
          url,
          forceSafariVC: true,
          forceWebView: true,
          headers: <String, String>{'webview_type': 'bfban'},
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
  Future opEnPage(BuildContext context, String url) async {
    Future<dynamic> res = await Routes.router.navigateTo(
      context,
      url,
      transition: TransitionType.cupertino,
    );

    return res;
  }
}