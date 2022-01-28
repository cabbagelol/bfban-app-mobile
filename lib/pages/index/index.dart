/// 功能：首页控制器

import 'dart:convert';

import 'package:bfban/pages/index/players.dart';
import 'package:bfban/provider/message_provider.dart';
import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:provider/provider.dart';

import 'package:bfban/utils/index.dart';

import '../../widgets/index/search.dart';
import '../my/my.dart';
import 'home.dart';
import 'players.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({
    Key? key,
  }) : super(key: key);

  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  final UrlUtil _urlUtil = UrlUtil();

  // 玩家列表
  GlobalKey<PlayerListPageState>? playerListPage = GlobalKey();

  // 首页下标
  int _currentPageIndex = 0;

  // 首页Wiget列表
  List<Widget> _listWidgetPage = [];

  @override
  void initState() {
    super.initState();
    _onReady();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// [Event]
  /// 初始用户数据
  void initUserData() async {
    dynamic user = await Storage().get("com.bfban.login");

    if (user != null) {
      // 数据 更新到状态机内
      ProviderUtil().ofUser(context).setData(jsonDecode(user));

      // 消息 更新状态机
      ProviderUtil().ofMessage(context).onUpDate();
    }

    // 包 更新状态机
    ProviderUtil().ofPackage(context).init();

    // 主题初始
    ProviderUtil().ofTheme(context).init();

    // 配置初始
    ProviderUtil().ofApp(context).conf!.init();
  }

  /// [Event]
  /// 初始页面数据
  void _onReady() async {
    _onGuide();
    _onToken();
    initUserData();
  }

  /// [Event]
  /// 处理token
  void _onToken() async {
    dynamic userinfo = jsonDecode(await Storage().get('com.bfban.login') ?? '{}');
    String token = userinfo["token"];

    // /// =============================
    // /// 校验TOKEN
    // /// 时间7日内该TOken生效并保留，否则重启登录
    // if (token.isEmpty) {
    //   return;
    // }
    //
    // if (DateTime.fromMicrosecondsSinceEpoch(token["time"]).add(const Duration(days: 7)).millisecondsSinceEpoch > DateTime.now().millisecondsSinceEpoch) {
    //   EluiMessageComponent.warning(context)(
    //     child: const Text("\u767b\u5f55\u5df2\u8fc7\u671f\uff0c\u8bf7\u91cd\u65b0\u767b\u5f55"),
    //   );
    //
    //   Storage().remove('com.bfban.token');
    //
    //   Routes.router!.navigateTo(
    //     context,
    //     '/login',
    //     transition: TransitionType.cupertino,
    //   );
    // } else {
    //   Http.setToken(token["value"]);
    // }

    Http.setToken(token);
  }

  /// [Event]
  /// 引导
  void _onGuide() async {
    Storage storage = Storage();
    String guideName = "com.bfban.guide";
    dynamic guide = await storage.get(guideName);

    if (guide == null) {
      _urlUtil.opEnPage(context, "/guide", transition: TransitionType.fadeIn).then((value) async {
        await storage.set(guideName, value: 1);
      });
    }
  }

  /// [Event]
  /// 首页控制器序列
  void onTap(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  /// [Event]
  /// 打开消息中心
  dynamic _openMessage() {
    return () {
      // 检查登录状态
      if (!ProviderUtil().ofUser(context).checkLogin()) return;

      _urlUtil.opEnPage(context, "/message/list");
    };
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppInfoProvider>(
      builder: (context, appInfo, child) {
        _listWidgetPage = [
          const SearchPage(),
          PlayerListPage(key: playerListPage),
          const UserCenterPage(),
        ];

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomRight,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
            ),
            title: Row(
              children: [
                // 消息
                Consumer<MessageProvider>(
                  builder: (BuildContext context, data, Widget? child) {
                    return SizedBox(
                      width: 50,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: <Widget>[
                          IconButton(
                            icon: const Icon(Icons.add_alert),
                            onPressed: _openMessage(),
                          ),
                          Visibility(
                            child: Positioned(
                              top: 2,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 15,
                                  minHeight: 15,
                                ),
                                child: Text(
                                  data.total.toString(), //通知数量
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            visible: true,
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // 搜索框
                Expanded(
                  flex: 1,
                  child: titleSearch(
                    controller: TextEditingController(),
                    theme: titleSearchTheme.black,
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              PopupMenuButton(
                onSelected: (value) {
                  switch (value) {
                    case 1:
                      _urlUtil.opEnPage(context, '/camera').then((value) {});
                      break;
                  }
                },
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      value: 1,
                      child: Wrap(
                        children: const [
                          Icon(Icons.qr_code),
                          SizedBox(
                            width: 10,
                          ),
                          Text("扫一扫"),
                        ],
                      ),
                    ),
                  ];
                },
              ),
            ],
            elevation: 0,
            titleSpacing: 0.0,
            centerTitle: false,
          ),
          body: IndexedStack(
            children: _listWidgetPage,
            index: _currentPageIndex,
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            items: [
              {
                "index": 0,
                "name": "\u9996\u9875",
                "icon": const Icon(Icons.home_rounded, size: 30),
              },
              {
                "index": 1,
                "name": "列表",
                "count": (playerListPage?.currentState?.playersStatus?.list!.length ?? 0).toString(),
                "icon": const Icon(Icons.view_list_sharp, size: 30),
              },
              {
                "index": 2,
                "name": "我",
                "icon": const Icon(Icons.person, size: 30),
              },
            ].map((Map? navitem) {
              return BottomNavigationBarItem(
                icon: navitem!["icon"],
                label: navitem["name"],
              );
            }).toList(),
            currentIndex: _currentPageIndex,
            onTap: (int index) => onTap(index),
          ),
        );
      },
    );
  }
}
