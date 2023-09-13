/// 语言包装

import 'dart:async';
import 'dart:convert';

import 'package:bfban/utils/storage.dart';
import 'package:flutter_i18n/loaders/file_translation_loader.dart';
import 'package:http/http.dart' as http;

class CustomTranslationLoader extends FileTranslationLoader {
  // 包名
  // 与[lang_provider]packageName一致
  String packageName = "language";

  final Uri baseUri;

  final List<String>? namespaces;

  final Storage storage = Storage();

  Map<dynamic, dynamic> _decodedMap = {};

  CustomTranslationLoader({
    required this.namespaces,
    required this.baseUri,
    basePath = "assets/lang",
    forcedLocale,
    fallback = "zh_CN",
    useCountryCode = false,
    useScriptCode = false,
    decodeStrategies,
  }) : super(
          fallbackFile: fallback,
          useCountryCode: useCountryCode,
          basePath: basePath,
          forcedLocale: forcedLocale,
          decodeStrategies: decodeStrategies,
        ) {
    assert(namespaces != null);
    assert(namespaces!.isNotEmpty);
  }

  @override
  Future<String> loadString(final String fileName, final String extension) async {
    Uri resolvedUri = baseUri.replace(path: '${baseUri.path}/$fileName.$extension');
    StorageData languageData = await storage.get(packageName);
    dynamic local = languageData.value;
    dynamic networkResult;
    dynamic localResult;

    // 从远程服务器取得LANG配置单，如果缓存则使用本地
    if (local == null || local.toString().isEmpty) {
      dynamic networkLang = await http.get(resolvedUri);
      networkResult = jsonDecode(utf8.decode(networkLang.bodyBytes));
    } else {
      networkResult = local["listConf"];
    }

    // 本地载入
    String localPath = "$basePath/${composeFileName()}.json";
    String loadString = await assetBundle.loadString(localPath, cache: false);
    if (loadString.isEmpty) {
      String localFallbackFilePath = "$basePath/$fallbackFile.json";
      localResult = jsonDecode(await assetBundle.loadString(localFallbackFilePath, cache: false));
    } else {
      localResult = jsonDecode(loadString);
    }

    _decodedMap.addAll(localResult);
    _decodedMap.addAll(networkResult);

    return jsonEncode(_decodedMap);
  }
}
