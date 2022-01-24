/// 支持

import 'package:flutter/material.dart';

import 'package:flutter_elui_plugin/elui.dart';

import 'package:bfban/utils/index.dart';

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
        title: const Text("支援"),
      ),
      body: ListView(
        children: <Widget>[
          EluiCellComponent(
            title: "引导",
            islink: true,
            onTap: () => _opEnGuide(),
          ),
          EluiCellComponent(
            title: "反馈群 (612949946)",
            label: "和作者更加接近呢",
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
            title: "Github",
            label: "开源地址",
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
            title: "捐赠",
            label: "向BFBAN APP开发者捐赠人民币",
            theme: EluiCellTheme(
              titleColor: Theme.of(context).textTheme.subtitle1?.color,
              labelColor: Theme.of(context).textTheme.subtitle2?.color,
              linkColor: Theme.of(context).textTheme.subtitle1?.color,
              backgroundColor: Theme.of(context).cardTheme.color,
            ),
            islink: true,
            onTap: () => _urlUtil.onPeUrl("https://cabbagelol.net/%e6%8d%90%e5%8a%a9/"),
          ),
          SizedBox(
            height: 20,
          ),
          EluiCellComponent(
            title: "内部",
          ),
          EluiCellComponent(
            title: "BFBAN WEB 接口",
            label: "app.bfban.com / bf.bamket.com",
            theme: EluiCellTheme(
              titleColor: Theme.of(context).textTheme.subtitle1?.color,
              labelColor: Theme.of(context).textTheme.subtitle2?.color,
              linkColor: Theme.of(context).textTheme.subtitle1?.color,
              backgroundColor: Theme.of(context).cardTheme.color,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          EluiCellComponent(
            title: "第三方 (我们无法管控的数据)",
            theme: EluiCellTheme(
              titleColor: Theme.of(context).textTheme.subtitle1?.color,
              labelColor: Theme.of(context).textTheme.subtitle2?.color,
              linkColor: Theme.of(context).textTheme.subtitle1?.color,
              backgroundColor: Theme.of(context).cardTheme.color,
            ),
          ),
          EluiCellComponent(
            title: "TRN",
            label: "battlefieldtracker.com",
            theme: EluiCellTheme(
              titleColor: Theme.of(context).textTheme.subtitle1?.color,
              labelColor: Theme.of(context).textTheme.subtitle2?.color,
              linkColor: Theme.of(context).textTheme.subtitle1?.color,
              backgroundColor: Theme.of(context).cardTheme.color,
            ),
          ),
          EluiCellComponent(
            title: "@Lv_Aini",
            label: "record.huiyi.sc.cn",
            theme: EluiCellTheme(
              titleColor: Theme.of(context).textTheme.subtitle1?.color,
              labelColor: Theme.of(context).textTheme.subtitle2?.color,
              linkColor: Theme.of(context).textTheme.subtitle1?.color,
              backgroundColor: Theme.of(context).cardTheme.color,
            ),
          ),
          EluiCellComponent(
            title: "@Lv_Ainio",
            label: "api.tracker.gg",
            theme: EluiCellTheme(
              titleColor: Theme.of(context).textTheme.subtitle1?.color,
              labelColor: Theme.of(context).textTheme.subtitle2?.color,
              linkColor: Theme.of(context).textTheme.subtitle1?.color,
              backgroundColor: Theme.of(context).cardTheme.color,
            ),
          ),
        ],
      ),
    );
  }
}
