import 'package:flutter/material.dart';

import 'package:bfban/constants/theme.dart';

class AppInfoProvider with ChangeNotifier {
  String _themeColor;

  String get themeColor => _themeColor;

  Future setTheme(String themeColor) async {
    print("修改值 $themeColor");

    _themeColor = themeColor;
    notifyListeners();
  }
}
