import 'package:bfban/component/_cheatMethodsTag/index.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../../component/_gamesTag/index.dart';
import '../../utils/date.dart';
import '../../utils/url.dart';
import 'cheaters_card_types.dart';

/// 举报
class CheatReportsCard extends StatelessWidget {
  // 单条数据
  late dynamic data;

  // 位置
  late int? index;

  final UrlUtil _urlUtil = UrlUtil();

  final CardUtil _detailApi = CardUtil();

  final Function onReplySucceed;

  CheatReportsCard({
    Key? key,
    required this.onReplySucceed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TimeLineCard(
      header: [
        Expanded(
          flex: 1,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                child: Text(data["username"][0].toString()),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // 标题
                    Text.rich(
                      TextSpan(
                        style: const TextStyle(fontSize: 18),
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
                            text: "${FlutterI18n.translate(context, "detail.info.report")}\t",
                            style: const TextStyle(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          TextSpan(
                            text: data["toOriginName"] + "\t",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "${Date().getTimestampTransferCharacter(data['createTime'])["Y_D_M"]}",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.subtitle2!.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              ReplyButtonWidget(data: data)..floor = index,
            ],
          ),
        ),
      ],
      headerSecondary: Offstage(
        offstage: data["videoLink"].toString().isEmpty,
        child: Column(
          children: data["videoLink"].toString().split(",").map((i) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: Row(
                children: [
                  Card(
                    borderOnForeground: true,
                    elevation: 20,
                    color: Theme.of(context).primaryColorDark.withOpacity(.2),
                    shadowColor: Colors.black26,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            FlutterI18n.translate(context, "detail.info.videoLink"),
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 2, right: 5),
                    width: 1,
                    height: 15,
                    color: Theme.of(context).dividerColor,
                    constraints: const BoxConstraints(
                      minHeight: 15,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Wrap(
                      children: [
                        GestureDetector(
                          child: const Icon(Icons.link, size: 15),
                          onTap: () => _urlUtil.onPeUrl(data["videoLink"].toString()),
                        ),
                        Text(
                          data["videoLink"].toString(),
                          style: const TextStyle(fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Text("${index! + 1}"),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      content: Offstage(
        offstage: data["content"] == "",
        child: Container(
          color: Theme.of(context).appBarTheme.backgroundColor!.withOpacity(.2),
          child: Html(
            data: data["content"],
            style: _detailApi.styleHtml(context),
            customRenders: _detailApi.customRenders(context),
          ),
        ),
      ),
    );
  }
}
