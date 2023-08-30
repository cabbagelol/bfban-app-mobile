/// 支持

import 'package:flutter/material.dart';

import 'package:flutter_elui_plugin/elui.dart';

import 'package:bfban/utils/index.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({Key? key}) : super(key: key);

  @override
  _SupportPageState createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(FlutterI18n.translate(context, "app.setting.support.title")),
        actions: [
          IconButton(
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
              labelColor: Theme.of(context).textTheme.subtitle2?.color,
              linkColor: Theme.of(context).textTheme.titleMedium?.color,
              backgroundColor: Theme.of(context).cardTheme.color,
            ),
            islink: true,
            onTap: () => _opEnGuide(),
          ),
          const SizedBox(height: 10),
          EluiCellComponent(
            title: FlutterI18n.translate(context, "app.setting.support.githubTitle"),
            label: FlutterI18n.translate(context, "app.setting.support.githubDescription"),
            theme: EluiCellTheme(
              titleColor: Theme.of(context).textTheme.titleMedium?.color,
              labelColor: Theme.of(context).textTheme.subtitle2?.color,
              linkColor: Theme.of(context).textTheme.titleMedium?.color,
              backgroundColor: Theme.of(context).cardTheme.color,
            ),
            islink: true,
            onTap: () => _urlUtil.onPeUrl("https://github.com/BFBAN/bfban-app", mode: LaunchMode.externalApplication),
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
          // EluiCellComponent(
          //   title: FlutterI18n.translate(context, "app.setting.support.feedbackTitle"),
          //   label: FlutterI18n.translate(context, "app.setting.support.feedbackDescription"),
          //   theme: EluiCellTheme(
          //     titleColor: Theme.of(context).textTheme.subtitle1?.color,
          //     labelColor: Theme.of(context).textTheme.subtitle2?.color,
          //     linkColor: Theme.of(context).textTheme.subtitle1?.color,
          //     backgroundColor: Theme.of(context).cardTheme.color,
          //   ),
          //   islink: true,
          //   onTap: () => UrlUtil().onPeUrl("https://jq.qq.com/?_wv=1027&k=kXr9z9FE"),
          // ),
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
