/// 玩家列表
library;

import 'dart:ui';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';

import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '/component/_refresh/index.dart';
import '/component/_empty/index.dart';
import '/data/index.dart';
import '/widgets/index/cheat_list_card.dart';
import '/widgets/player/filter/index.dart';
import '/constants/api.dart';
import '/utils/index.dart';

class PlayerListPage extends StatefulWidget {
  const PlayerListPage({
    super.key,
  });

  @override
  PlayerListPageState createState() => PlayerListPageState();
}

class PlayerListPageState extends State<PlayerListPage> with SingleTickerProviderStateMixin {
  // 抽屉
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // 列表
  final GlobalKey<RefreshState> _refreshKey = GlobalKey<RefreshState>();

  // 筛选
  final GlobalKey<PlayerFilterPanelState> _playerFilterPanelKey = GlobalKey<PlayerFilterPanelState>();

  // TAB
  late TabController? _tabController;

  // 列表视图控制器
  final ScrollController _scrollController = ScrollController();

  final StorageAccount _storageAccount = StorageAccount();

  // 玩家数据
  final PlayersStatus? playersStatus = PlayersStatus(
    load: false,
    list: [],
    pageNumber: 1,
    parame: PlayersParame(
      status: -1,
      limit: 20,
      skip: 0,
    ),
  );

  Statistics? statisticsStatus = Statistics(
    load: false,
    data: StatisticsData(),
  );

  // 玩家状态
  List? cheaterStatus = Config.cheaterStatus["child"] ?? [];

  @override
  void initState() {
    onReady();

    cheaterStatus!.insert(0, {
      "value": -1,
      "values": [-1],
    });

    // 标签初始
    _tabController = TabController(
      vsync: this,
      initialIndex: 0,
      length: cheaterStatus?.length ?? 0,
    );

    super.initState();
  }

  /// [Event]
  /// 初始
  onReady() async {
    dynamic playersTabInitialIndex = await _storageAccount.getConfiguration("playersTabInitialIndex");

    if (playersTabInitialIndex != null && playersTabInitialIndex != 0 && cheaterStatus!.length > 1) _tabController?.index = playersTabInitialIndex is bool ? 0 : playersTabInitialIndex;

    getPlayerList();
    getPlayerStatistics();
  }

  /// [Event]
  /// 重置参数
  bool onResetPlayerParame({skip = false, sort = false, game = false, page = false, data = false}) {
    setState(() {
      if (skip) {
        playersStatus!.parame!.resetPage();
        playersStatus!.pageNumber = 1;
      }
      if (sort) playersStatus!.parame!.sortBy = "updateTime";
      if (game) playersStatus!.parame!.game = "all";
      if (data) playersStatus!.list!.clear();
    });

    return true;
  }

  /// [Response]
  /// 获取作弊玩家列表
  Future getPlayerList() async {
    if (playersStatus!.load!) return;

    setState(() {
      playersStatus!.load = true;
    });

    Response result = await Http.request(
      Config.httpHost["players"],
      parame: playersStatus!.parame!.toMap,
      method: Http.GET,
    );

    if (result.data["success"] == 1) {
      Map d = result.data["data"];

      setState(() {
        // 追加数据预期状态
        if (d["result"].isEmpty || d["result"].length <= playersStatus?.parame!.limit) {
          _refreshKey.currentState!.controller.finishLoad(IndicatorResult.noMore);
        }

        // 首页数据
        if (playersStatus!.parame!.skip! <= 0) {
          playersStatus?.list = d["result"];
          return;
        }

        // 追加数据
        if (d["result"].isNotEmpty && playersStatus!.list!.isNotEmpty) {
          playersStatus?.list
            ?..add({
              "pageTip": true,
              "pageIndex": playersStatus!.pageNumber!,
            })
            ..addAll(d["result"]);

          playersStatus!.pageNumber = playersStatus!.pageNumber! + 1;
          _refreshKey.currentState!.controller.finishLoad(IndicatorResult.success);
        }
      });
    }

    setState(() {
      playersStatus!.load = false;
    });

    return true;
  }

  /// [Event]
  /// 下拉刷新方法,为list重新赋值
  Future _onRefresh() async {
    playersStatus!.parame!.resetPage();
    _refreshKey.currentState!.controller.finishRefresh();

    await getPlayerList();

    _refreshKey.currentState!.controller.resetHeader();
    _refreshKey.currentState!.controller.resetFooter();
  }

  /// [Event]
  /// 下拉 追加数据
  Future _getMore() async {
    playersStatus!.parame!.nextPage(count: playersStatus!.parame!.limit!);

    await getPlayerList();
  }

  /// [Event]
  /// tab切换
  Future _onSwitchTab(int index) async {
    int value = cheaterStatus![index]["value"];

    playersStatus!.parame!.status = value;

    onResetPlayerParame(skip: true, page: true);

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        curve: Curves.fastEaseInToSlowEaseOut,
        duration: const Duration(milliseconds: 300),
      );
    }

    _storageAccount.updateConfiguration("playersTabInitialIndex", index);

    setState(() {
      playersStatus!.list!.clear();
    });
    await getPlayerList();

    _refreshKey.currentState!.controller.resetHeader();
    _refreshKey.currentState!.controller.resetFooter();
  }

  /// [Response]
  /// 取得数量统计
  Future getPlayerStatistics() async {
    if (statisticsStatus!.load) return;

    // 生成查询条件
    Map data = {"data": []};

    Config.game["child"].forEach((i) {
      data["data"].add({"game": i["value"], "status": -1});
    });

    cheaterStatus!.asMap().keys.forEach((index) {
      // 跳过状态 -1 全部
      if (cheaterStatus![index]["value"] >= 0) {
        data["data"].add({
          "game": playersStatus!.parame!.game == "all" ? "*" : playersStatus!.parame!.game,
          "status": cheaterStatus![index]["value"],
        });
      }
    });

    setState(() {
      statisticsStatus!.load = true;
    });

    Response result = await Http.request(
      Config.httpHost["playerStatistics"],
      data: data,
      method: Http.POST,
    );

    if (result.data["success"] == 1) {
      final List d = result.data["data"];
      List tabStatusData = cheaterStatus!;

      cheaterStatus!.asMap().keys.forEach((itemIndex) {
        if (itemIndex >= 0) {
          for (var i in d) {
            // 状态统计
            if (i["status"] >= 0) {
              if (tabStatusData[itemIndex]["value"] == i["status"]) {
                // +1 是跳过 [全部] 标题不计入统计
                tabStatusData[itemIndex]["num"] = i["count"];
              }
            }

            // 游戏类型统计
            // 游戏类i["status"]是-1
            if (i["game"] != "*" && i["status"] == -1) {
              Config.game["child"].asMap().keys.forEach((index) {
                var gameNameItem = Config.game["child"][index];

                if (gameNameItem["value"] == i["game"]) {
                  gameNameItem["num"] = i["count"];
                }
              });
            }
          }
        }
      });

      // 渲染[TAB]不同状态统计
      setState(() {
        cheaterStatus = tabStatusData;
      });
    }

    setState(() {
      statisticsStatus!.load = false;
    });

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: false,
      body: Refresh(
        key: _refreshKey,
        edgeOffset: MediaQuery.of(context).padding.top,
        triggerOffset: MediaQuery.of(context).viewPadding.bottom + kBottomNavigationBarHeight,
        onRefresh: _onRefresh,
        onLoad: _getMore,
        child: Scrollbar(
          controller: _scrollController,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                stretch: true,
                pinned: true,
                primary: true,
                automaticallyImplyLeading: false,
                expandedHeight: 0,
                toolbarHeight: 40,
                backgroundColor: Theme.of(context).primaryColor.withOpacity(.95),
                flexibleSpace: FlexibleSpaceBar(
                  expandedTitleScale: 1,
                  titlePadding: EdgeInsets.zero,
                  background: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    blendMode: BlendMode.srcIn,
                    child: const SizedBox(),
                  ),
                  title: Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: TabBar.secondary(
                          controller: _tabController,
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          automaticIndicatorColorAdjustment: false,
                          onTap: (index) => _onSwitchTab(index),
                          tabs: cheaterStatus!.map((i) {
                            return Tab(
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: <Widget>[
                                  I18nText("basic.status.${i["value"] == -1 ? "all" : i["value"]}.text"),
                                  if (i["num"] != null && i["num"] > 0)
                                    Positioned(
                                      top: -10,
                                      right: -12,
                                      child: AnimatedScale(
                                        curve: Curves.easeInOutBack,
                                        scale: i["num"] != null || i["num"] == 0 ? 1 : .8,
                                        duration: const Duration(milliseconds: 800),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 0),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.error,
                                            borderRadius: BorderRadius.circular(5),
                                            border: Border.all(color: Theme.of(context).colorScheme.errorContainer, width: .7),
                                          ),
                                          constraints: const BoxConstraints(
                                            minWidth: 12,
                                            minHeight: 12,
                                          ),
                                          child: Text(
                                            i["num"] > 9999 ? "9999+" : i["num"].toString(),
                                            style: TextStyle(
                                              fontSize: FontSize.xSmall.value,
                                              color: Theme.of(context).colorScheme.errorContainer,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      PlayerFilterPanel(
                        key: _playerFilterPanelKey,
                        onChange: (Map value) {
                          playersStatus!.parame!.game = value["game"];
                          playersStatus!.parame!.sortBy = value["sortBy"];
                          playersStatus!.parame!.createTimeFrom = value["createTimeFrom"];
                          playersStatus!.parame!.createTimeTo = value["createTimeTo"];
                          playersStatus!.parame!.updateTimeFrom = value["updateTimeFrom"];
                          playersStatus!.parame!.updateTimeTo = value["updateTimeTo"];

                          _onRefresh();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              if (playersStatus!.list!.isNotEmpty)
                SliverList.builder(
                  itemCount: playersStatus!.list!.length,
                  itemBuilder: (BuildContext context, int index) {
                    if (index < playersStatus!.list!.length) {
                      // 分页提示
                      if (playersStatus!.list![index]["pageTip"] != null) {
                        return SizedBox(
                          height: 30,
                          child: Center(
                            child: Text(
                              FlutterI18n.translate(context, "app.home.paging", translationParams: {"num": "${playersStatus!.list![index]["pageIndex"]}"}),
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).textTheme.titleSmall?.color,
                              ),
                            ),
                          ),
                        );
                      }

                      // 内容卡片
                      return CheatListCard(
                        item: playersStatus?.list![index],
                      );
                    }

                    return Container();
                  },
                )
              else
                SliverFillRemaining(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: EmptyWidget(),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
