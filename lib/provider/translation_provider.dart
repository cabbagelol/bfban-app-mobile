import 'package:flutter/cupertino.dart';

import '../data/index.dart';
import '../utils/index.dart';

// 程序国际化
class TranslationProvider with ChangeNotifier {
  Storage storage = Storage();

  // 包名
  String packageName = "language";

  // 语言字典列表
  List _listDictionaryFrom = [];

  // 语言配置列表
  // 如: { 'zh': {} }
  Map _list = {};

  // 默认语言
  String _default = "zh_CN";

  String get defaultLang => _default;

  // 当前语言
  // 如: [zh, en, jp ...]
  String _currentLang = "";

  // 获取当前语言
  String get currentLang => _currentLang.isEmpty ? _default : _currentLang;

  // 转换当前语言对应的本地文本
  // 如: zh_CN:中文简体、en_US:English
  String get currentToLocalLangName {
    if (_listDictionaryFrom.isEmpty) return _currentLang;
    Iterable i = _listDictionaryFrom.where((element) => element["fileName"] == _currentLang);
    return i.isNotEmpty ? i.first["label"] : _currentLang;
  }

  set currentLang(String value) {
    _currentLang = value;
    setLocalLang();
    notifyListeners();
  }

  // 初始化
  Future init() async {
    Map localLang = await getLocalLang();

    if (_listDictionaryFrom.isEmpty && localLang.isEmpty) {
      await getNetworkLangListDictionary();
      await updateLocalLang();
    }

    _currentLang = localLang["currentLang"];
    notifyListeners();
  }

  // [Event]
  // 读取本地语言表
  Future<Map> getLocalLang() async {
    StorageData languageData = await storage.get(packageName);
    dynamic local = languageData.value;

    if (local != null) {
      _listDictionaryFrom = local["listDictionaryFrom"];
      _currentLang = local["currentLang"];
      return local;
    }

    return {};
  }

  // [Event]
  // 写入本地消息内容
  Future<bool> setLocalLang() async {
    Map data = {
      "currentLang": currentLang,
      "listDictionaryFrom": await getNetworkLangListDictionary(), // 所有可用语言字典表
      "listLangs": await getNetworkLangData(currentLang),
    };

    await storage.set(packageName, value: data);
    return true;
  }

  // 更新国际化配置到本地
  Future updateLocalLang() async {
    for (var i in _listDictionaryFrom) {
      // 不需要同步
      await getNetworkLangData(i["fileName"]);
    }

    setLocalLang();
  }

  // 获取国际化字典表
  Future getNetworkLangListDictionary() async {
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
  Future getNetworkLangData(currentLang) async {
    notifyListeners();
    Response result = await Http.request(
      "lang/$currentLang.json",
      httpDioValue: "web_site",
      method: Http.GET,
    );

    if (result.data.toString().isNotEmpty) {
      _list[currentLang] = result.data;
      _list[currentLang].addAll({"updateTime": DateTime.now().millisecondsSinceEpoch});
    }

    notifyListeners();
    return result.data;
  }
}

// 翻译模块
// 用于内容翻译
class PublicApiTranslationProvider with ChangeNotifier {
  Storage storage = Storage();

  // 包名
  String NAME = "apiPublicTranslator";
  String SWITCHNAME = ".switch";
  String SELECTACTIVATE = ".selectActivate";

  // 默认激活名称
  String _default = "youdao";

  // 翻译工具是否打开
  bool _isSwitch = false;

  // 所有模块
  List<PublicTranslatorItem> allTranslator = [
    PublicTranslatorItem(),
    PublicTranslatorDeeplItem(),
    PublicTranslatorYoudaoItem(),
    PublicTranslatorGoogleItem(),
  ];

  // 用户选购添加翻译API
  List<PublicTranslatorBox> userTrList = [];

  // 初始化
  Future init() async {
    await getSwitch();
    await initUserUseTrList();
    await getSelectActivate();

    notifyListeners();
    return true;
  }

  String _selectActivate = "";

  String get selectActivate => _selectActivate;

  set selectActivate(String value) {
    _selectActivate = value;
    storage.set(NAME + SELECTACTIVATE, value: value);
    notifyListeners();
  }

  get isSwitch => _isSwitch;

  set isSwitch(value) {
    _isSwitch = value;
    storage.set(NAME + SWITCHNAME, value: _isSwitch);
    notifyListeners();
  }

  // 当前激活翻译模块实例
  PublicTranslatorItem get currentPublicTranslatorItem {
    PublicTranslatorItem currentPublicTranslatorItem = PublicTranslatorItem();
    if (userTrList.isNotEmpty && selectActivate.isNotEmpty) currentPublicTranslatorItem = allTranslator.where((PublicTranslatorItem i) => i.type.name == selectActivate).first;
    return currentPublicTranslatorItem;
  }

  // 读取使用模块名称
  Future getSelectActivate() async {
    StorageData sa = await storage.get(NAME + SELECTACTIVATE);
    if (sa.code != 0) return _default;
    _selectActivate = sa.value ?? _default;
    return _selectActivate;
  }

  // 获取开关状态
  getSwitch() async {
    StorageData sa = await storage.get(NAME + SWITCHNAME);
    if (sa.code != 0) return isSwitch;
    _isSwitch = sa.value;
    notifyListeners();
    return sa.value;
  }

  // 切换开启翻译工具开关
  onSwitchTranslatorTool() {
    _isSwitch = !_isSwitch;
    storage.set(NAME + SWITCHNAME, value: _isSwitch);
    notifyListeners();
  }

  // 获取用户添加模块数据列表
  initUserUseTrList() async {
    StorageData userTrListData = await storage.get(NAME);
    if (userTrListData.code != 0) return userTrList;

    for (var i in Map.from(userTrListData.value).entries) {
      switch (i.key) {
        case "deepl":
          PublicTranslatorDeeplItem deepl = PublicTranslatorDeeplItem();
          deepl.toMap = i.value;
          userTrList.add(PublicTranslatorBox(
            data: deepl,
            index: 1,
          ));
          break;
        case "google":
          PublicTranslatorGoogleItem google = PublicTranslatorGoogleItem();
          google.toMap = i.value;
          userTrList.add(PublicTranslatorBox(
            data: google,
            index: 2,
          ));
          break;
        case "youdao":
          PublicTranslatorYoudaoItem youdao = PublicTranslatorYoudaoItem();
          youdao.toMap = i.value;
          userTrList.add(PublicTranslatorBox(
            data: youdao,
            index: 3,
          ));
          break;
      }
    }

    notifyListeners();
    return userTrList;
  }

  // 保存用户编辑翻译模块数据
  Map onSave() {
    Map map = {};
    for (var element in userTrList) {
      if (element.data!.type != PublicTranslatorType.none) map[element.data!.type.name] = element.data!.toMap;
    }
    if (map.isEmpty) return {"code": -2};
    storage.set(NAME, value: map);
    return {"code": 0};
  }
}
