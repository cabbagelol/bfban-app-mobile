import 'package:flutter/material.dart';

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
