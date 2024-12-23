import 'package:bfban/component/_empty/index.dart';
import 'package:bfban/component/_loading/index.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../../component/_refresh/index.dart';
import '../../constants/api.dart';
import '../../data/index.dart';
import '../../utils/index.dart';
import '../../widgets/player/appeal_card.dart';
import '../../widgets/player/cheat_reports_card.dart';
import '../../widgets/player/cheat_user_cheaters_card.dart';
import '../../widgets/player/history_name_card.dart';
import '../../widgets/player/judgement_card.dart';

class TimeLine extends StatefulWidget {
  final PlayerStatus playerStatus;

  const TimeLine({
    super.key,
    required this.playerStatus,
  });

  @override
  State<TimeLine> createState() => TimeLineState();
}

class TimeLineState extends State<TimeLine> with AutomaticKeepAliveClientMixin {
  // 列表
  final GlobalKey<RefreshState> _refreshKey = GlobalKey<RefreshState>();

  ScrollController scrollController = ScrollController();

  /// 时间轴
  PlayerTimelineStatus playerTimelineStatus = PlayerTimelineStatus(
    total: 0,
    pageNumber: 1,
    list: [],
    load: false,
    parame: PlayerTimelineParame(
      skip: 0,
      limit: 20,
      personaId: "",
    ),
  );

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    playerTimelineStatus.parame.personaId = widget.playerStatus.data!.toMap["originPersonaId"];

    // 订阅通知时间轴列表更新
    eventUtil.on("updateTimeline-event", (arg) {
      getTimeline();
    });

    getTimeline();

    super.initState();
  }

  /// [Response]
  /// 获取时间轴
  Future getTimeline() async {
    if (playerTimelineStatus.load!) return;
    if (!mounted) return;

    setState(() {
      playerTimelineStatus.load = true;
    });

    Response result = await Http.request(
      Config.httpHost["player_timeline"],
      parame: playerTimelineStatus.parame.toMap,
      method: Http.GET,
    );

    if (result.data["success"] == 1) {
      Map d = result.data["data"];

      if (!mounted) result;
      setState(() {
        // 追加数据预期状态
        if (d["result"].isEmpty || d["result"].length <= playerTimelineStatus.parame.limit) {
          _refreshKey.currentState!.controller.finishLoad(IndicatorResult.noMore);
        }

        // 首页数据
        if (playerTimelineStatus.parame.skip! <= 0) {
          playerTimelineStatus.list = d["result"];
          _onMergeHistoryName();

          _refreshKey.currentState?.controller.finishRefresh();
          _refreshKey.currentState?.controller.resetFooter();
          return;
        }

        // 追加数据
        if (d["result"].isNotEmpty) {
          playerTimelineStatus.list!
            ..add({
              "pageTip": true,
              "pageIndex": playerTimelineStatus.pageNumber!,
            })
            ..addAll(d["result"]);
          playerTimelineStatus.pageNumber = playerTimelineStatus.pageNumber! + 1;
          _onMergeHistoryName();
          _refreshKey.currentState!.controller.finishLoad(IndicatorResult.success);
        }

        playerTimelineStatus.total = d["total"];
      });
    }

    setState(() {
      playerTimelineStatus.load = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// [Event]
  /// 合并时间轴历史名称
  void _onMergeHistoryName() {
    List? timelineList = List.from(playerTimelineStatus.list!);
    List? history = widget.playerStatus.data!.history;

    if (timelineList.isEmpty) return;

    // 处理历史名称，放置对应对应位置
    for (int hisrotyIndex = 0; hisrotyIndex < history!.length; hisrotyIndex++) {
      num nameHistoryTime = DateTime.parse(history[hisrotyIndex]["fromTime"]).millisecondsSinceEpoch;
      num prevNameTimeListTime = 0;
      num nameTimeListTime = 0;

      for (int timeLineIndex = 0; timeLineIndex < timelineList.length; timeLineIndex++) {
        if (timeLineIndex > 0 && timelineList[timeLineIndex - 1].containsKey("createTime")) {
          prevNameTimeListTime = DateTime.parse(timelineList[timeLineIndex - 1]["createTime"]).millisecondsSinceEpoch;
        }
        nameTimeListTime = timelineList[timeLineIndex]["createTime"] != null ? DateTime.parse(timelineList[timeLineIndex]["createTime"]).millisecondsSinceEpoch : 0;

        // 历史名称的记录大于1，history内表示举报提交时初始名称，不应当放进timeline中
        // 索引自身历史修改日期位置，放入timeline中
        if (hisrotyIndex >= 1 && timelineList[timeLineIndex]["type"] != "historyUsername" && nameHistoryTime >= prevNameTimeListTime && nameHistoryTime <= nameTimeListTime) {
          timelineList.insert(timeLineIndex, {
            "type": "historyUsername",
            "beforeUsername": history[hisrotyIndex - 1]["originName"],
            "nextUsername": history[hisrotyIndex]["originName"],
            "fromTime": history[hisrotyIndex]["fromTime"],
          });
          break;
        } else if (hisrotyIndex >= 1 && hisrotyIndex == history.length - 1 && timelineList[timeLineIndex]["type"] != 'historyUsername' && nameHistoryTime >= nameTimeListTime) {
          timelineList.add({
            "type": "historyUsername",
            "beforeUsername": history[hisrotyIndex - 1]["originName"],
            "nextUsername": history[hisrotyIndex]["originName"],
            "fromTime": history[hisrotyIndex]["fromTime"],
          });
          break;
        }
      }
    }

    setState(() {
      playerTimelineStatus.list = timelineList;
    });
  }

  /// [Event]
  /// 评论内回复
  void _onReplySucceed(value) async {
    if (value == null) {
      return;
    }
    scrollController.jumpTo(scrollController.position.maxScrollExtent);
  }

  /// [Event]
  /// 作弊玩家时间轴 刷新
  Future<void> _onRefreshTimeline() async {
    playerTimelineStatus.parame.resetPage();

    await getTimeline();

    _refreshKey.currentState!.controller.finishRefresh();
    _refreshKey.currentState!.controller.resetFooter();
  }

  /// [Event]
  /// 下拉加载
  _getMore() async {
    playerTimelineStatus.parame.nextPage(count: playerTimelineStatus.parame.limit!);
    await getTimeline();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Refresh(
      key: _refreshKey,
      edgeOffset: MediaQuery.of(context).padding.top + kTextTabBarHeight,
      onRefresh: _onRefreshTimeline,
      onLoad: _getMore,
      child: Scrollbar(
        child: ListView(
          cacheExtent: 800,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10),
          controller: scrollController,
          children: playerTimelineStatus.list!.isNotEmpty
              ? playerTimelineStatus.list!.asMap().entries.map((data) {
                  int index = data.key;
                  num maxDataCount = playerTimelineStatus.list!.length;

                  if (data.key < playerTimelineStatus.list!.length) {
                    var timeLineItem = data.value;

                    // 分页提示
                    if (timeLineItem["pageTip"] != null) {
                      return Column(
                        children: [
                          if (index > 0 && index < playerTimelineStatus.list!.length - 1) const Divider(height: 1),
                          Row(
                            children: [
                              if (index > 0 && index < playerTimelineStatus.list!.length - 1)
                                Container(
                                  margin: const EdgeInsets.only(left: 29, right: 28),
                                  width: 2,
                                  height: 35,
                                ),
                              Center(
                                child: Wrap(
                                  runAlignment: WrapAlignment.center,
                                  children: [
                                    const Icon(Icons.tag, size: 17),
                                    Text(
                                      FlutterI18n.translate(context, "app.home.paging", translationParams: {"num": "${timeLineItem["pageIndex"]}"}),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Theme.of(context).textTheme.bodyMedium?.color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        ],
                      );
                    }

                    switch (timeLineItem["type"]) {
                      case "reply":
                        // 回复
                        return CheatUserCheatersCard(
                          onReplySucceed: _onReplySucceed,
                        ).init(
                          data: timeLineItem,
                          maxDataCount: maxDataCount,
                          index: index + 1,
                        );
                      case "report":
                        // 举报卡片
                        return CheatReportsCard(
                          onReplySucceed: _onReplySucceed,
                        ).init(
                          data: timeLineItem,
                          maxDataCount: maxDataCount,
                          index: index + 1,
                        );
                      case "judgement":
                        // 举报
                        return JudgementCard().init(
                          data: timeLineItem,
                          maxDataCount: maxDataCount,
                          index: index + 1,
                        );
                      case "banAppeal":
                        // 申诉
                        return AppealCard(
                          onReplySucceed: _onReplySucceed,
                        ).init(
                          data: timeLineItem,
                          maxDataCount: maxDataCount,
                          index: index + 1,
                        );
                      case "historyUsername":
                        return HistoryNameCard().init(
                          data: timeLineItem,
                          maxDataCount: maxDataCount,
                          index: index + 1,
                        );
                    }
                  }

                  return Container();
                }).toList()
              : [
                  playerTimelineStatus.load!
                      ? Center(
                          child: Container(
                            margin: const EdgeInsets.only(top: 30),
                            child: LoadingWidget(
                              size: 30,
                            ),
                          ),
                        )
                      : const EmptyWidget(),
                ],
        ),
      ),
    );
  }
}
