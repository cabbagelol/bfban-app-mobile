import 'package:bfban/component/_Time/index.dart';
import 'package:bfban/component/_cheatMethodsTag/index.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../../component/_gamesTag/index.dart';
import '../../component/_html/htmlWidget.dart';
import '../../utils/index.dart';
import 'base_card.dart';
import 'basic_timeline_types.dart';
import 'basic_quote_card.dart';
import 'basic_video_link.dart';

/// 举报
class CheatReportsCard extends StatelessWidget implements BaseCardStatelessWidget {
  final GlobalKey<TimeLineBaseCardState> _timeLineBaseCardKey = GlobalKey<TimeLineBaseCardState>();

  // 单条数据
  @override
  late Map data;

  // 数据数量
  @override
  late num maxDataCount;

  // 位置
  @override
  late int index;

  final CardUtil _detailApi = CardUtil();

  final Function onReplySucceed;

  CheatReportsCard({
    super.key,
    required this.onReplySucceed,
  });

  @override
  CheatReportsCard init({required Map data, required num maxDataCount, required int index}) {
    this.data = data;
    this.maxDataCount = maxDataCount;
    this.index = index;
    return this;
  }

  @override
  Widget build(BuildContext context) {
    return TimeLineBaseCard(
      key: _timeLineBaseCardKey,
      type: TimeLineItemType.report,
      isShowLine: maxDataCount > 1 && index! < maxDataCount,
      header: [
        // 标题
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
                text: "\t${FlutterI18n.translate(context, "detail.info.report")}\t",
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                ),
              ),
              TextSpan(
                text: data["toOriginName"] + "\t",
                style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: "UbuntuMono"),
              ),
              TextSpan(
                text: "${FlutterI18n.translate(context, "detail.info.inGame")}\t",
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                ),
              ),
              WidgetSpan(
                child: GamesTagWidget(
                  data: data["cheatGame"],
                  size: GamesTagSize.no2,
                ),
              ),
              TextSpan(
                text: "\t${FlutterI18n.translate(context, "detail.info.gaming")}\t",
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                ),
              ),
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
      headerSecondary: VideoLink(data: data),
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
