/// 作弊玩家档案 日历卡片
/// 存放日历卡片的模板

import 'package:flutter/material.dart';

import '../../component/_html/htmlWidget.dart';
import '../../utils/index.dart';

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
  final List<Widget>? header;
  final Widget? headerSecondary;
  final Widget? content;
  final TimeLineItemBottomBtn? bottom;
  final Widget? button;
  final bool? isShowLine;

  List? leftIconTypes = [
    CircleAvatar(
      radius: 18,
      backgroundColor: Colors.blue.withOpacity(.2),
      child: const Icon(
        Icons.help,
        color: Colors.red,
        size: 14,
      ),
    ),
    CircleAvatar(
      radius: 18,
      backgroundColor: Colors.blue.withOpacity(.2),
      child: const Icon(
        Icons.chat_bubble_outlined,
        color: Colors.blue,
        size: 14,
      ),
    ),
    CircleAvatar(
      radius: 18,
      backgroundColor: Colors.white.withOpacity(.2),
      child: const Icon(
        Icons.front_hand,
        size: 14,
      ),
    ),
    CircleAvatar(
      radius: 18,
      backgroundColor: const Color(0xFF3d1380).withOpacity(.8),
      child: const Icon(
        Icons.chat_rounded,
        color: Colors.white,
        size: 14,
      ),
    ),
    CircleAvatar(
      radius: 18,
      backgroundColor: const Color(0xFFeb2f96).withOpacity(.2),
      child: const Icon(
        Icons.bookmark,
        color: Color(0xFFeb2f96),
        size: 14,
      ),
    ),
    CircleAvatar(
      radius: 18,
      backgroundColor: const Color(0xFFffe58f).withOpacity(.2),
      child: const Icon(
        Icons.history,
        color: Color(0xFFffe58f),
        size: 14,
      ),
    )
  ];
  CircleAvatar? leftIcon;

  TimeLineBaseCard({
    super.key,
    TimeLineItemType type = TimeLineItemType.none,
    this.header,
    this.headerSecondary,
    this.content,
    this.button,
    this.bottom,
    this.isShowLine = true,
  }) {
    leftIcon = leftIconTypes![type.index];
  }

  @override
  State<TimeLineBaseCard> createState() => TimeLineBaseCardState();
}

class TimeLineBaseCardState extends State<TimeLineBaseCard> with SingleTickerProviderStateMixin {
  final GlobalKey contentHtmlBaseKey = GlobalKey();

  // 当前内容高度
  double currentBodyHeight = 0;

  bool inInit = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      updateWidgetHeight();
    });

    eventUtil.on("html-image-update-widget", (e) {
      Future.delayed(const Duration(microseconds: 300), () {
        updateWidgetHeight();
      });
    });

    inInit = true;
    super.initState();
  }

  /// [Event]
  /// 设置垂直线高度
  updateWidgetHeight() {
    if (mounted && inInit) {
      double semanticBounds = contentHtmlBaseKey.currentContext!.findRenderObject()!.semanticBounds.size.height;
      setState(() {
        if (semanticBounds != currentBodyHeight) currentBodyHeight = semanticBounds;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 0),
          height: currentBodyHeight,
          constraints: const BoxConstraints(
            minHeight: 36,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.only(top: 0, left: 10, right: 10),
                child: widget.leftIcon!,
              ),
              if (widget.isShowLine!)
                Flexible(
                  flex: 2,
                  child: Container(
                    color: Theme.of(context).dividerTheme.color,
                    width: 4,
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            key: contentHtmlBaseKey,
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
              // if (widget.isShowShare)
              //   IconButton(
              //     onPressed: () {},
              //     icon: const Icon(
              //       Icons.share_outlined,
              //       size: 17,
              //     ),
              //   ),
              if (widget.isShowReply)
                IconButton(
                  onPressed: () {
                    cardUtil.setReply(context, type: 1, floor: widget.floor, toPlayerId: widget.data!["toPlayerId"], toCommentId: widget.data!["id"], callback: () {
                      // 更新时间轴
                      eventUtil.emit("updateTimeline-event", null);
                    });
                  },
                  icon: const Icon(
                    Icons.quickreply_outlined,
                    size: 17,
                  ),
                ),
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
                  alignment: PlaceholderAlignment.middle,
                  child: Opacity(
                    opacity: .5,
                    child: Text(
                      "${widget.data!["id"]}",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
            ],
          ),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
