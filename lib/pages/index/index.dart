/// 功能：首页控制器
import 'dart:async';
import 'dart:convert';

import 'package:bfban/pages/index/community.dart';
import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter_plugin_elui/_message/index.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';

import 'package:bfban/utils/index.dart';
import 'package:bfban/router/router.dart';

import 'home.dart';
import 'news.dart';
import 'usercenter.dart';
import 'community.dart';
import '../guide/guide.dart';

class IndexPage extends StatefulWidget {
  IndexPage({
    Key key,
  }) : super(key: key);

  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  StreamSubscription _sub;

  Future futureBuilder;

  int _currentIndex = 0;

  List<Widget> list = [];

  @override
  void initState() {
    super.initState();

    this._onReady();
    this._onEnUniLinks();
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  void _onReady() async {
    Map token = jsonDecode(await Storage.get('com.bfban.token') ?? '{}');

    /// =============================
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

  /// 外链初始
  Future<Null> _onEnUniLinks() async {
    _sub = getLinksStream().listen((String link) {
      print("link" + link);
    }, onError: (err) {});
  }

  /// 首页控制器序列
  void onTap(int index) {
    setState(() {
      this._currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context)   {
    _getStorageGuide () async {
      return true;
      // return await Storage.get("com.bfban.guide");
    }

    return Consumer<AppInfoProvider>(
      builder: (context, appInfo, child) {
        num _guideState = Provider.of<AppInfoProvider>(context, listen: false).guideState;

        if (_getStorageGuide() != null) {
          _guideState = 1;
        }

        if (_guideState == 1) {
          list = [HomePage(), communityPage(), newsPage(), usercenter()];
        }

        return _guideState == 0 ? guidePage() : Scaffold(
          body: IndexedStack(
            children: list,
            index: _currentIndex,
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            items: [
              {
                "name": "\u9996\u9875",
                "icon": Icon(Icons.home),
              },
              {
                "name": "\u793e\u533a",
                "icon": Icon(Icons.comment),
              },
              {
                "name": "\u65b0\u95fb",
                "icon": Icon(Icons.featured_video),
              },
              {
                "name": "\u4e2a\u4eba\u4e2d\u5fc3",
                "icon": Icon(Icons.portrait),
              },
            ].map((e) {
              return BottomNavigationBarItem(
                icon: e["icon"],
                title: Text(e["name"]),
              );
            }).toList(),
            currentIndex: _currentIndex,
            onTap: (int index) => onTap(index),
          ),
        );
      },
    );
  }
}
