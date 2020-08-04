/// 支持

import 'package:flutter/material.dart';

import 'package:flutter_plugin_elui/elui.dart';

import 'package:bfban/utils/index.dart';

class SupportPage extends StatefulWidget {
  @override
  _SupportPageState createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  UrlUtil _urlUtil = new UrlUtil();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff111b2b),
      extendBodyBehindAppBar: true,
      appBar: EluiHeadComponent(
        context: context,
        backgroundColor: Color(0xff364e80),
        title: "",
        titleStyle: TextStyle(
          color: Colors.white,
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          EluiCellComponent(
            title: "Github",
            label: "开源地址",
            theme: EluiCellTheme(
              backgroundColor: Color.fromRGBO(255, 255, 255, .07),
            ),
            islink: true,
            onTap: () => _urlUtil.onPeUrl("https://github.com/BFBAN/bfban-app"),
          ),
          EluiCellComponent(
            title: "捐赠",
            label: "向BFBAN APP开发者捐赠人民币",
            theme: EluiCellTheme(
              backgroundColor: Color.fromRGBO(255, 255, 255, .07),
            ),
            islink: true,
            onTap: () => _urlUtil.onPeUrl("https://cabbagelol.net/%e6%8d%90%e5%8a%a9/"),
          ),
          SizedBox(
            height: 20,
          ),
          EluiCellComponent(
            title: "内部",
            theme: EluiCellTheme(
              backgroundColor: Colors.transparent,
              titleColor: Colors.white38,
            ),
          ),
          EluiCellComponent(
            title: "BFBAN WEB 接口",
            label: "app.bfban.com / bf.bamket.com",
            theme: EluiCellTheme(
              backgroundColor: Color.fromRGBO(255, 255, 255, .07),
            ),
          ),
          EluiCellComponent(
            title: "第三方 (我们无法管控的数据)",
            theme: EluiCellTheme(
              backgroundColor: Colors.transparent,
              titleColor: Colors.white38,
            ),
          ),
          EluiCellComponent(
            title: "TRN",
            label: "battlefieldtracker.com",
            theme: EluiCellTheme(
              backgroundColor: Color.fromRGBO(255, 255, 255, .07),
            ),
          ),
          EluiCellComponent(
            title: "@Lv_Aini",
            label: "record.huiyi.sc.cn",
            theme: EluiCellTheme(
              backgroundColor: Color.fromRGBO(255, 255, 255, .07),
            ),
          ),
          EluiCellComponent(
            title: "@Lv_Ainio",
            label: "api.tracker.gg",
            theme: EluiCellTheme(
              backgroundColor: Color.fromRGBO(255, 255, 255, .07),
            ),
          ),
        ],
      ),
    );
  }
}
