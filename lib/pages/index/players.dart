import 'package:flutter/material.dart';

import 'package:bfban/constants/api.dart';
import 'package:bfban/utils/index.dart';

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
        "tz": "",
        "limit": 10,
      },
    ),
  );

  List cheaterStatus = Config.cheaterStatus;

  @override
  void initState() {
    getPlayerList();

    // 标签初始
    _tabController = TabController(
      vsync: this,
      initialIndex: 0,
      length: Config.cheaterStatus.length,
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
  /// 重置参数
  bool resetPlayerParame({skip = false, sort = false, game = false, page = false}) {
    if (skip) playersStatus!.parame!.data["skip"] = 0;
    if (sort) playersStatus!.parame!.data["sort"] = "updateTime";
    if (game) playersStatus!.parame!.data["game"] = "all";
    if (game) playersStatus!.page = 1;

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
          onTap: (index) async {
            int _value = cheaterStatus[index]["value"];

            playersStatus!.parame!.data["status"] = _value;

            resetPlayerParame(skip: true, page: true);
            await getPlayerList();
          },
          padding: EdgeInsets.symmetric(horizontal: 15),
          tabs: cheaterStatus.map((i) {
            return Tab(
              text: Config.startusIng[i["value"]]["s"].toString(),
            );
          }).toList(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Filter(
              // 内容
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: playersStatus!.list!.isNotEmpty
                    ? ListView.builder(
                        controller: _scrollController,
                        itemCount: playersStatus?.list?.length,
                        itemBuilder: (BuildContext context, int index) {
                          if (playersStatus!.list![index]["pageTip"] != null) {
                            // 分页提示
                            return SizedBox(
                              height: 30,
                              child: Center(
                                child: Text(
                                  "第${playersStatus!.list![index]["pageIndex"]}页",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).textTheme.subtitle2?.color,
                                  ),
                                ),
                              ),
                            );
                          }

                          return CheatListCard(
                            item: playersStatus?.list![index],
                            onTap: () {
                              Routes.router!.navigateTo(
                                context,
                                '/detail/player/${playersStatus?.list![index]["originPersonaId"]}',
                              );
                            },
                          );
                        },
                      )
                    : const Center(child: Text('No items')),
              ),
              maxHeight: 300,
              suckTop: true,
              slot: [
                FilterItemWidget(
                  title: Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "排序方式",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.subtitle1!.color,
                      ),
                    ),
                  ),
                  panel: SoltFilterPanel(),
                ),
                FilterItemWidget(
                  title: Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "游戏类型",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.subtitle1!.color,
                      ),
                    ),
                  ),
                  panel: GameNameFilterPanel(),
                ),
              ],
              onChange: (data) async {
                playersStatus!.parame!.data["game"] = data[1].value;
                playersStatus!.parame!.data["sort"] = data[0].value;
                await _onRefresh();
              },
              onReset: () => resetPlayerParame(),
            ),
            flex: 1,
          ),

          // 加载
          playersStatus!.load!
              ? Container(
                  height: 30,
                  width: 30,
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              : Container(),
        ],
      ),
    );
  }
}
