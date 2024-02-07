import 'dart:ui' as ui;

import 'package:bfban/component/_html/html.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../../../utils/index.dart';

class UserAchievementDetailPage extends StatefulWidget {
  String? id;

  UserAchievementDetailPage({this.id = ""});

  @override
  State<UserAchievementDetailPage> createState() => _UserAchievementPageState();
}

class _UserAchievementPageState extends State<UserAchievementDetailPage> {
  AchievementUtil achievementUtil = AchievementUtil();

  Map achievementDetailInfo = {};

  @override
  void initState() {
    achievementDetailInfo = achievementUtil.getItem(widget.id!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        children: [
          ClipPath(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              color: Theme.of(context).cardTheme.color,
              height: 300,
              child: Center(
                child: Stack(
                  children: [
                    Image.asset(
                      achievementUtil.getIcon(achievementDetailInfo["iconPath"]),
                      width: 100,
                      height: 100,
                    ),
                    Positioned(
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(
                          sigmaX: 50.0,
                          sigmaY: 50.0,
                        ),
                        child: Image.asset(
                          achievementUtil.getIcon(achievementDetailInfo["iconPath"]),
                          width: 100,
                          height: 100,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  FlutterI18n.translate(context, "profile.achievement.list.${achievementDetailInfo["value"]}.name"),
                  style: TextStyle(fontSize: FontSize.xLarge.value, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                HtmlCore(data: FlutterI18n.translate(context, "profile.achievement.list.${achievementDetailInfo["value"]}.description")),
                HtmlCore(
                  data: FlutterI18n.translate(context, "profile.achievement.list.${achievementDetailInfo["value"]}.conditions"),
                  style: {'*': Style(color: Colors.white54)},
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
