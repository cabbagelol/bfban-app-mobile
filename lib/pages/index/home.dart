import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../../data/Theme.dart';
import '../not_found/index.dart';
import 'home_community_activitie.dart';
import 'home_tour_record.dart';
import 'home_trace.dart';
import 'home_trend.dart';

class homePage extends StatefulWidget {
  final int num;

  const homePage({
    Key? key,
    this.num = 0,
  }) : super(key: key);

  get getNum {
    return num;
  }

  @override
  _homePageState createState() => _homePageState();
}

class _homePageState extends State<homePage> with TickerProviderStateMixin {
  // 应用主体
  AppThemeItem? theme;

  final GlobalKey<HomeCommunityPageState> _homeCommunityPageKey = GlobalKey<HomeCommunityPageState>();

  final GlobalKey<HomeTracePageState> _homeTracePageKey = GlobalKey<HomeTracePageState>();

  final GlobalKey<HomeTrendPageState> _homeTrendPageKey = GlobalKey<HomeTrendPageState>();

  late TabController tabController;

  /// 异步
  Future? futureBuilder;

  List homeTabs = [];

  List homeTabsType = [
    {"text": "activities", "icon": Icons.notifications_active_rounded},
    {"text": "trend", "icon": Icons.local_fire_department_sharp},
    {"text": "trace", "icon": Icons.star},
    // {"text": "tourRecord", "icon": Icons.receipt},
  ];

  List<Widget> homeTabsWidget = [];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ready();
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // State has changed and needs to be redrawn
    _initTab();
    super.didChangeDependencies();
  }

  void ready() async {
    futureBuilder = _initTab();
  }

  Future _initTab() async {
    List _homeTabs = [];
    List<Widget> _homeTabsWidget = [];
    for (var i in homeTabsType) {
      Map waitMap = {
        "text": FlutterI18n.translate(context, "app.home.tabs.${i["text"]}"),
        "icon": Icon(i["icon"], size: 16),
      };
      switch (i["text"]) {
        case "activities":
          _homeTabsWidget.add(const HomeCommunityPage());
          waitMap["load"] = _homeCommunityPageKey.currentState?.activityStatus.load ?? false;
          break;
        case "trend":
          _homeTabsWidget.add(HomeTrendPage(key: _homeTrendPageKey));
          waitMap["load"] = _homeTrendPageKey.currentState?.trendStatus.load ?? false;
          break;
        case "trace":
          _homeTabsWidget.add(HomeTracePage(key: _homeTracePageKey));
          waitMap["load"] = _homeTracePageKey.currentState?.traceStatus.load ?? false;
          break;
        case "tourRecord":
          _homeTabsWidget.add(const HomeTourRecordPage());
          waitMap["load"] = false;
          break;
        default:
          // Null
          break;
      }
      _homeTabs.add(waitMap);
    }
    setState(() {
      homeTabs = _homeTabs;
      homeTabsWidget = _homeTabsWidget;
    });

    tabController = TabController(
      vsync: this,
      length: homeTabs.length,
      initialIndex: 0,
    );

    return _homeTabs;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureBuilder,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        /// 数据未加载完成时
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            return DefaultTabController(
              length: homeTabs.length,
              child: Scaffold(
                extendBodyBehindAppBar: false,
                appBar: AppBar(
                  titleSpacing: 0,
                  centerTitle: true,
                  backgroundColor: Theme.of(context).bottomAppBarTheme.color!.withOpacity(.1),
                  title: TabBar(
                    controller: tabController,
                    isScrollable: true,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    tabs: homeTabs.map((e) {
                      return Tab(
                        iconMargin: EdgeInsets.zero,
                        child: e["load"] ?? false
                            ? const Text("-")
                            : Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  e["icon"],
                                  Text(
                                    "${e["text"]}",
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  )
                                ],
                              ),
                      );
                    }).toList(),
                  ),
                ),
                body: TabBarView(
                  controller: tabController,
                  children: homeTabsWidget.toList(),
                ),
              ),
            );
          default:
            return Container();
        }
      },
    );
  }
}
