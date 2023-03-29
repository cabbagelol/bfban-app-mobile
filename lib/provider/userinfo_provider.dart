/// 用户数据状态管理

import 'dart:convert';

import 'package:flutter/material.dart';

import '../data/index.dart';
import '../utils/index.dart';

class UserInfoProvider with ChangeNotifier {
  final UrlUtil _urlUtil = UrlUtil();

  String packageName = "login";

  BuildContext? context;

  /// 用户数据
  late Map _userdata = {
    "userinfo": {},
    "token": "",
  };

  // 是否已登录
  bool get isLogin {
    return userinfo.isNotEmpty && getToken.isNotEmpty;
  }

  // 是否管理员
  bool get isAdmin {
    return isLogin && userinfo["privilege"].any((i) => ["admin", "super"].contains(i));
  }

  // 获取用户信息
  Map get userinfo {
    return _userdata!["userinfo"] ?? {};
  }

  // 获取token
  String get getToken {
    return _userdata!["token"] ?? "";
  }

  /// [Event]
  /// 初始
  Future init() async {
    dynamic userinfo = await Storage().get(packageName);

    if (userinfo != null) {
      _userdata = jsonDecode(userinfo);
    }

    return _userdata;
  }

  /// [Event]
  /// 检查登录状态，否则调起登录
  bool checkLogin() {
    if (!isLogin) _urlUtil.opEnPage(context!, "login/panel");

    return isLogin;
  }

  /// [Event]
  /// 设置用户数据
  setData(Map? value) {
    _userdata = value!;
    notifyListeners();
    return true;
  }

  /// [Event]
  /// 擦除
  void clear() {
    _userdata.clear();
    notifyListeners();
  }
}
