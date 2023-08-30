import 'package:flutter/cupertino.dart';

import '../utils/index.dart';

class TranslationProvider with ChangeNotifier {
  // 包名
  String packageName = "language";

  // 语言字典列表
  List _listDictionaryFrom = [];

  // 语言配置列表
  // 如: { 'zh': {} }
  Map _list = {};

  // 当前语言
  // 如: [zh, en, jp ...]
  String _currentLang = "";

  // 获取当前语言
  String get currentLang => _currentLang;

  set currentLang(String value) {
    _currentLang = value;
    setLocalLang();
    notifyListeners();
  }

  Storage storage = Storage();

  // 初始化
  Future init() async {
    Map _localLang = await getLocalLang();

    if (_listDictionaryFrom.isEmpty && _localLang.isEmpty) {
      await getLangFrom();
      await updateLocalLang();
    }

    _currentLang = _localLang["currentLang"];
    notifyListeners();
  }

  // [Event]
  // 读取本地语言表
  Future<Map> getLocalLang() async {
    StorageData languageData = await storage.get(packageName);
    dynamic local = languageData.value;

    if (local != null) {
      return local;
    }

    return {};
  }

  // [Event]
  // 写入本地消息内容
  Future<bool> setLocalLang() async {
    Map data = {
      'currentLang': currentLang,
      'listDictionaryFrom': await getLangFrom(),
      'listConf': await getLangConf(currentLang)
    };

    await storage.set(packageName, value: data);
    return true;
  }

  // 更新国际化配置到本地
  Future updateLocalLang() async {
    for (var element in _listDictionaryFrom) {
      // 不需要同步
      await getLangConf(element["fileName"]);
    }

    setLocalLang();
  }

  // 获取国际化字典表
  Future getLangFrom() async {
    notifyListeners();
    Response result = await Http.request(
      "config/languages.json",
      httpDioValue: "app_web_site",
      method: Http.GET,
    );

    if (result.data.toString().isNotEmpty) {
      _listDictionaryFrom = result.data["child"];
    }
    notifyListeners();

    return result.data["child"];
  }

  // 获取国际化对应的语言文本
  Future getLangConf(currentLang) async {
    notifyListeners();
    Response result = await Http.request(
      "lang/$currentLang.json",
      httpDioValue: "web_site",
      method: Http.GET,
    );

    if (result.data.toString().isNotEmpty) {
      _list[currentLang] = result.data;
    }

    notifyListeners();
    return result.data;
  }
}
