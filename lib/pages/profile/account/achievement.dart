import 'package:bfban/component/_html/html.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '/component/_achievement/index.dart';
import '/constants/api.dart';
import '/data/index.dart';
import '/utils/index.dart';

class UserAchievementPage extends StatefulWidget {
  const UserAchievementPage({super.key});

  @override
  State<UserAchievementPage> createState() => _UserAchievementPageState();
}

class _UserAchievementPageState extends State<UserAchievementPage> {
  AchievementUtil achievementUtil = AchievementUtil();

  Map<String, Style> style = {
    '*': Style(fontSize: FontSize.small, padding: HtmlPaddings.zero),
  };

  final UserAchievementStatus _userAchievementStatus = UserAchievementStatus(
    load: false,
    data: UserAchievementData(),
  );

  @override
  void initState() {
    _onRefresh();
    super.initState();
  }

  Future _onRefresh() async {
    _getUserAchievement();
  }

  /// [Result]
  /// 获取用户成就
  void _getUserAchievement() async {
    _userAchievementStatus.load = true;

    Response result = await HttpToken.request(
      Config.httpHost["account_achievements"],
      method: Http.GET,
    );

    Map d = result.data;

    if (d["success"] == 1) {
      _userAchievementStatus.data!.setData(d["data"]);
    }

    if (!mounted) return;
    setState(() {
      _userAchievementStatus.load = false;
    });
  }

  /// [Void]
  /// 查看成就详情
  void _openAchievementDetail(String id) {
    if (id.isNotEmpty) UrlUtil().opEnPage(context, "/account/achievement/$id");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          FlutterI18n.translate(context, "profile.achievement.title"),
        ),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => _onRefresh(),
        child: Scrollbar(
          child: ListView(
            children: [
              /// header
              Container(
                color: Theme.of(context).cardTheme.color,
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
                margin: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(FlutterI18n.translate(context, "profile.achievement.exp")),
                        const SizedBox(height: 5),
                        Opacity(
                          opacity: .9,
                          child: Text("${_userAchievementStatus.data!.userAchievementExp ?? "N/A"}"),
                        ),
                      ],
                    ),
                    const VerticalDivider(width: 1, thickness: 1),
                    Column(
                      children: [
                        Text(FlutterI18n.translate(context, "profile.achievement.owned")),
                        const SizedBox(height: 5),
                        if (_userAchievementStatus.data!.o_achievements!.isNotEmpty)
                          achievementWidget(
                            data: _userAchievementStatus.data!.o_achievements,
                            size: 20,
                          )
                        else
                          const Text("N/A"),
                      ],
                    )
                  ],
                ),
              ),

              /// list
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: (Config.achievements["child"] as List).where((o) => !o.containsKey("isHidden")).map<Widget>((e) {
                  if (e["child"] != null) {
                    return ListTile(
                      dense: true,
                      title: SelectionArea(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              FlutterI18n.translate(context, "profile.achievement.list.${e["value"]}.name"),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: FontSize.large.value,
                              ),
                            ),
                            HtmlCore(data: FlutterI18n.translate(context, "profile.achievement.list.${e["value"]}.description"), style: style),
                          ],
                        ),
                      ),
                      subtitle: Card(
                        margin: const EdgeInsets.only(top: 5),
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          child: Wrap(
                            spacing: 15,
                            runSpacing: 13,
                            children: e["child"].map<Widget>((i) {
                              return AchievementCard(
                                iconPath: i["iconPath"],
                                value: i["value"],
                                onTap: () => _openAchievementDetail(i["value"]),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    );
                  }

                  return ListTile(
                    dense: true,
                    title: SelectionArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            FlutterI18n.translate(context, "profile.achievement.list.${e["value"]}.name"),
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: FontSize.large.value),
                          ),
                          HtmlCore(data: FlutterI18n.translate(context, "profile.achievement.list.${e["value"]}.conditions"), style: style),
                          if (e["rarity"] != null)
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              child: InputChip(
                                visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                                label: Text(
                                  FlutterI18n.translate(context, "profile.achievement.rarity.${e["rarity"]}"),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    subtitle: Card(
                      margin: const EdgeInsets.only(top: 5),
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        child: Wrap(
                          spacing: 15,
                          runSpacing: 13,
                          children: [
                            AchievementCard(
                              iconPath: e["iconPath"],
                              value: e["value"],
                              onTap: () => _openAchievementDetail(e["value"]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class AchievementCard extends StatelessWidget {
  final AchievementUtil achievementUtil = AchievementUtil();

  final String? iconPath;

  final String? value;

  final Function? onTap;

  AchievementCard({
    super.key,
    this.iconPath,
    this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 5,
      children: [
        Image.network(
          achievementUtil.getIcon(iconPath!),
          width: 30,
          height: 30,
          cacheWidth: 30,
          cacheHeight: 30,
          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
            return Container(
              color: Theme.of(context).dividerTheme.color,
              width: 30,
              height: 30,
            );
          },
        ),
        SelectionArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  if (onTap != null) onTap!();
                },
                child: Text(
                  FlutterI18n.translate(context, "profile.achievement.list.$value.name"),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    decorationThickness: 4,
                    decorationStyle: TextDecorationStyle.dashed,
                  ),
                ),
              ),
              Text(
                FlutterI18n.translate(context, "profile.achievement.list.$value.description"),
                style: TextStyle(fontSize: FontSize.small.value),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
