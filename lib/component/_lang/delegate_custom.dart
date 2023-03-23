/// 语言包装

import 'dart:async';
import 'dart:convert';

import 'package:bfban/utils/storage.dart';
import 'package:flutter_i18n/loaders/file_translation_loader.dart';
import 'package:http/http.dart' as http;

class CustomTranslationLoader extends FileTranslationLoader {
  // 包名
  // 与[lang_provider]packageName一致
  String packageName = "com.bfban.language";

  final Uri baseUri;

  final List<String>? namespaces;

  Map<dynamic, dynamic> _decodedMap = {};

  CustomTranslationLoader({required this.namespaces, required this.baseUri, basePath = "assets/lang", forcedLocale, fallback = "zh_CN", useCountryCode = false, useScriptCode = false, decodeStrategies}) : super(fallbackFile: fallback, useCountryCode: useCountryCode, basePath: basePath, forcedLocale: forcedLocale, decodeStrategies: decodeStrategies) {
    assert(namespaces != null);
    assert(namespaces!.isNotEmpty);
  }

  @override
  Future<String> loadString(final String fileName, final String extension) async {
    Uri resolvedUri = baseUri.replace(path: '${baseUri.path}/$fileName.$extension');
    dynamic local = await Storage().get(packageName);
    dynamic result;

    // 从远程服务器取得LANG配置单，如果缓存则使用本地
    if (local == null || local.toString().isEmpty) {
      dynamic networkLang = await http.get(resolvedUri);
      result = jsonDecode(utf8.decode(networkLang.bodyBytes));
    } else {
      result = jsonDecode(local)["listConf"];
    }

    _decodedMap.addAll(jsonDecode(await assetBundle.loadString('$basePath/${composeFileName()}/app.json', cache: false)));
    _decodedMap.addAll(result);

    return jsonEncode(_decodedMap);
  }
}
