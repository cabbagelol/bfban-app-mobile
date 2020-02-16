/**
 * 功能：长久储存
 * 描述：
 */

import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static SharedPreferences prefs;

  /// 获取
  static Future get(String name, {type: "string"}) async {
    prefs = await SharedPreferences.getInstance();
    switch (type) {
      case "string":
        return prefs.get(name) ?? null;
        break;
    }
  }

  /// 设置
  static set(String name, {String type = "string", value = "null"}) async {
    prefs = await SharedPreferences.getInstance();
    switch (type) {
      case "bool":
        break;
      case "string":
        await prefs.setString(name, value).then((value) {
          get("Storage.get: ${name}");
        });
        break;
    }
  }

  /// 删除
  static remove(String name, {String type = "name"}) async {
    prefs = await SharedPreferences.getInstance();
    switch (type) {
      case "all":
        prefs.clear();
        break;
      case "name":
        prefs.remove(name); //删除指定键
        break;
    }
  }
}
