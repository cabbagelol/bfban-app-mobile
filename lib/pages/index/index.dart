/// 功能：首页控制器
library;

import 'dart:convert';
import 'dart:math';

import 'package:bfban/pages/index/players.dart';
import 'package:bfban/provider/chat_provider.dart';
import 'package:bfban/provider/package_provider.dart';
import 'package:bfban/provider/userinfo_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_elui_plugin/_message/index.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import 'package:bfban/utils/index.dart';

import '../../constants/api.dart';
import '../../widgets/drawer.dart';
import '../../widgets/red_dot.dart';
import 'user_center.dart';
import 'home_footer_bar_panel.dart';
import 'home.dart';

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

class IndexPage extends StatefulWidget {
  const IndexPage({
    super.key,
  });

  @override
  IndexPageState createState() => IndexPageState();
}

class IndexPageState extends State<IndexPage> with WidgetsBindingObserver {
  final UrlUtil _urlUtil = UrlUtil();

  final ProviderUtil _providerUtil = ProviderUtil();

  // 玩家列表
  final GlobalKey<PlayerListPageState> _playerListPage = GlobalKey<PlayerListPageState>();

  final GlobalKey<DragContainerState> _drawerWidget = GlobalKey<DragContainerState>();

  final StorageAccount _storageAccount = StorageAccount();

  // 首页下标
  int _currentPageIndex = 0;

  // 首页Widget列表
  List<Widget> _listWidgetPage = [];

  DateTime? _lastPressedAt = DateTime(0); //上次点击时间

  num reportsCount = 1;

  double screenHeight = 0;

  double screenBarHeight = 26.0;

  @override
  void initState() {
    _listWidgetPage = [
      const HomePage(),
      PlayerListPage(key: _playerListPage),
      const UserCenterPage(),
    ];
    _onNavInit();
    _onUserTokenExpired();

    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void deactivate() {
    _onNotNetwork();
    super.deactivate();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    if (state case AppLifecycleState.resumed) {
      _providerUtil.ofChat(context).getLocalMessage();
    }
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
  /// 初始导航位置
  void _onNavInit() async {
    if (!mounted) return;

    int localNavIndex = await _storageAccount.getConfiguration("userHomeNavPageIndex", 1);
    if (localNavIndex != _currentPageIndex) {
      _changePageIndex(localNavIndex);
    }
  }

  void _changePageIndex(int? index) {
    if (index == null || _playerListPage.currentState == null) return;

    setState(() {
      _currentPageIndex = index;
    });

    // 更新内部
    if (!_playerListPage.currentState!.mounted) return;
    _playerListPage.currentState!.setState(() {
      _playerListPage.currentState!.homePageIndex = index;
    });
  }

  /// [Event]
  /// 用户令牌失效触发器
  void _onUserTokenExpired() {
    eventUtil.on('user-token-expired', (arg) {
      UserInfoProvider().accountQuit(context);
    });
  }

  /// [Event]
  /// 网络失效触发器
  void _onNotNetwork() {
    eventUtil.on("not-network", (arg) {
      if (!mounted) return;
      Future.delayed(const Duration(seconds: 1), () {
        _urlUtil.opEnPage2("/notnetwork");
      });
    });
  }

  /// [Event]
  /// 首页控制器序列
  void _onHomePageIndexTap(int index) {
    if (_currentPageIndex == index) return;
    _changePageIndex(index);
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
    showCupertinoModalPopup<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: false,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(.9),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 160),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                child: LoadingAnimationWidget.beat(
                  size: 50,
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
              ),
            ),
          ),
        );
      },
    );

    if (reportsCount == 1) {
      await _getReportsCount().onError((e, _) => Navigator.pop(context));
    }

    int random = Random().nextInt(reportsCount as int);

    if (!mounted) return;
    Navigator.pop(context);
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

  /// [Event]
  /// 举报
  void _opEnVersion() {
    _urlUtil.opEnPage(context, "/profile/version/info");
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (status, data) {
        // 在这里处理返回事件
        if (_lastPressedAt == null || DateTime.now().difference(_lastPressedAt!) >= const Duration(seconds: 1)) {
          _lastPressedAt = DateTime.now();

          EluiMessageComponent.warning(context)(child: Text(FlutterI18n.translate(context, "app.basic.app_exit")));

          return;
        }

        SystemNavigator.pop();
        return;
      },
      child: Consumer<AppInfoProvider>(
        builder: (context, appInfo, child) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              automaticallyImplyLeading: false,
              centerTitle: true,
              leading: Consumer2<ChatProvider, UserInfoProvider>(
                builder: (BuildContext context, chatData, userData, Widget? child) {
                  return Stack(
                    fit: StackFit.passthrough,
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      AnimatedOpacity(
                        opacity: userData.isLogin ? 1 : .3,
                        duration: const Duration(seconds: 1),
                        child: IconButton(
                          icon: const Icon(Icons.chat_bubble),
                          onPressed: _openMessage(),
                        ),
                      ),
                      Visibility(
                        visible: chatData.total != 0,
                        child: Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: Theme.of(context).appBarTheme.iconTheme!.color!, width: 1.4),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 15,
                              minHeight: 15,
                            ),
                            child: Text(
                              chatData.total.toString(), //通知数量
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: FontSize.small.value,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              actions: <Widget>[
                IconButton(
                  padding: const EdgeInsets.all(16),
                  onPressed: () {
                    UrlUtil().opEnPage(context, '/search/${jsonEncode({"text": ''})}');
                  },
                  icon: const Icon(Icons.search),
                ),
                Consumer2<UserInfoProvider, PackageProvider>(builder: (BuildContext context, UserInfoProvider userData, PackageProvider packageData, Widget? child) {
                  return PopupMenuButton(
                    padding: const EdgeInsets.all(16),
                    icon: RedDotWidget(
                      show: packageData.isNewVersion,
                      child: Icon(
                        Icons.adaptive.more,
                        color: Theme.of(context).appBarTheme.iconTheme!.color,
                      ),
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
                        case 5:
                          _opEnVersion();
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
                          enabled: userData.isLogin,
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Icon(
                                Icons.front_hand,
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
                        PopupMenuItem(
                          value: 5,
                          child: Wrap(
                            children: [
                              Icon(
                                Icons.tips_and_updates,
                                color: Theme.of(context).iconTheme.color,
                              ),
                              const SizedBox(width: 10),
                              RedDotWidget(
                                show: packageData.isNewVersion,
                                child: Text(FlutterI18n.translate(context, "app.setting.versions.title")),
                              ),
                            ],
                          ),
                        ),
                      ];
                    },
                  );
                })
              ],
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
                    color: Color.alphaBlend(Theme.of(context).bottomAppBarTheme.color!, Theme.of(context).bottomSheetTheme.backgroundColor!),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  height: screenBarHeight,
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: 6.0,
                        width: 45.0,
                        margin: const EdgeInsets.only(top: 10.0, bottom: 10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).dividerTheme.color,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(5.0),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.55 - screenBarHeight,
                        child: HomeFooterBarPanel(
                          dragContainerKey: _drawerWidget,
                        ),
                      ),
                    ],
                  ),
                ),
                defaultShowHeight: screenBarHeight,
                height: screenHeight * .55,
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: true,
              showUnselectedLabels: false,
              items: navs.map((nav) {
                return BottomNavigationBarItem(
                  icon: nav!["icon"],
                  activeIcon: nav["activeIcon"],
                  label: FlutterI18n.translate(context, "${nav["name"]}.title"),
                );
              }).toList(),
              currentIndex: _currentPageIndex,
              onTap: (int index) => _onHomePageIndexTap(index),
            ),
          );
        },
      ),
    );
  }
}
