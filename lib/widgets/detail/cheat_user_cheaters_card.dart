import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../../component/_html/htmlWidget.dart';
import '../../utils/index.dart';
import 'cheaters_card_types.dart';
import 'basic_quote_card.dart';

/// 回复
class CheatUserCheatersCard extends StatelessWidget {
  final GlobalKey<TimeLineBaseCardState> _timeLineBaseCardKey = GlobalKey<TimeLineBaseCardState>();

  // 单条数据
  late Map data;

  // 数据数量
  late num maxDataCount;

  // 位置
  late int index = 0;

  final Function onReplySucceed;

  final CardUtil _detailApi = CardUtil();

  CheatUserCheatersCard({
    Key? key,
    required this.onReplySucceed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TimeLineBaseCard(
      key: _timeLineBaseCardKey,
      type: TimeLineItemType.reply,
      isShowLine: maxDataCount > 1 && index < maxDataCount,
      header: [
        // 类型
        Text.rich(
          TextSpan(
            style: const TextStyle(fontSize: 16),
            children: <TextSpan>[
              TextSpan(
                text: data["username"],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  decorationStyle: TextDecorationStyle.dotted,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    _detailApi.openPlayerDetail(context, data["byUserId"]);
                  },
              ),
              TextSpan(
                text: "\t${FlutterI18n.translate(context, "basic.button.reply")}",
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                ),
              ),
              TextSpan(
                text: "\t·\t${Date().getTimestampTransferCharacter(data['createTime'])["Y_D_M"]}",
              )
            ],
          ),
        ),
      ],
      content: HtmlWidget(
        content: data["content"] is Map ? data["content"]["text"] : data["content"],
        quote: QuoteCard(data: data),
        onChangeOption: () {
          _timeLineBaseCardKey.currentState!.updateWidgetHeight();
        },
      ),
      bottom: TimeLineItemBottomBtn(
        data: data,
        floor: index,
        isShowShare: true,
        isShowReply: true,
      ),
    );
  }
}
