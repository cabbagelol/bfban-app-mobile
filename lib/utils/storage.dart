/// 功能：长久储存
import 'dart:typed_data';
import 'package:dio/dio.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class Storage {
  SharedPreferences? _prefs;

  SharedPreferences? get prefs => _prefs;

  /// [Event]
  /// 初始化
  init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// 是否初始化
  get isInit => _prefs != null;

  /// [Event]
  /// 储存图片
  Future saveimg(
    url, {
    fileUrl = "",
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

  /// [Event]
  /// 获取
  Future get(String name, {type = "string", backNullValue = "none"}) async {
    try {
      if (!isInit) await init();

      switch (type) {
        case "none":
          return _prefs!.get(name);
        case "string":
          return _prefs!.getString(name);
      }
    } catch (E) {
      rethrow;
    }
  }

  /// [Event]
  /// 设置
  Future set(String name, {String type = "string", value = "null"}) async {
    try {
      if (!isInit) await init();

      switch (type) {
        case "bool":
          _prefs!.setBool(name, value);
          break;
        case "string":
          await _prefs!.setString(name, value);
          break;
      }

      String a = await get(name);

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
          _prefs.remove(name); //删除指定键
          break;
      }

      return _prefs;
    } catch (E) {
      rethrow;
    }
  }

  /// [Event]
  /// 获取所有
  Future getAll () async {
    if (!isInit) await init();
    print('返回！');
    print(_prefs!.getKeys());
    return _prefs!.getKeys();
  }
}
