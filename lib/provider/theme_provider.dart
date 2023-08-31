import 'package:flutter/material.dart';

import 'package:bfban/utils/index.dart';

import '../constants/theme.dart';
import '../data/index.dart';

class ThemeProvider with ChangeNotifier {
  BuildContext? context;

  /// 主题包名
  String? themePackageName = "theme";

  Storage storage = Storage();

  _TimeProviderInterval timeProviderInterval = _TimeProviderInterval(
    value: DateTime(DateTime.now().year, 0, 0, 7),
  );

  /// 主题
  ThemeProviderData theme = ThemeProviderData(
    defaultName: "dark",
    current: "",
    autoSwitchTheme: false,
    evening: "",
    morning: "",
    textScaleFactor: 1,
  );

  /// 主题表
  Map<String, AppBaseThemeItem>? list = ThemeList;

  /// [Event]
  /// 初始
  Future<bool> init() async {
    // 本地读取 赋予当前
    Map localTheme = await getLocalTheme();

    if (localTheme.isEmpty) return false;

    // 读取本地 更新自动主题状态
    theme.autoSwitchTheme = localTheme["autoTheme"];
    theme.current = localTheme["name"];
    theme.textScaleFactor = localTheme["textScaleFactor"] ?? 1;
    theme.morning = localTheme["morning"] ?? theme.defaultName;
    theme.evening = localTheme["evening"] ?? theme.defaultName;

    notifyListeners();
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
      _l.add(value.d);
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
    setLocalTheme(name);
    notifyListeners();
  }

  /// [Event]
  /// 获取储存主题
  Future<Map> getLocalTheme() async {
    StorageData? localTheme = await storage.get(themePackageName!);

    if (localTheme.code == 0) {
      Map formJson = localTheme.value;
      return formJson;
    }

    return {
      "name": theme.defaultName,
      "morning": theme.morning,
      "evening": theme.evening,
      "autoTheme": theme.autoSwitchTheme,
      "textScaleFactor": theme.textScaleFactor,
    };
  }

  /// [Event]
  /// 储存主题
  void setLocalTheme([String? name]) async {
    await storage.set(
      themePackageName!,
      value: {
        "name": name ?? theme.current,
        "morning": theme.morning,
        "evening": theme.evening,
        "autoTheme": theme.autoSwitchTheme,
        "textScaleFactor": theme.textScaleFactor,
      },
    );
  }

  /// [Event]
  /// 设置字体大小
  void setTextScaleFactor(double value) {
    if (value.isNaN) return;
    theme.textScaleFactor = value;
    setLocalTheme();
    notifyListeners();
  }

  /// 获取主题 ThemeData
  ThemeData get currentThemeData {
    ThemeData name = ThemeData();

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

    if (!theme.autoSwitchTheme!) {
      name = list![currentThemeName]!.d.themeData!;
    }

    // 自动选择主题，按照时间
    if (theme.autoSwitchTheme!) {
      DateTime currentTime = DateTime.now();
      if (currentTime.isBefore(timeInterval)) {
        // 早上
        name = list![theme.morning]!.d.themeData!;
      } else {
        // 晚上
        name = list![theme.evening]!.d.themeData!;
      }
    }

    // 配置主题外状态内容
    list![currentThemeName]!.changeSystem();

    return name;
  }

  /// 获取主题名称
  String get currentThemeName => theme.current!.isEmpty ? theme.defaultName! : theme.current!;

  /// 获取是否自动主题
  bool? get autoSwitchTheme => theme.autoSwitchTheme;

  /// 设置自动主题
  set autoSwitchTheme(bool? value) {
    theme.autoSwitchTheme = value;

    // 自动选择主题，按照时间
    if (theme.autoSwitchTheme!) {
      DateTime currentTime = DateTime.now();
      if (currentTime.isBefore(timeInterval)) {
        theme.current = theme.morning;
      } else {
        theme.current = theme.evening;
      }
    }

    notifyListeners();
  }

  // 上午下午中间分界线
  DateTime get timeInterval => timeProviderInterval.value!.toLocal();
}

class ThemeProviderData {
  String? current;
  String? defaultName;
  bool? autoSwitchTheme;
  String? evening;
  String? morning;
  double? textScaleFactor;

  ThemeProviderData({
    this.current,
    this.defaultName,
    this.autoSwitchTheme = false,
    this.evening,
    this.morning,
    this.textScaleFactor = 1.0,
  });
}

class _TimeProviderInterval {
  DateTime? value;

  _TimeProviderInterval({this.value});
}
