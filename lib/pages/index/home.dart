/// 搜索

import 'dart:ui' as ui;

import 'package:bfban/pages/index/footerbar_panel.dart';
import 'package:bfban/widgets/drawer.dart';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:video_player/video_player.dart';

import '../../data/Theme.dart';
import 'home_community_activitie.dart';
import 'home_tour_record.dart';
import 'home_trace.dart';
import 'home_trend.dart';

class SearchPage extends StatefulWidget {
  final int num;

  const SearchPage({
    Key? key,
    this.num = 0,
  }) : super(key: key);

  get getNum {
    return num;
  }

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  // 应用主体
  AppThemeItem? theme;

  // 视频控制器
  VideoPlayerController? _controller;

  final GlobalKey<HomeCommunityPageState> _homeCommunityPageKey = GlobalKey<HomeCommunityPageState>();

  final GlobalKey<HomeTracePageState> _homeTracePageKey = GlobalKey<HomeTracePageState>();

  final GlobalKey<HomeTrendPageState> _homeTrendPageKey = GlobalKey<HomeTrendPageState>();

  late TabController tabController;

  List homeTabs = [];

  List homeTabsType = [
    {"text": "activities", "icon": Icons.notifications_active_rounded},
    {"text": "trend", "icon": Icons.local_fire_department_sharp},
    {"text": "trace", "icon": Icons.star},
    {"text": "tourRecord", "icon": Icons.receipt},
  ];

  @override
  void initState() {
    super.initState();

    /// 播放控制器
    _controller = VideoPlayerController.asset(
      'assets/video/bf-video-hero-medium-steam-launch.mp4',
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: true,
      ),
    )
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      })
      ..setLooping(true)
      ..play();
  }

  @override
  void didChangeDependencies() {
    homeTabs = [];
    for (var i in homeTabsType) {
      Map waitMap = {
        "text": FlutterI18n.translate(context, "app.home.tabs.${i["text"]}"),
        "icon": Icon(i["icon"]),
      };
      switch (i["text"]) {
        case "activities":
          waitMap["load"] = _homeCommunityPageKey.currentState?.activity!.load ?? false;
          break;
        case "trend":
          waitMap["load"] = _homeTrendPageKey.currentState?.trendStatus.load ?? false;
          break;
        case "trace":
          waitMap["load"] = _homeTracePageKey.currentState?.traceStatus.load ?? false;
          break;
        case "tourRecord":
        default:
          waitMap["load"] = false;
          break;
      }
      homeTabs.add(waitMap);
    }

    tabController = TabController(vsync: this, length: homeTabs.length, initialIndex: 0);

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    _controller!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenBarHeight = 26.0;

    return DefaultTabController(
      length: homeTabs.length,
      child: FlutterPluginDrawer(
        body: Stack(
          fit: StackFit.loose,
          children: <Widget>[
            // Positioned(
            //   top: 0,
            //   bottom: 0,
            //   child: _controller!.value.isInitialized
            //       ? AspectRatio(
            //           aspectRatio: _controller!.value.aspectRatio,
            //           child: VideoPlayer(_controller!),
            //         )
            //       : Container(),
            // ),
            BackdropFilter(
              filter: ui.ImageFilter.blur(
                sigmaX: 6.0,
                sigmaY: 6.0,
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    TabBar(
                      automaticIndicatorColorAdjustment: true,
                      controller: tabController,
                      tabs: homeTabs.map((e) {
                        return Tab(
                          icon: e["icon"],
                          iconMargin: EdgeInsets.zero,
                          child: e["load"] ?? false ? const Text("-") : Text("${e["text"]}", textAlign: TextAlign.center),
                        );
                      }).toList(),
                    ),
                    Expanded(
                      flex: 1,
                      child: TabBarView(
                        controller: tabController,
                        children: [
                          HomeCommunityPage(),
                          HomeTrendPage(key: _homeTrendPageKey),
                          HomeTracePage(key: _homeTracePageKey),
                          HomeTourRecordPage(),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        dragContainer: DragContainer(
          drawer: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  offset: const Offset(0, -2),
                  spreadRadius: .2,
                  blurRadius: 10,
                )
              ],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
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
          defaultShowHeight: screenBarHeight + 70,
          height: screenHeight * .5,
        ),
      ),
    );
  }
}
