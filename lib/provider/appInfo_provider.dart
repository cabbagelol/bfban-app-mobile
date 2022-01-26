/// 全局状态管理

import 'package:flutter/material.dart';

import 'package:bfban/utils/index.dart';

import 'package:bfban/themes/default.dart';
import 'package:bfban/themes/lightness.dart';
import '../data/index.dart';

class AppInfoProvider with ChangeNotifier {
  /// 主题包名
  String? themePackageName = "com.bfban.theme";

  /// 主题
  ThemeProvider theme = ThemeProvider(
    defaultName: "default",
    current: "",
  );

  /// 主题表
  Map<String, AppThemeItem>? list = {
    "default": DefaultTheme.data,
    "lightnes": LightnesTheme.data,
  };

  /// [Event]
  /// 初始
  init() async {
    // 本地读取 赋予当前
    theme.current = await getLoaclTheme();
  }

  /// [Event]
  /// 获取主题列表, 从map转list类型
  List<AppThemeItem>? get getList {
    List<AppThemeItem> _l = [];
    list!.forEach((key, value) {
      _l.add(value);
    });
    return _l;
  }

  /// [Event]
  /// 设置主题
  setTheme(String name) async {
    // 设置主题
    theme.current = name;

    // 持久储存
    setLoaclTheme(name);
    notifyListeners();
  }

  /// [Event]
  /// 获取储存主题
  Future<String?> getLoaclTheme() async {
    String loacl = await Storage().get(themePackageName!);

    if (loacl != null) {
      return loacl;
    }

    return theme.defaultName;
  }

  /// [Event]
  /// 储存主题
  void setLoaclTheme(String name) async {
    await Storage().set(themePackageName!, value: name);
  }

  /// 获取主题 ThemeData
  ThemeData get currentThemeData {
    return list![currentThemeName]!.themeData!;
  }

  /// 获取主题名称
  String get currentThemeName =>
      theme.current!.isEmpty ? theme.defaultName! : theme.current!;
}

class ThemeProvider {
  String? current;
  String? defaultName;

  ThemeProvider({
    this.current,
    this.defaultName,
  });
}
