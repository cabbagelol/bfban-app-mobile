import 'package:flutter/material.dart';

import 'package:bfban/constants/theme.dart';

class AppInfoProvider with ChangeNotifier {
  String _themeColor = "bright";

  String get themeColor => _themeColor;

  setTheme(String themeColor) {
    _themeColor = themeColor;
    notifyListeners();
  }
}
