/// 玩家列表

import 'package:flutter/material.dart';

import 'package:bfban/constants/api.dart';
import 'package:bfban/utils/index.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../../component/_filter/index.dart';
import '../../data/index.dart';
import '../../router/router.dart';
import '../../widgets/filter/game_filter.dart';
import '../../widgets/filter/solt_filter.dart';
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
    page: 1,
    list: [],
    parame: PlayersParame(
      data: {
        "game": "all",
        "skip": 0,
        "sort": "updateTime",
        "status": -1,
        "limit": 10,
      },
    ),
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

    // 滚动视图初始
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        // 非加载状态调用
        if (!playersStatus!.load!) {
          await _getMore();
        }
      }
    });

    super.initState();
  }

  /// [Event]
  /// 初始
  ready() async {
    cheaterStatus!.insert(0, {
      "value": -1,
      "values": [-1],
    });

    getPlayerList();
    await getPlayerStatistics();
  }

  /// [Event]
  /// 重置参数
  bool resetPlayerParame({skip = false, sort = false, game = false, page = false, data = false}) {
    if (skip) playersStatus!.parame!.data["skip"] = 0;
    if (sort) playersStatus!.parame!.data["sort"] = "updateTime";
    if (game) playersStatus!.parame!.data["game"] = "all";
    if (page) playersStatus!.page = 1;
    if (data) playersStatus!.list = [];

    return true;
  }

  /// [Response]
  /// 获取作弊玩家列表
  Future getPlayerList() async {
    setState(() {
      playersStatus!.load = true;
    });

    // 更新页号
    playersStatus!.parame!.skip = (playersStatus!.page - 1) * playersStatus!.parame!.data["limit"];

    Response result = await Http.request(
      Config.httpHost["players"],
      parame: playersStatus!.parame!.toMap,
      method: Http.GET,
    );

    if (result.data["success"] == 1) {
      final List d = result.data["data"]["result"];
      setState(() {
        if (playersStatus!.page <= 1) {
          playersStatus?.list = d;
        } else {
          // 追加数据
          if (d.isNotEmpty) {
            playersStatus?.list
              ?..addAll(d)
              ..add({
                "pageTip": true,
                "pageIndex": playersStatus!.page,
              });
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
    playersStatus!.page = 1;

    await getPlayerList();
  }

  /// [Event]
  /// 下拉 追加数据
  Future _getMore() async {
    playersStatus!.page += 1;

    await getPlayerList();
  }

  /// [Event]
  /// tab切换
  _onSwitchTab(int index) async {
    Future.delayed(const Duration(seconds: 0), () {
      _refreshIndicatorKey.currentState!.show();
    });

    int _value = cheaterStatus![index]["value"];

    playersStatus!.parame!.data["status"] = _value;

    resetPlayerParame(skip: true, page: true);

    _scrollController.jumpTo(0);

    await getPlayerList();
  }

  /// [Response]
  /// 取得数量统计
  Future getPlayerStatistics() async {
    Map data = {"data": []};

    Config.game["child"].forEach((i) {
      data["data"].add({"game": i["value"], "status": -1});
    });

    cheaterStatus!.asMap().keys.forEach((index) {
      // 跳过状态 -1 全部
      if (cheaterStatus![index]["value"] >= 0) {
        data["data"].add({
          "game": playersStatus!.parame!.data["game"] == 'all' ? '*' : cheaterStatus![index]["value"],
          "status": cheaterStatus![index]["value"],
        });
      }
    });

    Response result = await Http.request(
      Config.httpHost["playerStatistics"],
      data: data,
      method: Http.POST,
    );

    if (result.data["success"] == 1) {
      final List d = result.data["data"];

      cheaterStatus!.asMap().keys.forEach((itemIndex) {
        if (itemIndex >= 0) {
          for (var i in d) {
            // 状态统计
            if (i["game"] == "*") {
              if (cheaterStatus![itemIndex]["value"] == i["status"]) {
                setState(() {
                  // +1 是跳过 [全部] 标题不计入统计
                  cheaterStatus![itemIndex]["num"] = i["count"];
                });
              }
            }

            // 游戏类型统计
            // 游戏类i["status"]是-1
            if (i["game"] != "*") {
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

      // 重新渲染筛选控件内部数据
      _gameNameFilterKey.currentState!.upData();
    }

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
        backgroundColor: Theme.of(context).backgroundColor.withOpacity(.1),
        title: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorWeight: .1,
          labelPadding: const EdgeInsets.symmetric(horizontal: 10),
          onTap: (index) => _onSwitchTab(index),
          padding: const EdgeInsets.symmetric(horizontal: 15),
          tabs: cheaterStatus!.map((i) {
            return Tab(
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  I18nText("basic.status.${ i["value"] == -1 ? 'all' : i["value"] }"),
                  Positioned(
                    top: -7,
                    right: -12,
                    child: AnimatedOpacity(
                      opacity: i["num"] != null || i["num"] == 0 ? 1 : 0,
                      duration: const Duration(milliseconds: 300),
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
                          i["num"].toString(),
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
              height: 61,
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
        slot: [
          FilterItemWidget(
            title: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                FlutterI18n.translate(context, "list.filters.sortByTitle"),
              ),
            ),
            panel: SoltFilterPanel(),
          ),
          FilterItemWidget(
            title: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                FlutterI18n.translate(context, "report.labels.game"),
              ),
            ),
            panel: GameNameFilterPanel(
              key: _gameNameFilterKey,
            ),
          ),
        ],
        onChange: (data) async {
          resetPlayerParame(game: true, sort: true, data: true);

          playersStatus!.parame!.data["game"] = data[1].value;
          playersStatus!.parame!.data["sort"] = data[0].value;

          await _onRefresh();
        },
        onReset: () => resetPlayerParame(),
        // 内容
        child: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _onRefresh,
          child: ListView.builder(
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
                        FlutterI18n.translate(context, "app.home.paging", translationParams: {
                          "num": "${playersStatus!.list![index]["pageIndex"]}"
                        }),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.subtitle2?.color,
                        ),
                      ),
                    ),
                  );
                }

                // 内容卡片
                return CheatListCard(
                  item: playersStatus?.list![index],
                );
              } else if (index >= playersStatus!.list!.length && playersStatus!.load!) {
                // 下拉加载
                return Center(
                  child: Container(
                    height: 30,
                    width: 30,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
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
