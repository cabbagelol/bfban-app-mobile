import 'package:flutter/material.dart';

class AppConfig extends InheritedWidget {
  final String appName;
  final bool debug;
  final String flavorName;
  final String apiBaseUrl;

  const AppConfig({
    super.key,
    this.debug = false,
    required this.appName,
    required this.flavorName,
    required this.apiBaseUrl,
    required super.child,
  });

  static AppConfig? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppConfig>();
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}
