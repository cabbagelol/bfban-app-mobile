/// 功能：首页控制器

import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';

import 'package:bfban/constants/index.dart';
import 'package:bfban/utils/index.dart';
import 'package:bfban/widgets/index.dart';
import 'package:bfban/router/router.dart';
import 'package:flutter_plugin_elui/_message/index.dart';

import 'home.dart';
import 'news.dart';
import 'usercenter.dart';


class IndexPage extends StatefulWidget {
  IndexPage({
    Key key,
  }) : super(key: key);

  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  PageController pageController;

  int currentPage = 0;

  @override
  void initState() {
    super.initState();

    this.onGuide();

    this._onReady();
  }

  void _onReady () async {
    Map token = jsonDecode(await Storage.get('com.bfban.token') ?? '{}');


    /// 校验TOKEN
    /// 时间7日内该TOken生效并保留，否则重启登录
    if (DateTime.parse(token["time"]).add(Duration(days: 7)).millisecondsSinceEpoch > new DateTime.now().millisecondsSinceEpoch) {
      EluiMessageComponent.warning(context)(
        child: Text("登录已过期，请重新登录"),
      );

      Storage.remove('com.bfban.token');

      Routes.router.navigateTo(
        context,
        '/login',
        transition: TransitionType.cupertino,
      );
    } else {
      Http.setToken(token["value"]);
    }
  }

  /// 引导器
  void onGuide() async {
    Storage.get('com.bfban.guide').then((value) {
      if (value == null) {
        Routes.router.navigateTo(
          context,
          '/guide',
          transition: TransitionType.materialFullScreenDialog,
        );
      }
    });
  }

  /// 首页控制器序列
  void onTap(int index) {
    setState(() {
      this.currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: Klength.designWidth)..init(context);

    List<Widget> widgets = [HomePage(), newsPage(), usercenter()];

    return Scaffold(
      backgroundColor: Color(0xff111b2b),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Opacity(
            opacity: 0.5,
            child: Image.asset(
              "assets/images/bk-companion-1.jpg",
              fit: BoxFit.cover,
            ),
          ),
          BackdropFilter(
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: IndexedStack(
                    children: widgets,
                    index: currentPage,
                  ),
                ),
                KKBottomAppBar(
                    onTabSeleted: onTap,
                    actviveColor: Colors.yellow,
                    color: Colors.white,
                    items: [
                      {
                        "name": "\u9996\u9875",
                        "icon": Icon(
                          Icons.home,
                          color: Colors.white,
                        ),
                        "icon_s": Icon(
                          Icons.home,
                          color: Colors.yellow,
                        ),
                      },
                      {
                        "name": "\u65b0\u95fb",
                        "icon": Icon(
                          Icons.featured_video,
                          color: Colors.white,
                        ),
                        "icon_s": Icon(
                          Icons.featured_video,
                          color: Colors.yellow,
                        ),
                      },
                      {
                        "name": "\u4e2a\u4eba\u4e2d\u5fc3",
                        "icon": Icon(
                          Icons.portrait,
                          color: Colors.white,
                        ),
                        "icon_s": Icon(
                          Icons.portrait,
                          color: Colors.yellow,
                        ),
                      },
                    ].map((e) {
                      return BottomAppBarItemModal(
                        e,
                        e["name"],
                      );
                    }).toList()),
              ],
            ),
            filter: ui.ImageFilter.blur(
              sigmaX: 0.0,
              sigmaY: 0.0,
            ),
          ),
        ],
      ),
    );
  }
}
