/// 储存
import 'package:bfban/constants/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Storage {
  PackageInfo? _packageInfo;

  SharedPreferences? _prefs;

  SharedPreferences? get prefs => _prefs;

  String _preName = "";

  /// [Event]
  /// 初始化
  init() async {
    _packageInfo = await PackageInfo.fromPlatform();
    _prefs = await SharedPreferences.getInstance();
    _preName = "${_packageInfo!.appName.toLowerCase()}.${Config.envCurrentName}:";
  }

  /// 是否初始化
  get isInit => _prefs != null;

  /// [Event]
  /// 获取
  Future<dynamic> get(String name, {type = "string", backNullValue = "none"}) async {
    if (!isInit) await init();

    dynamic result;

    switch (type) {
      case "none":
        result = _prefs!.get("$_preName$name");
        break;
      case "string":
        result = _prefs!.getString("$_preName$name");
        break;
    }

    return result;
  }

  /// [Event]
  /// 设置
  Future set(String name, {String type = "string", value = "null"}) async {
    try {
      if (!isInit) await init();
      switch (type) {
        case "bool":
          _prefs!.setBool("$_preName$name", value);
          break;
        case "string":
          await _prefs!.setString("$_preName$name", value);
          break;
      }

      return _prefs;
    } catch (E) {
      rethrow;
    }
  }

  /// [Event]
  /// 删除
  Future remove(String name, {String type = "name"}) async {
    try {
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      switch (type) {
        case "all":
          _prefs.clear();
          break;
        case "name":
          _prefs.remove("$_preName$name"); //删除指定键
          break;
      }

      return _prefs;
    } catch (E) {
      rethrow;
    }
  }

  /// [Event]
  /// 删除所有
  Future removeAll () async {
    if (!isInit) await init();
    _prefs!.clear();
  }

  /// [Event]
  /// 获取所有
  Future getAll() async {
    if (!isInit) await init();
    List keys = [];
    _prefs!.getKeys().forEach((key) {
      keys.add({
        "value": _prefs!.get(key),
        "key": key
      });
    });
    return keys;
  }
}
