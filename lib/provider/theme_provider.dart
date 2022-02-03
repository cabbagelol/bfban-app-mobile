/// 主题状态管理

import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:bfban/utils/index.dart';

import 'package:bfban/themes/default.dart';
import 'package:bfban/themes/lightnes.dart';
import '../data/index.dart';

class ThemeProvider with ChangeNotifier {
  BuildContext? context;

  /// 主题包名
  String? themePackageName = "com.bfban.theme";

  /// 主题
  ThemeProviderData theme = ThemeProviderData(
    defaultName: "default",
    current: "",
    autoSwitchTheme: false,
  );

  /// 主题表
  Map<String, AppThemeItem>? list = {
    "default": DefaultTheme.data,
    "lightnes": LightnesTheme.data,
  };

  /// [Event]
  /// 初始
  Future<bool> init() async {
    // 本地读取 赋予当前
    Map loacl = await getLoaclTheme();

    if (loacl.isEmpty) return false;

    // 读取本地 更新自动主题状态
    theme.autoSwitchTheme = loacl["autoTheme"];

    theme.current = loacl["name"];

    return true;
  }

  Brightness get isBrightnessMode {
    return MediaQuery.platformBrightnessOf(context!);
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
    if (theme.autoSwitchTheme!) return;

    // 设置主题
    theme.current = name;

    // 持久储存
    setLoaclTheme(name);
    notifyListeners();
  }

  /// [Event]
  /// 获取储存主题
  Future<Map> getLoaclTheme() async {
    String? loacl = await Storage().get(themePackageName!);

    if (loacl != null) {
      Map formjson = jsonDecode(loacl);
      return formjson;
    }

    return {
      "name": theme.defaultName,
      "autoTheme": theme.autoSwitchTheme,
    };
  }

  /// [Event]
  /// 储存主题
  void setLoaclTheme(String name) async {
    await Storage().set(themePackageName!,
        value: jsonEncode({
          "name": name,
          "autoTheme": theme.autoSwitchTheme,
        }));
  }

  /// 获取主题 ThemeData
  ThemeData get currentThemeData {
    // 是否开启自动主题，依照自动决定
    if (theme.autoSwitchTheme!) {
      switch (isBrightnessMode) {
        case Brightness.dark:
          theme.current = theme.defaultName;
          break;
        case Brightness.light:
          theme.current = "lightnes";
          break;
      }
    }
    return list![currentThemeName]!.themeData!;
  }

  /// 获取主题名称
  String get currentThemeName => theme.current!.isEmpty ? theme.defaultName! : theme.current!;

  /// 获取是否自动主题
  bool? get autoSwitchTheme => theme.autoSwitchTheme;

  /// 设置自动主题
  set autoSwitchTheme(bool? value) {
    theme.autoSwitchTheme = value;

    // 更改后更新本地
    setLoaclTheme(theme.current.toString());

    notifyListeners();
  }
}

class ThemeProviderData {
  String? current;
  String? defaultName;
  bool? autoSwitchTheme;

  ThemeProviderData({
    this.current,
    this.defaultName,
    this.autoSwitchTheme,
  });
}
