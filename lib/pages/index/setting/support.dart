/// 支持
library;

import 'package:bfban/constants/api.dart';
import 'package:flutter/material.dart';

import 'package:flutter_elui_plugin/elui.dart';

import 'package:bfban/utils/index.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  SupportPageState createState() => SupportPageState();
}

class SupportPageState extends State<SupportPage> {
  final UrlUtil _urlUtil = UrlUtil();

  @override
  void initState() {
    super.initState();
  }

  /// [Event]
  /// 打开引导
  void _opEnGuide() {
    _urlUtil.opEnPage(context, '/guide');
  }

  /// [Event]
  /// 打开网络状态
  void _opEnNetwork() {
    _urlUtil.opEnPage(context, "/network");
  }

  /// [Event]
  /// 日志
  void _opEnLogs() {
    _urlUtil.opEnPage(context, "/profile/logs");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "app.setting.support.title")),
        actions: [
          IconButton(
            padding: const EdgeInsets.all(16),
            onPressed: () => _opEnNetwork(),
            icon: const Icon(Icons.electrical_services),
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          EluiCellComponent(
            title: FlutterI18n.translate(context, "app.setting.support.guide"),
            theme: EluiCellTheme(
              titleColor: Theme.of(context).textTheme.titleMedium?.color,
              labelColor: Theme.of(context).textTheme.labelLarge?.color,
              linkColor: Theme.of(context).textTheme.titleMedium?.color,
              backgroundColor: Theme.of(context).cardTheme.color,
            ),
            islink: true,
            onTap: () => _opEnGuide(),
          ),
          EluiCellComponent(
            title: FlutterI18n.translate(context, "app.setting.support.logTitle"),
            label: FlutterI18n.translate(context, "app.setting.support.logDescription"),
            theme: EluiCellTheme(
              titleColor: Theme.of(context).textTheme.titleMedium?.color,
              labelColor: Theme.of(context).textTheme.labelLarge?.color,
              linkColor: Theme.of(context).textTheme.titleMedium?.color,
              backgroundColor: Theme.of(context).cardTheme.color,
            ),
            islink: true,
            onTap: () => _opEnLogs(),
          ),
          const SizedBox(height: 10),
          EluiCellComponent(
            title: FlutterI18n.translate(context, "app.setting.support.githubTitle"),
            label: FlutterI18n.translate(context, "app.setting.support.githubDescription"),
            theme: EluiCellTheme(
              titleColor: Theme.of(context).textTheme.titleMedium?.color,
              labelColor: Theme.of(context).textTheme.displayMedium?.color,
              linkColor: Theme.of(context).textTheme.titleMedium?.color,
              backgroundColor: Theme.of(context).cardTheme.color,
            ),
            islink: true,
            onTap: () => _urlUtil.onPeUrl("${Config.apis["web_github"]!.url}/cabbagelol/bfban-app-mobile", mode: LaunchMode.externalApplication),
          ),
          EluiCellComponent(
            title: FlutterI18n.translate(context, "app.setting.cell.website.title"),
            label: "${FlutterI18n.translate(context, "app.setting.cell.website.describe")}: ${Config.apiHost["web_site"]!.url}",
            theme: EluiCellTheme(
              titleColor: Theme.of(context).textTheme.titleMedium?.color,
              labelColor: Theme.of(context).textTheme.displayMedium?.color,
              linkColor: Theme.of(context).textTheme.titleMedium?.color,
              backgroundColor: Theme.of(context).cardTheme.color,
            ),
            islink: true,
            onTap: () => _urlUtil.onPeUrl(
              Config.apiHost["web_site"]!.url,
              mode: LaunchMode.externalApplication,
            ),
          ),
          EluiCellComponent(
            title: "Email",
            label: "app@bfban.com",
            theme: EluiCellTheme(
              titleColor: Theme.of(context).textTheme.titleMedium?.color,
              labelColor: Theme.of(context).textTheme.displayMedium?.color,
              linkColor: Theme.of(context).textTheme.titleMedium?.color,
              backgroundColor: Theme.of(context).cardTheme.color,
            ),
            islink: true,
            onTap: () => _urlUtil.onPeUrl("mailto:app@bfban.com", mode: LaunchMode.externalApplication),
          ),
          EluiCellComponent(
            title: FlutterI18n.translate(context, "app.setting.support.licenseTitle"),
            label: FlutterI18n.translate(context, "app.setting.support.licenseDescription"),
            theme: EluiCellTheme(
              titleColor: Theme.of(context).textTheme.titleMedium?.color,
              labelColor: Theme.of(context).textTheme.displayMedium?.color,
              linkColor: Theme.of(context).textTheme.titleMedium?.color,
              backgroundColor: Theme.of(context).cardTheme.color,
            ),
            islink: true,
            onTap: () => UrlUtil().opEnPage(context, "/license"),
          ),
          EluiCellComponent(
            title: FlutterI18n.translate(context, "app.setting.support.appDocumentationTitle"),
            label: FlutterI18n.translate(context, "app.setting.support.appDocumentationDescription"),
            theme: EluiCellTheme(
              titleColor: Theme.of(context).textTheme.titleMedium?.color,
              labelColor: Theme.of(context).textTheme.displayMedium?.color,
              linkColor: Theme.of(context).textTheme.titleMedium?.color,
              backgroundColor: Theme.of(context).cardTheme.color,
            ),
            islink: true,
            onTap: () => _urlUtil.onPeUrl("https://cabbagelol.github.io/bfban-app-mobile-docs"),
          ),
        ],
      ),
    );
  }
}
