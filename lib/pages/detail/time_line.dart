import 'package:bfban/component/_empty/index.dart';
import 'package:flutter/material.dart';

import '../../constants/api.dart';
import '../../data/index.dart';
import '../../utils/index.dart';
import '../../widgets/detail/appeal_card.dart';
import '../../widgets/detail/cheat_reports_card.dart';
import '../../widgets/detail/cheat_user_cheaters_card.dart';
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
      });
    }

    setState(() {
      playerTimelineStatus.load = false;
    });

    return playerTimelineStatus.list;
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
              // 评论 or 回复
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
          }

          return const EmptyWidget();
        },
      ),
    );
  }
}



