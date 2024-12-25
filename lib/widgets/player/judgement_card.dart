import 'package:bfban/component/_cheatMethodsTag/index.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../../component/_Time/index.dart';
import '../../component/_html/htmlWidget.dart';
import '../../utils/index.dart';
import 'base_card.dart';
import 'basic_quote_card.dart';
import 'basic_timeline_types.dart';

/// 裁判
class JudgementCard extends StatelessWidget implements BaseCardStatelessWidget {
  final GlobalKey<TimeLineBaseCardState> _timeLineBaseCardKey = GlobalKey<TimeLineBaseCardState>();

  final Util _util = Util();

  // 单条数据
  @override
  late Map data;

  // 数据数量
  @override
  late num maxDataCount;

  // 位置
  @override
  late int index = 0;

  final CardUtil _detailApi = CardUtil();

  JudgementCard({
    super.key,
  });

  @override
  JudgementCard init({required Map data, required num maxDataCount, required int index}) {
    this.data = data;
    this.maxDataCount = maxDataCount;
    this.index = index;
    return this;
  }

  @override
  Widget build(BuildContext context) {
    return TimeLineBaseCard(
      key: _timeLineBaseCardKey,
      type: TimeLineItemType.judgement,
      isShowLine: maxDataCount > 1 && index < maxDataCount,
      header: [
        /// 类型
        Text.rich(
          TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: [
              TextSpan(
                text: data["username"],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  decorationThickness: 1,
                  decorationStyle: TextDecorationStyle.wavy,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    _detailApi.openPlayerDetail(context, data["byUserId"]);
                  },
              ),
              TextSpan(
                text: "\t${FlutterI18n.translate(context, "detail.info.judge")}\t",
                style: const TextStyle(fontWeight: FontWeight.normal),
              ),
              WidgetSpan(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    border: Border.all(color: Theme.of(context).dividerTheme.color!),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    FlutterI18n.translate(context, "basic.action.${_util.queryAction(data["judgeAction"])}.text"),
                    style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.errorContainer),
                  ),
                ),
              ),
              if (data["cheatMethods"].isNotEmpty)
                TextSpan(
                  text: "\t${FlutterI18n.translate(context, "detail.info.cheatMethod")}\t",
                  style: const TextStyle(fontWeight: FontWeight.normal),
                ),
              if (data["cheatMethods"].isNotEmpty)
                WidgetSpan(
                  child: CheatMethodsTagWidget(data: data["cheatMethods"]),
                ),
              WidgetSpan(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('\t·\t'),
                    TimeWidget(
                      data: data['createTime'],
                      type: TimeWidgetType.full,
                      style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
      content: HtmlWidget(
        content: data["content"] is Map ? data["content"]["text"] : data["content"],
        quote: QuoteCard(data: data),
        onChangeOption: () {
          Future.delayed(const Duration(milliseconds: 25), () {
            _timeLineBaseCardKey.currentState!.updateWidgetHeight();
          });
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
