/// 功能：长久储存
import 'dart:typed_data';
import 'package:dio/dio.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class Storage {
  static SharedPreferences _prefs;

  static SharedPreferences get getPrefs => _prefs;

  /// 储存图片
  static Future saveimg(
    url, {
    fileUrl: "",
  }) async {
    var response = await Dio().get(
      url,
      options: Options(
        responseType: ResponseType.bytes,
      ),
    );

    final result = await ImageGallerySaver.saveImage(
      Uint8List.fromList(
        response.data,
      ),
    );

    if (result != "") {
      return {
        "src": result,
        "code": 0,
      };
    }

    return {
      "code": -1,
    };
  }

  /// 获取
  static Future get(String name, {type: "string"}) async {
    try {
      _prefs = await SharedPreferences.getInstance();
      switch (type) {
        case "string":
          return _prefs.get(name) ?? null;
          break;
      }

      return _prefs;
    } catch (E) {
      throw E;
    }
  }

  /// 设置
  static Future set(String name, {String type = "string", value = "null"}) async {
    try {
      _prefs = await SharedPreferences.getInstance();
      switch (type) {
        case "bool":
          break;
        case "string":
          await _prefs.setString(name, value).then((value) {
            get("Storage.get: $name");
          });
          break;
      }

      return _prefs;
    } catch (E) {
      throw E;
    }
  }

  /// 删除
  static Future remove(String name, {String type = "name"}) async {
    try {
      _prefs = await SharedPreferences.getInstance();
      switch (type) {
        case "all":
          _prefs.clear();
          break;
        case "name":
          _prefs.remove(name); //删除指定键
          break;
      }

      return _prefs;
    } catch (E) {
      throw E;
    }
  }
}
