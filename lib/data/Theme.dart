import 'package:flutter/material.dart';

class AppBaseThemeItem {
  AppBaseThemeItem() {
    init();
  }

  init() {}

  void changeSystem() {}

  get d => data;

  static dynamic data = AppThemeItem();
}

/// 单个主题
class AppThemeItem {
  final String name;
  final bool isDefault;
  final ThemeData? themeData;

  AppThemeItem({
    this.name = "none",
    this.isDefault = false,
    this.themeData,
  });
}
