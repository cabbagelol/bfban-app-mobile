/// 功能：首页控制器

import 'dart:convert';
import 'dart:ui' as ui;

import 'package:bfban/constants/theme.dart';
import 'package:bfban/pages/index/community.dart';
import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:provider/provider.dart';
import 'package:flutter_plugin_elui/_message/index.dart';

import 'package:bfban/constants/index.dart';
import 'package:bfban/utils/index.dart';
import 'package:bfban/router/router.dart';

import 'home.dart';
import 'news.dart';
import 'usercenter.dart';
import 'community.dart';

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

    this._onGuide();
    this._onReady();
  }

  void _onReady() async {
    Map token = jsonDecode(await Storage.get('com.bfban.token') ?? '{}');

    print(token);

    /// 校验TOKEN
    /// 时间7日内该TOken生效并保留，否则重启登录
    if (token.isEmpty) {
      return;
    }

    if (DateTime.fromMicrosecondsSinceEpoch(token["time"]).add(Duration(days: 7)).millisecondsSinceEpoch >
        new DateTime.now().millisecondsSinceEpoch) {
      EluiMessageComponent.warning(context)(
        child: Text("\u767b\u5f55\u5df2\u8fc7\u671f\uff0c\u8bf7\u91cd\u65b0\u767b\u5f55"),
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
  void _onGuide() async {
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
    Map theme = THEMELIST[context.watch<AppInfoProvider>().themeColor];
    ScreenUtil.instance = ScreenUtil(width: Klength.designWidth)..init(context);
    List<Widget> widgets = [HomePage(), communityPage(), newsPage(), usercenter()];

    return Column(
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
            theme: theme,
            items: [
              {
                "name": "\u9996\u9875",
                "icon": Icon(
                  Icons.home,
                  color: theme['index_index_tabs']['color'],
                ),
                "icon_s": Icon(
                  Icons.home,
                  color: theme['index_index_tabs']['actviveColor'],
                ),
              },
              {
                "name": "\u793e\u533a",
                "icon": Icon(
                  Icons.comment,
                  color: theme['index_index_tabs']['color'],
                ),
                "icon_s": Icon(
                  Icons.comment,
                  color: theme['index_index_tabs']['actviveColor'],
                ),
              },
              {
                "name": "\u65b0\u95fb",
                "icon": Icon(
                  Icons.featured_video,
                  color: theme['index_index_tabs']['color'],
                ),
                "icon_s": Icon(
                  Icons.featured_video,
                  color: theme['index_index_tabs']['actviveColor'],
                ),
              },
              {
                "name": "\u4e2a\u4eba\u4e2d\u5fc3",
                "icon": Icon(
                  Icons.portrait,
                  color: theme['index_index_tabs']['color'],
                ),
                "icon_s": Icon(
                  Icons.portrait,
                  color: theme['index_index_tabs']['actviveColor'],
                ),
              },
            ].map((e) {
              return BottomAppBarItemModal(
                e,
                e["name"],
              );
            }).toList()),
      ],
    );
  }
}

class BottomAppBarItemModal {
  final Map iconData;
  final String text;

  BottomAppBarItemModal(
    this.iconData,
    this.text,
  );
}

class KKBottomAppBar extends StatefulWidget {
  final List<BottomAppBarItemModal> items;
  final ValueChanged<int> onTabSeleted;
  final theme;

  KKBottomAppBar({
    this.items,
    this.onTabSeleted,
    this.theme,
  }) : super();

  @override
  BottomAppBarState createState() => BottomAppBarState();
}

class BottomAppBarState extends State<KKBottomAppBar> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    int l = widget.items.length;
    double bottom = ScreenUtil.bottomBarHeight; //IPhone 底部

    List<Widget> listWidgets = List.generate(l, (index) {
      BottomAppBarItemModal i = widget.items[index];

      return Expanded(
        flex: 1,
        child: FlatButton(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              index == currentIndex ? i.iconData["icon_s"] : i.iconData["icon"],
              Text(
                i.text,
                style: TextStyle(color: index == currentIndex ? widget.theme['index_index_tabs']['actviveColor'] : widget.theme['index_index_tabs']['color'], fontSize: 12),
              ),
            ],
          ),
          onPressed: () {
            setState(() => this.currentIndex = index);
            widget.onTabSeleted(index);
          },
        ),
      );
    });

    return Container(
      height: Klength.bottomBarHeight,
      color: widget.theme['index_index_tabs']['backgroundColor'],
      alignment: Alignment.center,
      margin: EdgeInsets.only(bottom: bottom),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: listWidgets,
      ),
    );
  }
}
