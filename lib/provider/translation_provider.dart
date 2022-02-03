import 'package:bfban/utils/http.dart';
import 'package:flutter/cupertino.dart';

/// 本地语言

class TranslationProvider with ChangeNotifier {
  /// 本地语言
  TranslationData data = TranslationData(
    currentLang: "",
    langList: [],
    autoSwitchLang: false,
  );

  bool get autoSwitchLang => data.autoSwitchLang!;

  set autoSwitchLang(bool value) {
    data.autoSwitchLang = value;
    notifyListeners();
  }

  /// [Response]
  /// 获取网络
  init() {}

  /// [Response]
  /// 获取网络
  getConf() {}

  /// [Event]
  /// 设置语言
  set currentLang(value) {
    data.currentLang = value;
    notifyListeners();
  }

  /// [Event]
  /// 获取语言
  get currentLang => data.currentLang;
}

class TranslationData {
  /// 当前语言
  late String? currentLang;
  late List? langList;
  bool? autoSwitchLang;

  TranslationData({
    this.currentLang,
    this.langList,
    this.autoSwitchLang,
  });
}
