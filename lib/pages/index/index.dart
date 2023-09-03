/// 功能：首页控制器

import 'dart:convert';
import 'dart:math';

import 'package:bfban/pages/index/players.dart';
import 'package:bfban/provider/chat_provider.dart';
import 'package:bfban/provider/userinfo_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/_message/index.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

import 'package:bfban/utils/index.dart';

import '../../constants/api.dart';
import '../../widgets/drawer.dart';
import '../../widgets/index/search_box.dart';
import '../profile/index.dart';
import 'footer_bar_panel.dart';
import 'search.dart';

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
  GlobalKey<PlayerListPageState>? playerListPage = GlobalKey<PlayerListPageState>();

  GlobalKey<DragContainerState>? _drawerWidget = GlobalKey<DragContainerState>();

  // 首页下标
  int _currentPageIndex = 0;

  // 首页Widget列表
  List<Widget> _listWidgetPage = [];

  DateTime? _lastPressedAt = DateTime(0); //上次点击时间

  List<dynamic> navs = [
    {
      "name": "home",
      "icon": const Icon(Icons.home_outlined, size: 30),
      "activeIcon": const Icon(Icons.home_sharp, size: 30),
    },
    {
      "name": "player_list",
      "icon": const Icon(Icons.view_list_outlined, size: 30),
      "activeIcon": const Icon(Icons.view_list, size: 30),
    },
    {
      "name": "profile",
      "icon": const Icon(Icons.person_outline, size: 30),
      "activeIcon": const Icon(Icons.person_sharp, size: 30),
    },
  ];

  num reportsCount = 0;

  double screenHeight = 0;

  double screenBarHeight = 26.0;

  @override
  void initState() {
    _onUserTokenExpired();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    setState(() {
      screenHeight = MediaQuery.of(context).size.height;
    });
  }

  /// [Response]
  /// 获取长度
  Future _getReportsCount() async {
    Response result = await Http.request(
      Config.httpHost["statistics"],
      parame: {"reports": true},
      method: Http.GET,
    );

    if (result.data["success"] == 1) {
      final d = result.data["data"];
      reportsCount = d["reports"];
    }

    return reportsCount;
  }

  /// [Event]
  /// 用户令牌失效触发器
  void _onUserTokenExpired() {
    eventUtil.on('user-token-expired', (arg) {
      UserInfoProvider().accountQuit(context);
    });
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

      _urlUtil.opEnPage(context, "/chat/list");
    };
  }

  /// [Event]
  /// 随便看看
  void _takeLook() async {
    if (reportsCount == 0) {
      await _getReportsCount();
    }

    int random = Random().nextInt(reportsCount as int);

    _urlUtil.opEnPage(context, "/player/dbId/$random");
  }

  /// [Event]
  /// 打开网络状态
  void _opEnNetwork() {
    _urlUtil.opEnPage(context, "/network");
  }

  /// [Event]
  /// 举报
  void _opEnReport() {
    String data = jsonEncode({
      "originName": "",
    });
    _urlUtil.opEnPage(context, '/report/$data');
  }

  @override
  Widget build(BuildContext context) {
    Widget titleWidget = Row(
      children: [
        // 消息
        Consumer<ChatProvider>(
          builder: (BuildContext context, data, Widget? child) {
            return SizedBox(
              width: 50,
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Consumer<UserInfoProvider>(
                    builder: (BuildContext context, userdata, Widget? child) {
                      return AnimatedOpacity(
                        opacity: userdata.isLogin ? 1 : .3,
                        duration: const Duration(seconds: 1),
                        child: IconButton(
                          icon: Icon(
                            Icons.chat,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          onPressed: _openMessage(),
                        ),
                      );
                    },
                  ),
                  Visibility(
                    visible: data.total != 0,
                    child: Positioned(
                      top: 2,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
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
          child: TitleSearchWidget(
            controller: TextEditingController(),
            theme: titleSearchTheme.black,
          ),
        ),
      ],
    );

    return WillPopScope(
      onWillPop: () async {
        if (_lastPressedAt == null || DateTime.now().difference(_lastPressedAt!) > const Duration(seconds: 1)) {
          _lastPressedAt = DateTime.now();

          EluiMessageComponent.warning(context)(
            child: Text(FlutterI18n.translate(context, "app.basic.app_exit")),
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

          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              if (constraints.maxWidth < 1024) {
                // move app
                return Scaffold(
                  extendBodyBehindAppBar: true,
                  appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    flexibleSpace: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomRight,
                          colors: ProviderUtil().ofTheme(context).currentThemeName == "default" ? [Colors.transparent, Colors.black54] : [Colors.transparent, Colors.black12],
                        ),
                      ),
                    ),
                    title: titleWidget,
                    actions: <Widget>[
                      Consumer<UserInfoProvider>(builder: (BuildContext context, UserInfoProvider data, Widget? child) {
                        return PopupMenuButton(
                          icon: Icon(
                            Icons.adaptive.more,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          offset: const Offset(0, 45),
                          onSelected: (value) {
                            switch (value) {
                              case 1:
                                _urlUtil.opEnPage(context, '/camera').then((value) {});
                                break;
                              case 2:
                                _takeLook();
                                break;
                              case 3:
                                _opEnNetwork();
                                break;
                              case 4:
                                _opEnReport();
                                break;
                            }
                          },
                          itemBuilder: (context) {
                            return [
                              PopupMenuItem(
                                value: 1,
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.camera,
                                      color: Theme.of(context).iconTheme.color,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(FlutterI18n.translate(context, "app.home.scancode")),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 2,
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.casino_outlined,
                                      color: Theme.of(context).iconTheme.color,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(FlutterI18n.translate(context, "app.home.takeLook")),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 4,
                                enabled: data.isLogin,
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add,
                                      color: Theme.of(context).iconTheme.color,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(FlutterI18n.translate(context, "report.title")),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                height: 10,
                                child: Divider(height: 1),
                              ),
                              PopupMenuItem(
                                value: 3,
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.language,
                                      color: Theme.of(context).iconTheme.color,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(FlutterI18n.translate(context, "app.networkDetection.title")),
                                  ],
                                ),
                              ),
                            ];
                          },
                        );
                      })
                    ],
                    elevation: 0,
                    titleSpacing: 0.0,
                    centerTitle: false,
                  ),
                  body: FlutterPluginDrawer(
                    body: SizedBox(
                      height: screenHeight,
                      child: IndexedStack(
                        index: _currentPageIndex,
                        children: _listWidgetPage,
                      ),
                    ),
                    dragContainer: DragContainer(
                      key: _drawerWidget,
                      drawer: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).bottomAppBarTheme.color,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).dividerTheme.color!,
                              spreadRadius: 1,
                              blurRadius: 0,
                            ),
                            BoxShadow(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              spreadRadius: .2,
                              blurRadius: 2,
                            ),
                          ],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        height: screenBarHeight,
                        child: OverscrollNotificationWidget(
                          child: Column(
                            children: <Widget>[
                              Container(
                                height: 6.0,
                                width: 45.0,
                                margin: const EdgeInsets.only(top: 10.0, bottom: 10),
                                decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 214, 215, 218),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5.0),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: screenHeight * 0.5 - screenBarHeight,
                                child: MediaQuery.removePadding(
                                  context: context,
                                  removeTop: true,
                                  child: const HomeButtomPanel(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      defaultShowHeight: screenBarHeight,
                      height: screenHeight * .5,
                    ),
                  ),
                  bottomNavigationBar: BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    showSelectedLabels: true,
                    showUnselectedLabels: true,
                    items: navs.map((nav) {
                      return BottomNavigationBarItem(
                        icon: nav!["icon"],
                        activeIcon: nav["activeIcon"],
                        label: FlutterI18n.translate(context, "${nav["name"]}.title"),
                      );
                    }).toList(),
                    currentIndex: _currentPageIndex,
                    onTap: (int index) => onTap(index),
                  ),
                );
              } else {
                // desktop
                return Scaffold(
                  appBar: AppBar(
                    title: titleWidget,
                    actions: <Widget>[
                      Consumer<UserInfoProvider>(builder: (BuildContext context, UserInfoProvider data, Widget? child) {
                        return PopupMenuButton(
                          icon: Icon(
                            Icons.adaptive.more,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          offset: const Offset(0, 45),
                          onSelected: (value) {
                            switch (value) {
                              case 1:
                                _urlUtil.opEnPage(context, '/camera').then((value) {});
                                break;
                              case 2:
                                _takeLook();
                                break;
                              case 3:
                                _opEnNetwork();
                                break;
                              case 4:
                                _opEnReport();
                                break;
                            }
                          },
                          itemBuilder: (context) {
                            return [
                              PopupMenuItem(
                                value: 1,
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.camera,
                                      color: Theme.of(context).iconTheme.color,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(FlutterI18n.translate(context, "app.home.scancode")),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 2,
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.casino_outlined,
                                      color: Theme.of(context).iconTheme.color,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(FlutterI18n.translate(context, "app.home.takeLook")),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 4,
                                enabled: data.isLogin,
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add,
                                      color: Theme.of(context).iconTheme.color,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(FlutterI18n.translate(context, "report.title")),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                height: 10,
                                child: Divider(height: 1),
                              ),
                              PopupMenuItem(
                                value: 3,
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.language,
                                      color: Theme.of(context).iconTheme.color,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(FlutterI18n.translate(context, "app.networkDetection.title")),
                                  ],
                                ),
                              ),
                            ];
                          },
                        );
                      })
                    ],
                    elevation: 0,
                    titleSpacing: 65,
                    centerTitle: false,
                  ),
                  body: Row(
                    children: [
                      NavigationRail(
                        onDestinationSelected: (value) {
                          setState(() {
                            _currentPageIndex = value;
                          });
                        },
                        labelType: NavigationRailLabelType.none,
                        backgroundColor: Theme.of(context).bottomAppBarTheme.color,
                        destinations: navs.map((nav) {
                          return NavigationRailDestination(
                            icon: nav!["icon"],
                            selectedIcon: nav!["activeIcon"],
                            label: Text(FlutterI18n.translate(
                              context,
                              "${nav["name"]}.title",
                            )),
                          );
                        }).toList(),
                        selectedIndex: _currentPageIndex,
                      ),
                      // VerticalDivider(
                      //   width: 1,
                      //   color: Theme.of(context).dividerTheme.color!.withOpacity(.05),
                      // ),
                      Expanded(
                        flex: 1,
                        child: IndexedStack(
                          index: _currentPageIndex,
                          children: _listWidgetPage,
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
