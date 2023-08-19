import 'package:bfban/widgets/detail/quote_card.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/_tag/tag.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../../component/_html/htmlWidget.dart';
import '../../utils/index.dart';
import 'cheaters_card_types.dart';

/// 申诉
class AppealCard extends StatelessWidget {
  // 单条数据
  late Map data;

  // 位置
  late int index = 0;

  final Function onReplySucceed;

  final CardUtil _detailApi = CardUtil();

  AppealCard({
    Key? key,
    required this.onReplySucceed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TimeLineCard(
      type: TimeLineItemType.banAppeal,
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
                    style: const TextStyle(fontSize: 16, height: 1.5),
                    children: [
                      TextSpan(
                        text: data["username"] + "\t",
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
                      TextSpan(
                        text: "\t·\t${Date().getTimestampTransferCharacter(data['createTime'])["Y_D_M"]}",
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
      content: HtmlWidget(
          content: data["content"],
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
