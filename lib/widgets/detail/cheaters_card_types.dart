/// 作弊玩家档案 日历卡片
/// 存放日历卡片的模板

import 'package:flutter/material.dart';

import '../../component/_html/htmlWidget.dart';

enum TimeLineItemType {
  none,
  reply,
  report,
  judgement,
  banAppeal,
  historyName,
}

/// 时间轴卡
/// Core Card
class TimeLineCard extends StatelessWidget {
  List<Widget>? header;
  Widget? headerSecondary;
  Widget? content;
  TimeLineItemBottomBtn? bottom;
  Widget? button;

  List? leftIconTypes = [
    CircleAvatar(
      backgroundColor: Colors.blue.withOpacity(.2),
      child: const Icon(
        Icons.help,
        color: Colors.red,
      ),
    ),
    CircleAvatar(
      backgroundColor: Colors.blue.withOpacity(.2),
      child: const Icon(
        Icons.chat_bubble_outlined,
        color: Colors.blue,
      ),
    ),
    CircleAvatar(
      backgroundColor: Colors.white.withOpacity(.2),
      child: const Icon(Icons.front_hand),
    ),
    CircleAvatar(
      backgroundColor: const Color(0xFF3d1380).withOpacity(.8),
      child: const Icon(
        Icons.chat_rounded,
        color: Colors.white,
      ),
    ),
    CircleAvatar(
      backgroundColor: const Color(0xFFeb2f96).withOpacity(.2),
      child: const Icon(
        Icons.bookmark,
        color: Color(0xFFeb2f96),
      ),
    ),
    CircleAvatar(
      backgroundColor: const Color(0xFFffe58f).withOpacity(.2),
      child: const Icon(
        Icons.history,
        color: Color(0xFFffe58f),
      ),
    )
  ];
  Widget? leftIcon;

  TimeLineCard({
    Key? key,
    TimeLineItemType type = TimeLineItemType.none,
    this.header,
    this.headerSecondary,
    this.content,
    this.button,
    this.bottom,
  }) : super(key: key) {
    leftIcon = leftIconTypes![type.index];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: [
          const Divider(height: 1),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
                child: leftIcon!,
              ),
              Flexible(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // 卡片标题
                    Container(
                      margin: const EdgeInsets.only(right: 10, top: 20, bottom: 10),
                      child: SelectionArea(
                        child: Wrap(
                          children: header!,
                        ),
                      ),
                    ),

                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: Column(
                        children: [
                          if (headerSecondary != null) headerSecondary!,

                          // 内容
                          content!,
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (bottom != null)
            Container(
              margin: const EdgeInsets.only(top: 3, left: 50, right: 10),
              child: Column(
                children: [
                  bottom!,
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// 时间轴按钮集
/// [时间轴卡] 下的按钮集合
class TimeLineItemBottomBtn extends StatefulWidget {
  Map? data;
  num? floor;
  bool isShowReply;
  bool isShowShare;

  TimeLineItemBottomBtn({
    Key? key,
    this.data,
    this.floor,
    this.isShowReply = false,
    this.isShowShare = false,
  }) : super(key: key);

  @override
  State<TimeLineItemBottomBtn> createState() => _TimeLineItemBottomBtnState();
}

class _TimeLineItemBottomBtnState extends State<TimeLineItemBottomBtn> {
  final CardUtil cardUtil = CardUtil();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Wrap(
            children: [
              if (widget.isShowReply)
                IconButton(
                  onPressed: () {
                    cardUtil.setReply(
                      context,
                      type: 1,
                      floor: widget.floor,
                      toPlayerId: widget.data!["toPlayerId"],
                      toCommentId: widget.data!["id"],
                    );
                  },
                  icon: const Icon(
                    Icons.quickreply_outlined,
                    size: 17,
                  ),
                ),
              // if (widget.isShowShare)
              //   IconButton(
              //     onPressed: () {},
              //     icon: const Icon(
              //       Icons.share_outlined,
              //     ),
              //   ),
            ],
          ),
        ),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: "#${widget.floor}"),
              if (widget.data!["id"] != null) const TextSpan(text: "-"),
              if (widget.data!["id"] != null)
                WidgetSpan(
                  child: Opacity(
                    opacity: .5,
                    child: Text("${widget.data!["id"]}"),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
