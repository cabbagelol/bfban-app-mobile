import 'dart:async';
import 'package:flutter/cupertino.dart';

import 'package:fluro/fluro.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:bfban/router/router.dart';

class UrlUtil {
  /// 回复链接执行
  void onPeUrl(String url) async {
    if (url.length < 0) {
      return;
    }
    await launch(url);
  }

  /// 打开页面
  Future opEnPage(BuildContext context, String url) {
//    /usercenter/supportPage

    Routes.router.navigateTo(
      context,
      url,
      transition: TransitionType.cupertino,
    ).then((res) {
      return res;
//      if (res == 'loginBack') {
//        this.getUserInfo();
//      }
    });

  }
}