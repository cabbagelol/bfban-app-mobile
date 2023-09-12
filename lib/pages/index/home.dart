/// 搜索

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../../data/Theme.dart';
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
    super.initState();
  }

  @override
  void didChangeDependencies() {
    homeTabs = [];
    for (var i in homeTabsType) {
      Map waitMap = {
        "text": FlutterI18n.translate(context, "app.home.tabs.${i["text"]}"),
        "icon": Icon(i["icon"], size: 16),
      };
      switch (i["text"]) {
        case "activities":
          homeTabsWidget.add(const HomeCommunityPage());
          waitMap["load"] = _homeCommunityPageKey.currentState?.activityStatus.load ?? false;
          break;
        case "trend":
          homeTabsWidget.add(HomeTrendPage(key: _homeTrendPageKey));
          waitMap["load"] = _homeTrendPageKey.currentState?.trendStatus.load ?? false;
          break;
        case "trace":
          homeTabsWidget.add(HomeTracePage(key: _homeTracePageKey));
          waitMap["load"] = _homeTracePageKey.currentState?.traceStatus.load ?? false;
          break;
        case "tourRecord":
          homeTabsWidget.add(const HomeTourRecordPage());
          waitMap["load"] = false;
          break;
        default:
          // Null
          break;
      }
      homeTabs.add(waitMap);
    }

    tabController = TabController(vsync: this, length: homeTabs.length, initialIndex: 0);

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
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
        body: Column(
          children: [
            Expanded(
              flex: 1,
              child: TabBarView(
                controller: tabController,
                children: homeTabsWidget.toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
