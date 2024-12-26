import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '/component/_time/index.dart';

import 'base_card.dart';
import 'basic_timeline_types.dart';

class HistoryNameCard extends StatelessWidget implements BaseCardStatelessWidget {
  // 单条数据
  @override
  late Map data;

  // 数据数量
  @override
  late num maxDataCount;

  // 位置
  @override
  late int index = 0;

  HistoryNameCard({
    super.key,
  });

  @override
  HistoryNameCard init({required Map data, required num maxDataCount, required int index}) {
    this.data = data;
    this.maxDataCount = maxDataCount;
    this.index = index;
    return this;
  }

  @override
  Widget build(BuildContext context) {
    return TimeLineBaseCard(
      type: TimeLineItemType.historyName,
      isShowLine: maxDataCount > 1 && index < maxDataCount,
      header: [
        // 标题
        Text.rich(
          TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: [
              TextSpan(
                text: "\t${FlutterI18n.translate(context, "detail.appeal.info.changeName")}\t",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              WidgetSpan(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('\t·\t'),
                    TimeWidget(
                      data: data['fromTime'],
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
              Text(
                data["beforeUsername"].toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: "UbuntuMono"),
              ),
              const SizedBox(
                height: 30,
                child: Icon(Icons.arrow_downward_outlined, size: 16),
              ),
              Text(
                data["nextUsername"].toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: "UbuntuMono"),
              ),
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
