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

  // @override
  // Future<String> loadString(final String fileName, final String extension) async {
  //   final resolvedUri = resolveUri(fileName, extension);
  //   final result = await http.get(resolvedUri);
  //   return utf8.decode(result.bodyBytes);
  // }
  //
  // Uri resolveUri(final String fileName, final String extension) {
  //   final fileToFind = '$fileName.$extension';
  //   return this.baseUri.replace(path: '${this.baseUri.path}/$fileToFind');
  // }

  /// Return the translation Map for the namespace
  Future<Map> load() async {
    this.locale = locale ?? await findDeviceLocale();
    MessagePrinter.info("The current locale is ${this.locale}");

    await Future.wait(
        namespaces!.map((namespace) => _loadTranslation(namespace, 'json')));

    return _decodedMap;
  }

  Future<void> _loadTranslation(String namespace, String extension) async {
    _decodedMap[namespace] = Map();

    try {
      _decodedMap[namespace] = await assetBundle.loadString('$basePath/${composeFileName()}/$namespace.$extension', cache: false);
      _decodedMap[namespace] = jsonDecode(_decodedMap[namespace]);
    } catch (e) {
      MessagePrinter.debug('Error loading translation $e');
      await _loadTranslationFallback(namespace);
    }
  }

  Future<void> _loadTranslationFallback(String namespace) async {
    try {
      _decodedMap[namespace] = await loadFile("$fallbackFile/$namespace");
    } catch (e) {
      MessagePrinter.debug('Error loading translation fallback $e');
    }
  }
}