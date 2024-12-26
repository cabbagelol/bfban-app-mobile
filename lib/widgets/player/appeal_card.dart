import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/_tag/tag.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../../component/_time/index.dart';
import '../../component/_html/htmlWidget.dart';

import 'base_card.dart';
import 'basic_timeline_types.dart';
import 'basic_quote_card.dart';

/// 申诉
class AppealCard extends StatelessWidget implements BaseCardStatelessWidget {
  // 单条数据
  @override
  late final Map data;

  // 数据数量
  @override
  late final num maxDataCount;

  // 位置
  @override
  late int index = 0;

  final Function onReplySucceed;

  final CardUtil _detailApi = CardUtil();

  AppealCard({
    super.key,
    required this.onReplySucceed,
  });

  @override
  AppealCard init({required Map data, required num maxDataCount, required int index}) {
    this.data = data;
    this.maxDataCount = maxDataCount;
    this.index = index;
    return this;
  }

  @override
  Widget build(BuildContext context) {
    return TimeLineBaseCard(
      type: TimeLineItemType.banAppeal,
      isShowLine: maxDataCount > 1 && index < maxDataCount,
      header: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Wrap(
              runAlignment: WrapAlignment.center,
              children: <Widget>[
                // 类型
                Text.rich(
                  TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                        text: data["username"] + "\t",
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
                        text: "${FlutterI18n.translate(context, "detail.appeal.info.content")}\t",
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      WidgetSpan(
                        child: EluiTagComponent(
                          color: EluiTagType.none,
                          size: EluiTagSize.no2,
                          theme: EluiTagTheme(
                            backgroundColor: Theme.of(context).cardColor,
                            textColor: Theme.of(context).textTheme.displayMedium!.color!,
                          ),
                          value: data["appealStatus"] ?? "NONE",
                        ),
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
            ),
          ],
        ),
      ],
      content: HtmlWidget(
        content: data["content"] is Map ? data["content"]["text"] : data["content"],
        quote: QuoteCard(data: data),
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
