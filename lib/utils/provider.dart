import 'package:flutter/material.dart';

import 'package:bfban/constants/theme.dart';

class AppInfoProvider with ChangeNotifier {
  String _themeColor;

  String get themeColor => _themeColor;

  /// _guideState表示着初始App呈现的view
  /// 如果表示:
  /// 1 -> 正常首页
  /// 0 -> 引导器 (前往/guide/guide.dart查看)
  num _guideState = 0;

  num get guideState => _guideState;

  Future setTheme(String themeColor) async {
    print("修改值 $themeColor");

    _themeColor = themeColor;
    notifyListeners();
  }

  /// 应用引导状态
  Future setGuideNumberState(num n) async {
    _guideState = n;
    notifyListeners();
  }
}
