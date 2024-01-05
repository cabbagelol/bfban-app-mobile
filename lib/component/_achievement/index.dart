import 'package:bfban/utils/index.dart';
import 'package:flutter/material.dart';

class achievementWidget extends StatefulWidget {
  final List? data;

  achievementWidget({
    Key? key,
    this.data,
  });

  @override
  State<achievementWidget> createState() => _achievementWidgetState();
}

class _achievementWidgetState extends State<achievementWidget> {
  AchievementUtil achievementUtil = new AchievementUtil();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: widget.data!.map<Widget>((i) {
        return Column(
          children: [
            SizedBox(
              width: 25,
              height: 25,
              child: Image.asset(achievementUtil.getIcon(achievementUtil.getItem(i["name"])["iconPath"])),
            )
          ],
        );
      }).toList(),
    );
  }
}
