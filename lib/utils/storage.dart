/// 储存
library;

import 'dart:convert';

import 'package:bfban/constants/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

enum StorageType { string, int, double, bool }

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
    _preName = "${_packageInfo!.appName.trim().toLowerCase()}.${Config.envCurrentName}:";
  }

  /// 是否初始化
  get isInit => _prefs != null;

  /// [Event]
  /// 获取
  Future<StorageData> get(String name, {StorageType type = StorageType.string, backNullValue = "none"}) async {
    if (!isInit) await init();

    StorageData result = StorageData();

    switch (type) {
      case StorageType.int:
        result.setData(_prefs!.getInt("$_preName$name"));
        break;
      case StorageType.double:
        result.setData(_prefs!.getDouble("$_preName$name"));
        break;
      case StorageType.bool:
        result.setData(_prefs!.getBool("$_preName$name"));
        break;
      case StorageType.string:
        result.setData(_prefs!.getString("$_preName$name"));
        break;
    }

    return result;
  }

  /// [Event]
  /// 设置
  Future set(String key, {StorageType type = StorageType.string, value}) async {
    try {
      if (!isInit) await init();
      String name = "$_preName$key";
      switch (type) {
        case StorageType.int:
          _prefs!.setInt(name, value);
          break;
        case StorageType.double:
          _prefs!.setDouble(name, value);
          break;
        case StorageType.bool:
          _prefs!.setBool(name, value);
          break;
        case StorageType.string:
          int time = DateTime.now().millisecondsSinceEpoch;
          Map<dynamic, dynamic> val = {"time": time, "value": value};
          await _prefs!.setString(
            name,
            jsonEncode(val),
          );
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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      switch (type) {
        case "all":
          prefs.clear();
          break;
        case "name":
          prefs.remove("$_preName$name"); //删除指定键
          break;
      }

      return prefs;
    } catch (E) {
      rethrow;
    }
  }

  /// [Event]
  /// 删除所有
  Future removeAll() async {
    if (!isInit) await init();
    _prefs!.clear();
  }

  /// [Event]
  /// 获取所有
  Future getAll() async {
    if (!isInit) await init();
    List keys = [];
    for (var key in _prefs!.getKeys()) {
      keys.add({"value": _prefs!.get(key), "key": key});
    }
    return keys;
  }
}

class StorageData {
  int? code;
  num? time;
  dynamic value;

  StorageData({
    this.code = 0,
    this.time,
    this.value,
  });

  setData(dynamic data) {
    if (data != null) {
      Map map = {};
      if (data.runtimeType == String) {
        map = jsonDecode(data);
        if (map["time"] != null) time = map["time"];
        if (map["value"] != null) value = map["value"];
      }
    }
    return toMap;
  }

  get toMap {
    Map map = {"code": code};
    if (time == null && value == null) {
      code = -1;
      return map;
    }

    map.addAll({
      "time": time,
      "value": value,
    });
    return map;
  }
}
