import 'dart:ui' as ui;

import 'package:bfban/component/_html/html.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/elui.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '/utils/index.dart';

class UserAchievementDetailPage extends StatefulWidget {
  String? id;

  UserAchievementDetailPage({Key? key, this.id = ""}) : super(key: key);

  @override
  State<UserAchievementDetailPage> createState() => _UserAchievementPageState();
}

class _UserAchievementPageState extends State<UserAchievementDetailPage> {
  AchievementUtil achievementUtil = AchievementUtil();

  Map achievementDetailInfo = {};

  bool activeButton = true;

  bool activeButtonload = false;

  @override
  void initState() {
    achievementDetailInfo = achievementUtil.getItem(widget.id!);
    super.initState();
  }

  /// [Future]
  /// 主动获取成就
  void onActiveAchievement() async {
    if (achievementDetailInfo["value"] == null) return;
    setState(() {
      activeButtonload = true;
    });

    Response result = await achievementUtil.onActiveAchievement(achievementDetailInfo["value"]);

    Map d = result.data;

    if (d["success"] == 1) {
      setState(() {
        activeButton = false;
        activeButtonload = false;
      });

      EluiMessageComponent.success(context)(
        child: Text(FlutterI18n.translate(
          context,
          "appStatusCode.${d["code"].replaceAll(".", "_")}",
          translationParams: {"message": d["message"] ?? ""},
        )),
      );
      return;
    }

    EluiMessageComponent.error(context)(
      child: Text(FlutterI18n.translate(
        context,
        "appStatusCode.${d["code"].replaceAll(".", "_")}",
        translationParams: {"message": d["message"] ?? ""},
      )),
    );

    setState(() {
      activeButtonload = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Scrollbar(
        child: ListView(
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
                      Image.network(
                        achievementUtil.getIcon(achievementDetailInfo["iconPath"]),
                        width: 100,
                        height: 100,
                        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                          return Container(
                            color: Theme.of(context).dividerTheme.color,
                            width: 100,
                            height: 100,
                          );
                        },
                      ),
                      Positioned(
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(
                            sigmaX: 50.0,
                            sigmaY: 50.0,
                          ),
                          child: Image.network(
                            achievementUtil.getIcon(achievementDetailInfo["iconPath"]),
                            width: 100,
                            height: 100,
                            errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                              return Container(
                                color: Theme.of(context).dividerTheme.color,
                                width: 100,
                                height: 100,
                              );
                            },
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
            ),
            if ((achievementDetailInfo.containsKey("acquisition") && achievementDetailInfo["acquisition"].indexOf("active") >= 0))
              Container(
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: () {
                    onActiveAchievement();
                  },
                  child: activeButtonload
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(FlutterI18n.translate(context, "profile.achievement.getButton")),
                ),
              )
          ],
        ),
      ),
    );
  }
}
