/// 语言包装
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter_i18n/loaders/file_translation_loader.dart';
import 'package:bfban/utils/index.dart';

class CustomTranslationLoader extends FileTranslationLoader {
  // 包名
  // 与[translation_provider]packageName一致
  String packageName = "language";

  final Uri baseUri;

  final List<String>? namespaces;

  final Storage storage = Storage();

  final Map<dynamic, dynamic> _decodedMap = {};

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
    // 尝试从本地存储获取语言配置
    final languageData = await storage.get(packageName);
    final localConfig = languageData.value;

    // 优先使用本地缓存的语言配置
    final networkLanguage = localConfig != null ? localConfig["listLangs"] : {};

    // 构建语言文件名
    final languagePath = "$basePath/${composeFileName()}.json";

    // 尝试从本地加载语言文件
    final localLanguage = await _loadJson(languagePath) ?? {};

    // 尝试从本地加载状态码文件（可选）
    final statusCodePath = "$basePath/${composeFileName()}_status_code.json";
    final statusCodeMap = await _loadJson(statusCodePath) ?? {};

    // 合并所有数据源
    final mergedData = {
      ...localLanguage,
      ...statusCodeMap,
      ...networkLanguage,
    };

    return jsonEncode(mergedData);
  }

  Future<Map<String, dynamic>> _loadJson(String path) async {
    try {
      final jsonString = await assetBundle.loadString(path, cache: true);
      return jsonDecode(jsonString);
    } catch (e) {
      return <String, dynamic>{};
    }
  }
}
