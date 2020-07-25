/// 功能：首页控制器
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:bfban/constants/index.dart';
import 'package:bfban/utils/index.dart';
import 'package:bfban/widgets/index.dart';

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

    Storage.get('com.bfban.token').then((value) => {
          Http.setToken(value),
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
                        "name": "首页",
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
                        "name": "新闻",
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
                        "name": "个人中心",
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
                    }).toList()
                    ),
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
