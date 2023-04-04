import 'package:bfban/component/_empty/index.dart';
import 'package:flutter/material.dart';

import '../../constants/api.dart';
import '../../data/index.dart';
import '../../utils/index.dart';
import '../../widgets/detail/appeal_card.dart';
import '../../widgets/detail/cheat_reports_card.dart';
import '../../widgets/detail/cheat_user_cheaters_card.dart';
import '../../widgets/detail/history_name_card.dart';
import '../../widgets/detail/judgement_card.dart';

class TimeLine extends StatefulWidget {
  PlayerStatus playerStatus;

  TimeLine({
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
    index: 0,
    list: [],
    total: 0,
    load: false,
    parame: PlayerTimelineParame(
      skip: 0,
      limit: 100,
      personaId: "",
    ),
  );

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    playerTimelineStatus.parame!.personaId = widget.playerStatus.data.toMap["originPersonaId"];

    getTimeline();

    super.initState();
  }

  /// [Response]
  /// 获取时间轴
  Future getTimeline() async {
    setState(() {
      Future.delayed(const Duration(seconds: 0), () {
        _refreshIndicatorKey.currentState!.show();
      });
      playerTimelineStatus.load = true;
    });

    Response result = await Http.request(
      Config.httpHost["player_timeline"],
      parame: playerTimelineStatus.parame!.toMap,
      method: Http.GET,
    );

    if (result.data["success"] == 1) {
      final d = result.data["data"];

      setState(() {
        playerTimelineStatus.list = d["result"];
        playerTimelineStatus.total = d["total"];

        onMergeHistoryName();
      });
    }

    setState(() {
      playerTimelineStatus.load = false;
    });

    return playerTimelineStatus.list;
  }

  /// 合并时间轴历史名称
  onMergeHistoryName() {
    List? _timelineList = List.from(playerTimelineStatus.list!);
    List? _history = widget.playerStatus.data.history;

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
        if (
            hisrotyIndex >= 1 &&
            _timelineList[timeLineIndex]["type"] != "historyUsername" &&
            nameHistoryTime >= prevNameTimeListTime &&
            nameHistoryTime <= nameTimeListTime
        ) {
          _timelineList.insert(timeLineIndex, {
            "type": "historyUsername",
            "beforeUsername": _history[hisrotyIndex - 1]["originName"],
            "nextUsername": _history[hisrotyIndex]["originName"],
            "fromTime": _history[hisrotyIndex]["fromTime"],
          });
          break;
        } else if (
            hisrotyIndex >= 1 &&
            hisrotyIndex == _history.length - 1 &&
            _timelineList[timeLineIndex]["type"] != 'historyUsername' &&
            nameHistoryTime >= nameTimeListTime
        ) {
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
  /// 作弊玩家日历 刷新
  Future<void> _onRefreshTimeline() async {
    await getTimeline();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      edgeOffset: MediaQuery.of(context).padding.top,
      onRefresh: _onRefreshTimeline,
      child: ListView.builder(
        controller: scrollController,
        itemCount: playerTimelineStatus.list!.length,
        itemBuilder: (BuildContext context, int index) {
          var timeLineItem = playerTimelineStatus.list![index];

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

          return const EmptyWidget();
        },
      ),
    );
  }
}
