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
class TimeLineBaseCard extends StatefulWidget {
  List<Widget>? header;
  Widget? headerSecondary;
  Widget? content;
  TimeLineItemBottomBtn? bottom;
  Widget? button;
  bool? isShowLine;

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

  TimeLineBaseCard({
    Key? key,
    TimeLineItemType type = TimeLineItemType.none,
    this.header,
    this.headerSecondary,
    this.content,
    this.button,
    this.bottom,
    this.isShowLine = true,
  }) : super(key: key) {
    leftIcon = leftIconTypes![type.index];
  }

  @override
  State<TimeLineBaseCard> createState() => _TimeLineBaseCardState();
}

class _TimeLineBaseCardState extends State<TimeLineBaseCard> {
  GlobalKey contentKey = GlobalKey();
  double contentBodyHeight = 400.0;

  /// [Event]
  /// 设置垂直线高度
  _getWidgetHeight() {
    setState(() {
      contentBodyHeight = contentKey.currentContext!.findRenderObject()!.semanticBounds.size.height;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _getWidgetHeight();
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant TimeLineBaseCard oldWidget) {
    _getWidgetHeight();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: contentBodyHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.only(top: 0, left: 10, right: 10),
                child: widget.leftIcon!,
              ),
              if (widget.isShowLine!)
                Flexible(
                  flex: 1,
                  child: Container(
                    color: Theme.of(context).dividerTheme.color,
                    width: 2,
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            key: contentKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // 卡片标题
                Container(
                  margin: const EdgeInsets.only(right: 10, top: 5, bottom: 10),
                  child: SelectionArea(
                    child: Wrap(
                      children: widget.header!,
                    ),
                  ),
                ),

                Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: Column(
                    children: [
                      if (widget.headerSecondary != null) widget.headerSecondary!,

                      // 内容
                      widget.content!,
                    ],
                  ),
                ),

                if (widget.bottom != null)
                  Container(
                    margin: const EdgeInsets.only(top: 3, right: 10),
                    child: Column(
                      children: [
                        widget.bottom!,
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
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
