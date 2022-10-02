/// 筛选 游戏类型选择面板

import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/_tag/tag.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import 'package:bfban/constants/api.dart';

import '../../component/_filter/class.dart';
import '../../component/_filter/framework.dart';

class GameNameFilterPanel extends FilterPanelWidget {
  GameNameFilterPanel({
    Key? key,
  }) : super(key: key);

  @override
  GameNameFilterPanelState createState() => GameNameFilterPanelState();
}

class GameNameFilterPanelState extends State<GameNameFilterPanel> {
  /// 游戏类型
  List gameList = [
    {
      "value": "all",
      "app_assets_logo_file": "assets/images/report/battlefield-v-png-logo.png",
    },
  ];

  @override
  void initState() {
    super.initState();

    if (!widget.isInit) {
      widget.data = FilterPanelData(
        value: "all",
        name: "game",
      );
    }

    gameList.addAll(Config.game["child"]);

    widget.isInit = true;
  }

  /// [Event]
  /// 更新数据
  upData () {
    gameList = [];
    setState(() {
      gameList.addAll(Config.game["child"]);
    });
  }

  /// [Event]
  /// 设置单选下标
  void _setIndex(int index) {
    setState(() {
      widget.data!.value = gameList[index]["value"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Column(
          children: gameList.asMap().keys.map((index) {
            Map i = gameList[index];

            return GestureDetector(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: widget.data!.value == i["value"] ? Theme.of(context).textSelectionTheme.selectionColor : Theme.of(context).scaffoldBackgroundColor.withOpacity(.9),
                  image: i["app_assets_bk_file"] == null
                      ? null
                      : DecorationImage(
                          opacity: .06,
                          fit: BoxFit.cover,
                          image: AssetImage(i["app_assets_bk_file"]),
                        ),
                ),
                child: Center(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      i["value"] == "all"
                          ? Center(
                              child: Text(
                                FlutterI18n.translate(context, "basic.games.all"),
                                style: TextStyle(
                                  fontWeight: widget.data!.value == i["value"] ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            )
                          : Image.asset(
                              i["app_assets_logo_file"],
                              height: 30,
                            ),
                      SizedBox(width: 10),
                      Visibility(
                        visible: i["num"] != null,
                        child: EluiTagComponent(
                          color: EluiTagType.none,
                          size: EluiTagSize.no2,
                          theme: EluiTagTheme(
                            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                          ),
                          value: i["num"].toString(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              onTap: () => _setIndex(index),
            );
          }).toList(),
        ),
      ],
    );
  }
}
