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
      children: (widget.data == null || widget.data!.isEmpty)
          ? [const Text("N/A")]
          : widget.data!.map<Widget>((i) {
        final String name = (i is Map ? i["name"] ?? "" : "").toString();
        final String iconPath = (achievementUtil.getItem(name)["iconPath"] ?? "").toString();
        final String iconUrl = achievementUtil.getIcon(iconPath);
        final double itemSize = widget.size ?? 25.0;

              return GestureDetector(
                onTap: () {
                  _openAchievementDetail(name);
                },
                child: SizedBox(
                  width: itemSize,
                  height: itemSize,
                  child: iconUrl.isNotEmpty
                      ? Image.network(
                    iconUrl,
                    errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                      return Container(
                        color: Theme
                            .of(context)
                            .dividerTheme
                            .color ?? Colors.grey.shade300,
                        width: itemSize,
                        height: itemSize,
                      );
                    },
                  )
                      : Container(
                    color: Theme
                        .of(context)
                        .dividerTheme
                        .color ?? Colors.grey.shade300,
                    width: itemSize,
                    height: itemSize,
                  ),
                ),
              );
            }).toList(),
    );
  }
}
