/// 支持

import 'package:flutter/material.dart';

import 'package:flutter_elui_plugin/elui.dart';

import 'package:bfban/utils/index.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

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
            onPressed: () {
              _urlUtil.opEnPage(context, "/network");
            },
            icon: const Icon(Icons.electrical_services),
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          EluiCellComponent(
            title: FlutterI18n.translate(context, "app.setting.support.guide"),
            theme: EluiCellTheme(
              titleColor: Theme.of(context).textTheme.subtitle1?.color,
              labelColor: Theme.of(context).textTheme.subtitle2?.color,
              linkColor: Theme.of(context).textTheme.subtitle1?.color,
              backgroundColor: Theme.of(context).cardTheme.color,
            ),
            islink: true,
            onTap: () => _opEnGuide(),
          ),
          const SizedBox(height: 10),
          EluiCellComponent(
            title: FlutterI18n.translate(context, "app.setting.support.feedbackTitle"),
            label: FlutterI18n.translate(context, "app.setting.support.feedbackDescription"),
            theme: EluiCellTheme(
              titleColor: Theme.of(context).textTheme.subtitle1?.color,
              labelColor: Theme.of(context).textTheme.subtitle2?.color,
              linkColor: Theme.of(context).textTheme.subtitle1?.color,
              backgroundColor: Theme.of(context).cardTheme.color,
            ),
            islink: true,
            onTap: () => UrlUtil().onPeUrl("https://jq.qq.com/?_wv=1027&k=kXr9z9FE"),
          ),
          EluiCellComponent(
            title: FlutterI18n.translate(context, "app.setting.support.githubTitle"),
            label: FlutterI18n.translate(context, "app.setting.support.githubDescription"),
            theme: EluiCellTheme(
              titleColor: Theme.of(context).textTheme.subtitle1?.color,
              labelColor: Theme.of(context).textTheme.subtitle2?.color,
              linkColor: Theme.of(context).textTheme.subtitle1?.color,
              backgroundColor: Theme.of(context).cardTheme.color,
            ),
            islink: true,
            onTap: () => _urlUtil.onPeUrl("https://github.com/BFBAN/bfban-app"),
          ),
          EluiCellComponent(
            title: FlutterI18n.translate(context, "app.setting.support.donateTitle"),
            label: FlutterI18n.translate(context, "app.setting.support.donateDescription"),
            theme: EluiCellTheme(
              titleColor: Theme.of(context).textTheme.subtitle1?.color,
              labelColor: Theme.of(context).textTheme.subtitle2?.color,
              linkColor: Theme.of(context).textTheme.subtitle1?.color,
              backgroundColor: Theme.of(context).cardTheme.color,
            ),
            islink: true,
            onTap: () => _urlUtil.onPeUrl("https://cabbagelol.net/%e6%8d%90%e5%8a%a9/"),
          ),
        ],
      ),
    );
  }
}
