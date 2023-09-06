import 'dart:convert';

import 'package:bfban/utils/index.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum PublicTranslatorType {
  none,
  deepl,
  google,
  youdao,
}

class PublicTranslatorItem extends Http {
  PublicTranslatorType type = PublicTranslatorType.none;

  Storage storage = Storage();

  // 默认目标语言
  String defaultToLang = "";

  // 当前选择的语言
  String _currentToLang = "";

  String get currentToLang => _currentToLang.isEmpty ? defaultToLang : _currentToLang;

  set currentToLang(String value) {
    if (value.isEmpty) return;
    _currentToLang = value;
  }

  // 所有支持目标语言
  // 每个模块所支持的语言不一致
  Map<String, String> allToLang = {};

  // 存放值
  Map toMap = {};

  // 支持链接
  get support => "";

  Future<String> tr(String content, targetLang) async => "";
}

class PublicTranslatorBox {
  PublicTranslatorItem? data = PublicTranslatorItem();
  int? index = 0;

  PublicTranslatorBox({
    Key? key,
    this.data,
    this.index,
  });
}

// Deepl翻译
class PublicTranslatorDeeplItem extends PublicTranslatorItem {
  @override
  PublicTranslatorType get type => PublicTranslatorType.deepl;

  @override
  String defaultToLang = "en";

  @override
  Map<String, String> allToLang = {
    "en": "English",
    "zh-CH": "中文-简体",
  };

  PublicTranslatorDeeplItem();

  @override
  Map toMap = {
    "deepl.key": "",
  };

  @override
  get support => "https://www.deepl.com/docs-api";

  @override
  Future<String> tr(String content, targetLang) async {
    StorageData keyData = await storage.get("apiPublicTranslator");

    if (keyData.value['deepl'] == null) return "";

    String key = keyData.value['deepl']["deepl.key"];
    String resultString = "";

    if (key.isEmpty) return "";

    Response result = await Http.request(
      'https://api-free.deepl.com/v2/translate',
      method: Http.POST,
      headers: {'Authorization': 'DeepL-Auth-Key $key'},
      data: {
        "text": [content],
        "target_lang": targetLang,
        "tag_handling": "html"
      },
      httpDioValue: "",
      httpDioType: HttpDioType.api,
    );

    List list = result.data["translation"] ?? [];
    for (var text in list) {
      resultString += text;
    }
    return resultString;
  }
}

// 有道翻译
class PublicTranslatorYoudaoItem extends PublicTranslatorItem {
  @override
  PublicTranslatorType get type => PublicTranslatorType.youdao;

  @override
  String defaultToLang = "zh-CHS";

  @override
  Map<String, String> allToLang = {
    "ar": "Arabic",
    "de": "German",
    "en": "English",
    "fr": "French",
    "ja": "Japanese",
    "ru": "Russian",
    "zh-CHS": "中文-简体",
    "zh-CHT": "中文-繁体",
    "tr": "Turkish",
  };

  PublicTranslatorYoudaoItem();

  @override
  Map toMap = {
    "youdao.key": "",
    "youdao.appKey": "",
  };

  @override
  get support => "https://ai.youdao.com/DOCSIRMA/html/trans/api/wbfy/index.html";

  @override
  Future<String> tr(String content, targetLang) async {
    StorageData keyData = await storage.get("apiPublicTranslator");

    if (keyData.value['youdao'] == null) return "";

    String resultString = "";
    String salt = const Uuid().v4();
    String key = keyData.value['youdao']["youdao.key"].toString().trim(); // 应用密钥
    String appKey = keyData.value['youdao']["youdao.appKey"].toString().trim(); // APP ID
    String curtime = (DateTime.now().millisecondsSinceEpoch / 1000).toInt().toString();

    String signString = appKey + truncate(content) + salt + curtime + key;

    List<int> bytes = utf8.encode(signString);
    var sign = sha256.convert(bytes);

    Map<String, dynamic> data = {
      "q": content.toString(),
      "from": "auto",
      "to": targetLang,
      "appKey": appKey,
      "salt": salt,
      "sign": sign,
      "signType": "v3",
      "curtime": curtime,
    };
    FormData formData = FormData.fromMap(data);

    Response result = await Http.request(
      'https://openapi.youdao.com/api',
      method: Http.POST,
      data: formData,
      httpDioValue: "",
      httpDioType: HttpDioType.none,
    );

    List list = result.data["translation"] ?? [];
    for (var text in list) {
      resultString += text;
    }
    return resultString;
  }

  truncate(String q) {
    int len = q.length;
    if (len <= 20) return q;
    return q.substring(0, 10) + len.toString() + q.substring(len - 10, len);
  }
}

// 谷歌翻译
class PublicTranslatorGoogleItem extends PublicTranslatorItem {
  @override
  PublicTranslatorType get type => PublicTranslatorType.google;

  @override
  String defaultToLang = "en";

  @override
  Map<String, String> allToLang = {
    "en": "English",
    "zh-CH": "中文-简体",
  };

  @override
  Map toMap = {
    "googleTranslator.key": "",
  };

  @override
  get support => "https://translator.google.com";

  @override
  Future<String> tr(String content, targetLang) async {
    StorageData keyData = await storage.get("apiPublicTranslator");

    if (keyData.value['google'] == null) return "";

    return "";
  }
}
