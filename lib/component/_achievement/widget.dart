import 'package:bfban/utils/index.dart';
import 'package:flutter/material.dart';

class achievementWidget extends StatefulWidget {
  final List? data;
  final double? size;

  achievementWidget({
    Key? key,
    this.data,
    this.size = 25.0,
  });

  @override
  State<achievementWidget> createState() => _achievementWidgetState();
}

class _achievementWidgetState extends State<achievementWidget> {
  AchievementUtil achievementUtil = AchievementUtil();

  /// [Void]
  /// 查看成就详情
  void _openAchievementDetail(String id) {
    if (id.isNotEmpty) UrlUtil().opEnPage(context, "/account/achievement/$id");
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 3,
      children: widget.data == null
          ? [const Text("N/A")]
          : widget.data!.map<Widget>((i) {
              return GestureDetector(
                onTap: () {
                  _openAchievementDetail(i["name"]);
                },
                child: SizedBox(
                  width: widget.size as double,
                  height: widget.size as double,
                  child: Image.asset(achievementUtil.getIcon(achievementUtil.getItem(i["name"])["iconPath"])),
                ),
              );
            }).toList(),
    );
  }
}
