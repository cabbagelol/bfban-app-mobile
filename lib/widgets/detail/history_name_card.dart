import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../../utils/index.dart';
import 'cheaters_card_types.dart';

class HistoryNameCard extends StatelessWidget {
  // 单条数据
  late Map data;

  // 位置
  late int index = 0;

  final CardUtil _detailApi = CardUtil();

  @override
  Widget build(BuildContext context) {
    return TimeLineCard(
      type: TimeLineItemType.historyName,
      header: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // 标题
                  Text.rich(
                    TextSpan(
                      style: const TextStyle(fontSize: 16, height: 1.5),
                      children: [
                        TextSpan(
                          text: "\t${FlutterI18n.translate(context, "detail.appeal.info.changeName")}\t",
                          style: const TextStyle(
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        TextSpan(
                          text: "\t·\t${Date().getTimestampTransferCharacter(data["fromTime"])["Y_D_M"]}",
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
      content: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerTheme.color!, width: 1),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(data["beforeUsername"].toString(), textAlign: TextAlign.center),
              const SizedBox(
                height: 30,
                child: Icon(Icons.arrow_downward_outlined, size: 16),
              ),
              Text(data["nextUsername"].toString(), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
      bottom: TimeLineItemBottomBtn(
        data: data,
        floor: index,
        isShowShare: false,
        isShowReply: false,
      ),
    );
  }
}
