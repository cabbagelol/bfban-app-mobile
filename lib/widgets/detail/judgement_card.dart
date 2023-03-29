import 'package:bfban/component/_cheatMethodsTag/index.dart';
import 'package:bfban/component/_gamesTag/index.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/_tag/tag.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import 'cheaters_card_types.dart';
import '../../utils/date.dart';

/// 裁判
class JudgementCard extends StatelessWidget {
  // 单条数据
  late Map data;

  // 位置
  late int index = 0;

  final CardUtil _detailApi = CardUtil();

  JudgementCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TimeLineCard(
      header: [
        Container(
          padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
          child: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(.2),
            child: Icon(Icons.contactless_sharp),
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Wrap(
                runAlignment: WrapAlignment.center,
                children: <Widget>[
                  // 类型
                  Text.rich(
                    TextSpan(
                      style: const TextStyle(fontSize: 16),
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
                          text: "${FlutterI18n.translate(context, "detail.info.judge")}\t",
                          style: const TextStyle(fontWeight: FontWeight.normal),
                        ),
                        WidgetSpan(
                          child: EluiTagComponent(
                            color: EluiTagType.none,
                            size: EluiTagSize.no2,
                            theme: EluiTagTheme(
                              backgroundColor: Theme.of(context).cardColor,
                              textColor: Theme.of(context).textTheme.subtitle1!.color!,
                            ),
                            value: FlutterI18n.translate(context, "basic.action.${data["judgeAction"]}.text"),
                            onTap: () {},
                          ),
                        ),
                        if (data["cheatMethods"] == null)
                          TextSpan(
                            text: "\t${FlutterI18n.translate(context, "detail.info.cheatMethod")}\t",
                            style: const TextStyle(fontWeight: FontWeight.normal),
                          ),
                        if (data["cheatMethods"] == null)
                          WidgetSpan(
                            child: CheatMethodsTagWidget(data: data["cheatMethods"]),
                          ),
                        TextSpan(text: "\t·\t${Date().getTimestampTransferCharacter(data['createTime'])["Y_D_M"]}")
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        ReplyButtonWidget(data: data)..floor = index,
      ],
      headerSecondary: Card(
        margin: const EdgeInsets.only(right: 10, bottom: 10),
        color: Theme.of(context).primaryColorDark.withOpacity(.2),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Wrap(
                  runAlignment: WrapAlignment.center,
                  spacing: 5,
                  children: <Widget>[
                    // 名称
                    Text(
                      data["username"],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Offstage(
                offstage: data["toFloor"] == null,
                child: Text(
                  "#${data["toFloor"]} ",
                  style: const TextStyle(
                    color: Colors.black26,
                  ),
                ),
              ),
              const Icon(
                Icons.vertical_align_top,
                color: Colors.black26,
                size: 15,
              )
            ],
          ),
        ),
      ),
      content: Offstage(
        offstage: data["content"] == "",
        child: Html(
          data: data["content"],
          style: _detailApi.styleHtml(context),
          customRenders: _detailApi.customRenders(context),
        ),
      ),
    );
  }
}
