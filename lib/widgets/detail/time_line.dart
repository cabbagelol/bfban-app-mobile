import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';

import '../../constants/api.dart';
import '../../data/index.dart';
import '../../utils/index.dart';
import 'appeal_card.dart';
import 'cheat_reports_card.dart';
import 'cheaters_card_types.dart';
import 'judgement_card.dart';

class TimeLine extends StatefulWidget {
  PlayerStatus playerStatus;

  TimeLine({
    Key? key,
    required this.playerStatus,
  }) : super(key: key);

  @override
  State<TimeLine> createState() => TimeLineState();
}

class TimeLineState extends State<TimeLine> {
  final UrlUtil _urlUtil = UrlUtil();

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
  void initState() {
    playerTimelineStatus.parame!.personaId = widget.playerStatus.data["originPersonaId"];

    getTimeline();

    super.initState();
  }

  /// [Response]
  /// 获取时间轴
  Future getTimeline() async {
    setState(() {
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
  /// 用户回复
  dynamic setReply(num type) {
    return () {
      // 检查登录状态
      if (!ProviderUtil().ofUser(context).checkLogin()) return;

      String parameter = "";

      switch (type) {
        case 0:
          // 回复
          parameter = jsonEncode({
            "type": type,
            "toCommentId": null,
            "toPlayerId": widget.playerStatus.data["id"],
          });
          break;
        case 1:
          // 回复楼层
          parameter = jsonEncode({
            "type": type,
            "toCommentId": widget.playerStatus.data["id"],
            "toPlayerId": widget.playerStatus.data["toPlayerId"],
          });
          break;
      }

      _urlUtil.opEnPage(context, "/reply/$parameter", transition: TransitionType.cupertinoFullScreenDialog).then((value) {
        if (value != null) {
          scrollController.jumpTo(scrollController.position.maxScrollExtent);
        }
      });
    };
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
      onRefresh: _onRefreshTimeline,
      child: ListView.builder(
        controller: scrollController,
        itemCount: playerTimelineStatus.list!.length,
        itemBuilder: (BuildContext context, int index) {
          var timeLineItem = playerTimelineStatus.list![index];

          switch (timeLineItem["type"]) {
            case "reply":
              // 评论
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

          return Container();
        },
      ),
    );
  }
}
