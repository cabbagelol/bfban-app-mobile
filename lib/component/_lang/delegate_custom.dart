import 'dart:async';
import 'dart:convert';

import 'package:flutter_i18n/loaders/file_translation_loader.dart';
import 'package:flutter_i18n/utils/message_printer.dart';
import 'package:http/http.dart' as http;

class CustomTranslationLoader extends FileTranslationLoader {
  final Uri baseUri;
  final List<String>? namespaces;

  Map<dynamic, dynamic> _decodedMap = {};

  CustomTranslationLoader(
      {
        required this.namespaces,
        required this.baseUri,
        basePath = "assets/lang",
        forcedLocale,
        fallback = "en",
        useCountryCode = false,
        useScriptCode = false,
        decodeStrategies})
      : super(
      fallbackFile: fallback,
      useCountryCode: useCountryCode,
      basePath: basePath,
      forcedLocale: forcedLocale,
      decodeStrategies: decodeStrategies) {
    assert(namespaces != null);
    assert(namespaces!.length > 0);
  }

  @override
  Future<String> loadString(final String fileName, final String extension) async {
    final resolvedUri = resolveUri(fileName, 'json');
    final result = await http.get(resolvedUri);

    _decodedMap.addAll(jsonDecode( await assetBundle.loadString('$basePath/${composeFileName()}/app.json', cache: false) ));
    _decodedMap.addAll(jsonDecode(utf8.decode(result.bodyBytes)));

    return jsonEncode(_decodedMap);
  }

  Uri resolveUri(final String fileName, final String extension) {
    final fileToFind = '$fileName.$extension';
    return baseUri.replace(path: '${baseUri.path}/$fileToFind');
  }
}