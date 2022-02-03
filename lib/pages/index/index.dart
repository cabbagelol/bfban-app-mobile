/// 功能：首页控制器

import 'package:bfban/pages/index/players.dart';
import 'package:bfban/provider/message_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/_message/index.dart';
import 'package:flutter_translate/flutter_translate.dart';
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
  int _currentPageIndex = 1;

  // 首页Wiget列表
  List<Widget> _listWidgetPage = [];

  DateTime? _lastPressedAt = DateTime(0); //上次点击时间

  @override
  void dispose() {
    super.dispose();
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
    return WillPopScope(
      onWillPop: () async {
        if (_lastPressedAt == null || DateTime.now().difference(_lastPressedAt!) > const Duration(seconds: 1)) {
          _lastPressedAt = DateTime.now();

          EluiMessageComponent.warning(context)(
            child: const Text("再次点击,退出程序"),
          );
          return false;
        }
        return true;
      },
      child: Consumer<AppInfoProvider>(
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
                            AnimatedOpacity(
                              opacity: data.total == 0 ? .3 : 1,
                              duration: Duration(seconds: 1),
                              child: IconButton(
                                icon: const Icon(Icons.add_alert),
                                onPressed: _openMessage(),
                              ),
                            ),
                            Visibility(
                              visible: data.total != 0,
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
                  "name": "home",
                  "icon": const Icon(Icons.home_rounded, size: 30),
                },
                {
                  "index": 1,
                  "name": "player",
                  "count": (playerListPage?.currentState?.playersStatus?.list!.length ?? 0).toString(),
                  "icon": const Icon(Icons.view_list_sharp, size: 30),
                },
                {
                  "index": 2,
                  "name": "my",
                  "icon": const Icon(Icons.person, size: 30),
                },
              ].map((Map? navitem) {
                return BottomNavigationBarItem(
                  icon: navitem!["icon"],
                  label: translate("${navitem["name"]}.title"),
                );
              }).toList(),
              currentIndex: _currentPageIndex,
              onTap: (int index) => onTap(index),
            ),
          );
        },
      ),
    );
  }
}
