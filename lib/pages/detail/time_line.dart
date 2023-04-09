import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../../constants/api.dart';
import '../../data/index.dart';
import '../../utils/index.dart';
import '../../widgets/detail/appeal_card.dart';
import '../../widgets/detail/cheat_reports_card.dart';
import '../../widgets/detail/cheat_user_cheaters_card.dart';
import '../../widgets/detail/history_name_card.dart';
import '../../widgets/detail/judgement_card.dart';

class TimeLine extends StatefulWidget {
  final PlayerStatus playerStatus;

  const TimeLine({
    Key? key,
    required this.playerStatus,
  }) : super(key: key);

  @override
  State<TimeLine> createState() => TimeLineState();
}

class TimeLineState extends State<TimeLine> with AutomaticKeepAliveClientMixin {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

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

    // 滚动视图初始
    scrollController.addListener(() async {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        // 非加载状态调用
        if (!playerTimelineStatus.load!) {
          await _getMore();
        }
      }
    });

    getTimeline();

    super.initState();
  }

  /// [Response]
  /// 获取时间轴
  Future getTimeline() async {
    if (playerTimelineStatus.load!) return;

    setState(() {
      Future.delayed(const Duration(seconds: 0), () {
        _refreshIndicatorKey.currentState!.show(atTop: true);
      });
      playerTimelineStatus.load = true;
    });

    Response result = await Http.request(
      Config.httpHost["player_timeline"],
      parame: playerTimelineStatus.parame.toMap,
      method: Http.GET,
    );

    if (result.data["success"] == 1) {
      Map d = result.data["data"];

      setState(() {
        if (playerTimelineStatus.parame.skip! <= 0) {
          playerTimelineStatus.list = d["result"];
        } else {
          if (playerTimelineStatus.parame.skip! <= playerTimelineStatus.parame.limit!) {
            playerTimelineStatus.list?.add({
              "pageTip": true,
              "pageIndex": playerTimelineStatus.pageNumber!,
            });
            playerTimelineStatus.pageNumber = playerTimelineStatus.pageNumber! + 1;
          }

          // 追加数据
          if (d["result"].isNotEmpty) {
            playerTimelineStatus.list!
              ..addAll(d["result"])
              ..add({
                "pageTip": true,
                "pageIndex": playerTimelineStatus.pageNumber!,
              });
            playerTimelineStatus.pageNumber = playerTimelineStatus.pageNumber! + 1;
          }
        }
        onMergeHistoryName();
        playerTimelineStatus.total = d["total"];
      });
    }

    setState(() {
      playerTimelineStatus.load = false;
    });
  }

  /// 合并时间轴历史名称
  void onMergeHistoryName() {
    List? _timelineList = List.from(playerTimelineStatus.list!);
    List? _history = widget.playerStatus.data!.history;

    // 处理历史名称，放置对应对应位置
    for (int hisrotyIndex = 0; hisrotyIndex < _history!.length; hisrotyIndex++) {
      num nameHistoryTime = DateTime.parse(_history[hisrotyIndex]["fromTime"]).millisecondsSinceEpoch;
      num prevNameTimeListTime = 0;
      num nameTimeListTime = 0;

      for (int timeLineIndex = 0; timeLineIndex < _timelineList.length; timeLineIndex++) {
        if (timeLineIndex > 0 && _timelineList[timeLineIndex - 1].containsKey("createTime")) {
          prevNameTimeListTime = DateTime.parse(_timelineList[timeLineIndex - 1]["createTime"]).millisecondsSinceEpoch;
        }
        nameTimeListTime = DateTime.parse(_timelineList[timeLineIndex]["createTime"]).millisecondsSinceEpoch;

        // 历史名称的记录大于1，history内表示举报提交时初始名称，不应当放进timeline中
        // 索引自身历史修改日期位置，放入timeline中
        if (hisrotyIndex >= 1 && _timelineList[timeLineIndex]["type"] != "historyUsername" && nameHistoryTime >= prevNameTimeListTime && nameHistoryTime <= nameTimeListTime) {
          _timelineList.insert(timeLineIndex, {
            "type": "historyUsername",
            "beforeUsername": _history[hisrotyIndex - 1]["originName"],
            "nextUsername": _history[hisrotyIndex]["originName"],
            "fromTime": _history[hisrotyIndex]["fromTime"],
          });
          break;
        } else if (hisrotyIndex >= 1 && hisrotyIndex == _history.length - 1 && _timelineList[timeLineIndex]["type"] != 'historyUsername' && nameHistoryTime >= nameTimeListTime) {
          _timelineList.add({
            "type": "historyUsername",
            "beforeUsername": _history[hisrotyIndex - 1]["originName"],
            "nextUsername": _history[hisrotyIndex]["originName"],
            "fromTime": _history[hisrotyIndex]["fromTime"],
          });
          break;
        }
      }
    }

    setState(() {
      _timelineList.add({"type": "button_add"});
      playerTimelineStatus.list = _timelineList;
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
    // playerTimelineStatus.parame.resetPage();
    await getTimeline();
  }

  /// [Event]
  /// 下拉加载
  Future<void> _getMore() async {
    playerTimelineStatus.parame.nextPage(count: playerTimelineStatus.parame.limit!);
    await getTimeline();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      edgeOffset: MediaQuery.of(context).padding.top,
      onRefresh: _onRefreshTimeline,
      child: ListView.builder(
        controller: scrollController,
        itemCount: playerTimelineStatus.list!.length,
        itemBuilder: (BuildContext context, int index) {
          if (index < playerTimelineStatus.list!.length) {
            var timeLineItem = playerTimelineStatus.list![index];

            // 分页提示
            if (timeLineItem["pageTip"] != null) {
              return Column(
                children: [
                  const Divider(height: 1),
                  SizedBox(
                    height: 30,
                    child: Center(
                      child: Text(
                        FlutterI18n.translate(context, "app.home.paging", translationParams: {"num": "${timeLineItem["pageIndex"]}"}),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            switch (timeLineItem["type"]) {
              case "reply":
              // 回复
                return CheatUserCheatersCard(
                  onReplySucceed: _onReplySucceed,
                )
                  ..data = timeLineItem
                  ..index = index;
              case "report":
              // 举报卡片
                return CheatReportsCard(
                  onReplySucceed: _onReplySucceed,
                )
                  ..data = timeLineItem
                  ..index = index;
              case "judgement":
              // 举报
                return JudgementCard()
                  ..data = timeLineItem
                  ..index = index;
              case "banAppeal":
              // 申诉
                return AppealCard(
                  onReplySucceed: _onReplySucceed,
                )
                  ..data = timeLineItem
                  ..index = index;
              case "historyUsername":
                return HistoryNameCard()
                  ..data = timeLineItem
                  ..index = index;
            }
          }

          return Container();
        },
      ),
    );
  }
}
