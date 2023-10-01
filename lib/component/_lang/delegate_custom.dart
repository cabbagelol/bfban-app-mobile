/// 语言包装

import 'dart:async';
import 'dart:convert';

import 'package:flutter_i18n/loaders/file_translation_loader.dart';
import 'package:bfban/utils/index.dart';

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
    fallback = "",
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
    Uri resolvedUri = baseUri.replace(path: '${baseUri.path}/$fileName.json');
    StorageData languageData = await storage.get(packageName);

    dynamic local = languageData.value;
    dynamic networkLanguageResult = {};
    dynamic localLanguageResult = {};
    dynamic localStatusCodeResult = {};

    // 从远程服务器取得LANG配置单，如果缓存则使用本地
    if (local == null || local.toString().isEmpty) {
      Response networkLang = await Http.request(resolvedUri.path);
      if (networkLang.statusCode != null) {
        networkLanguageResult = jsonDecode(networkLang.data);
      }
    } else {
      networkLanguageResult = local["listConf"];
    }

    // 本地载入
    String localLanguagePath = "$basePath/${composeFileName()}.json";
    String loadString = await assetBundle.loadString(localLanguagePath, cache: false);
    if (loadString.isEmpty) {
      String localFallbackFilePath = "$basePath/$fallbackFile.json";
      localLanguageResult = jsonDecode(await assetBundle.loadString(localFallbackFilePath, cache: false));
    } else {
      localLanguageResult = jsonDecode(loadString);
    }

    String localStatusCodePath = "$basePath/${composeFileName()}_status_code.json";
    String loadStatusCodeString = await assetBundle.loadString(localStatusCodePath, cache: false);
    if (loadStatusCodeString.isEmpty) {
      String localFallbackFilePath = "$basePath/${fallbackFile}_status_code.json";
      localStatusCodeResult = jsonDecode(await assetBundle.loadString(localFallbackFilePath, cache: false));
    } else {
      localStatusCodeResult = jsonDecode(loadStatusCodeString);
    }

    _decodedMap.addAll(localLanguageResult);
    _decodedMap.addAll(localStatusCodeResult);
    _decodedMap.addAll(networkLanguageResult);

    return jsonEncode(_decodedMap);
  }
}
