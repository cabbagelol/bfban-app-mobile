/// 玩家列表

import 'package:bfban/component/_empty/index.dart';
import 'package:flutter/material.dart';

import 'package:bfban/constants/api.dart';
import 'package:bfban/utils/index.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../../component/_filter/index.dart';
import '../../data/index.dart';
import '../../widgets/filter/create_time_filter.dart';
import '../../widgets/filter/game_filter.dart';
import '../../widgets/filter/solt_filter.dart';
import '../../widgets/filter/update_time_filter.dart';
import '../../widgets/index/cheat_list_card.dart';

class PlayerListPage extends StatefulWidget {
  const PlayerListPage({
    Key? key,
  }) : super(key: key);

  @override
  PlayerListPageState createState() => PlayerListPageState();
}

class PlayerListPageState extends State<PlayerListPage> with SingleTickerProviderStateMixin {
  // 抽屉
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // 筛选
  final GlobalKey<GameNameFilterPanelState> _gameNameFilterKey = GlobalKey();

  // TAB
  late TabController? _tabController;

  // 列表视图控制器
  final ScrollController _scrollController = ScrollController();

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

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  final GlobalKey<FilterState> _filterKey = GlobalKey();

  @override
  void initState() {
    ready();

    // 标签初始
    _tabController = TabController(
      vsync: this,
      initialIndex: 0,
      length: cheaterStatus?.length ?? 0,
    );

    _scrollController.addListener(() async {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (!playersStatus!.load!) {
          await _getMore();
        }
      }
    });

    super.initState();
  }

  /// [Event]
  /// 初始
  ready() {
    cheaterStatus!.insert(0, {
      "value": -1,
      "values": [-1],
    });

    getPlayerList();
    getPlayerStatistics();
  }

  /// [Event]
  /// 重置参数
  bool onResetPlayerParame({skip = false, sort = false, game = false, page = false, data = false}) {
    if (skip) playersStatus!.parame!.resetPage();
    if (sort) playersStatus!.parame!.sortBy = "updateTime";
    if (game) playersStatus!.parame!.game = "all";
    if (data) playersStatus!.list!.clear();

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
        if (playersStatus!.parame!.skip! <= 0) {
          playersStatus?.list = d["result"];
        } else {
          if (playersStatus!.parame!.skip! <= playersStatus!.parame!.limit!) {
            playersStatus!.list!.add({
              "pageTip": true,
              "pageIndex": playersStatus!.pageNumber!,
            });
            playersStatus!.pageNumber = playersStatus!.pageNumber! + 1;
          }

          // 追加数据
          if (d.isNotEmpty) {
            playersStatus?.list
              ?..addAll(d["result"])
              ..add({
                "pageTip": true,
                "pageIndex": playersStatus!.pageNumber!,
              });
            playersStatus!.pageNumber = playersStatus!.pageNumber! + 1;
          }
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

    await getPlayerList();
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

    if (_scrollController.hasClients && _scrollController.position.pixels > _scrollController.position.minScrollExtent) {
      _scrollController.animateTo(0, duration: const Duration(seconds: 1), curve: Curves.fastLinearToSlowEaseIn);
    }

    await _refreshIndicatorKey.currentState!.show();
    await getPlayerList();
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

      // 渲染[筛选]控件内部数据
      _gameNameFilterKey.currentState!.upData();
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
      appBar: AppBar(
        titleSpacing: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).bottomAppBarTheme.color!.withOpacity(.1),
        title: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorWeight: .1,
          labelPadding: const EdgeInsets.symmetric(horizontal: 10),
          padding: const EdgeInsets.symmetric(horizontal: 15),
          onTap: (index) => _onSwitchTab(index),
          tabs: cheaterStatus!.map((i) {
            return Tab(
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  I18nText("basic.status.${i["value"] == -1 ? "all" : i["value"]}"),
                  if (i["num"] != null && i["num"] > 0)
                    Positioned(
                      top: -10,
                      right: -12,
                      child: AnimatedOpacity(
                        opacity: i["num"] != null || i["num"] == 0 ? 1 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                          child: Text(
                            i["num"].toString(),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
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
      body: Filter(
        key: _filterKey,
        maxHeight: 300,
        suckTop: false,
        actions: [
          Expanded(
            flex: 1,
            child: Container(
              height: 50,
              color: Theme.of(context).scaffoldBackgroundColor,
              child: ButtonBar(
                alignment: MainAxisAlignment.end,
                children: <Widget>[
                  OutlinedButton(
                    child: Text(
                      FlutterI18n.translate(context, "basic.button.cancel"),
                    ),
                    onPressed: () {
                      _filterKey.currentState!.hidden();
                    },
                  ),
                  OutlinedButton(
                    child: Text(
                      FlutterI18n.translate(context, "basic.button.submit"),
                    ),
                    onPressed: () {
                      _filterKey.currentState!.hidden();
                      _filterKey.currentState!.updataFrom();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
        slot: <FilterItemWidget>[
          FilterItemWidget(
            title: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                FlutterI18n.translate(context, "list.filters.sortByTitle"),
                style: const TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            panel: SoltFilterPanel(),
          ),
          FilterItemWidget(
            title: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                FlutterI18n.translate(context, "list.colums.updateTime"),
                style: const TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            panel: CreateTimeFilterPanel(),
          ),
          FilterItemWidget(
            title: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                FlutterI18n.translate(context, "list.colums.reportTime"),
                style: const TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            panel: UpdateTimeFilterPanel(),
          ),
          FilterItemWidget(
            title: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                FlutterI18n.translate(context, "report.labels.game"),
                style: const TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            panel: GameNameFilterPanel(
              key: _gameNameFilterKey,
            ),
          ),
        ],
        onChange: (data) async {
          Map filterData = data;
          onResetPlayerParame(game: true, sort: true, data: true);

          if (data["createTime"] != null) {
            List createTime = data["createTime"].split(",");

            filterData["createTimeTo"] = DateTime.parse(createTime[0]).millisecondsSinceEpoch;
            filterData["createTimeFrom"] = DateTime.parse(createTime[1]).millisecondsSinceEpoch;
          }
          if (data["updateTime"] != null) {
            List updateTime = data["updateTime"].split(",");

            filterData["updateTimeTo"] = DateTime.parse(updateTime[0]).millisecondsSinceEpoch;
            filterData["updateTimeFrom"] = DateTime.parse(updateTime[0]).millisecondsSinceEpoch;
          }

          playersStatus!.parame!.setData(filterData);

          _onRefresh();
          getPlayerStatistics();
        },
        onReset: () => onResetPlayerParame(),
        // 内容
        child: RefreshIndicator(
          triggerMode: RefreshIndicatorTriggerMode.anywhere,
          key: _refreshIndicatorKey,
          onRefresh: _onRefresh,
          child: playersStatus!.list!.isEmpty
              ? const EmptyWidget()
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: playersStatus!.list!.length + 1,
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
                ),
        ),
      ),
    );
  }
}
