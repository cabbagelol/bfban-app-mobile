import 'dart:async';
import 'package:flutter/cupertino.dart';

import 'package:fluro/fluro.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:bfban/router/router.dart';

class UrlUtil {
  /// 唤起内置游览器，并访问
  void onPeUrl(String url) async {
    if (url.length < 0) {
      return;
    }

    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      print('Could not launch $url');
    }
  }

  /// 唤起内部webview，访问地址
  Future<void> opEnWebView(String url) async {
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
  }

  /// 打开页面
  Future opEnPage(BuildContext context, String url) {
    Routes.router.navigateTo(
      context,
      url,
      transition: TransitionType.cupertino,
    ).then((res) {
      return res;
    });
  }
}