/// 筛选 游戏类型选择面板

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import 'package:bfban/constants/api.dart';

import '../../../component/_filter/class.dart';
import '../../../component/_filter/framework.dart';

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
    {"value": "all"}
  ];

  @override
  void initState() {
    widget.data = FilterPanelData(
      value: "all",
      name: "game",
    );

    setState(() {
      gameList.addAll(Config.game["child"]);
      widget.isInit = true;
    });

    super.initState();
  }

  @override
  void didUpdateWidget(covariant GameNameFilterPanel oldWidget) {
    widget.data ??= FilterPanelData(
      value: "all",
      name: "game",
    );

    super.didUpdateWidget(oldWidget);
  }

  /// [Event]
  /// 更新数据
  upData() {
    gameList = [
      {"value": "all"}
    ];
    setState(() {
      gameList.addAll(Config.game["child"]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FormField(
      builder: (FormFieldState field) {
        return Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
                side: BorderSide(
                  color: Theme.of(context).dividerTheme.color!,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButton(
                    isExpanded: true,
                    underline: const SizedBox(),
                    dropdownColor: Theme.of(context).bottomAppBarTheme.color,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    style: Theme.of(context).dropdownMenuTheme.textStyle,
                    onChanged: (value) {
                      field.setState(() {
                        field.setValue(value.toString());
                      });

                      setState(() {
                        widget.data!.value = field.value;
                      });
                    },
                    value: field.value,
                    items: gameList.asMap().keys.map<DropdownMenuItem<String>>((index) {
                      Map i = gameList[index];

                      return DropdownMenuItem(
                        value: i["value"].toString(),
                        child: Text(FlutterI18n.translate(context, "basic.games.${i["value"]}")),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        );
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      initialValue: widget.data!.value,
      onSaved: (value) {
        setState(() {
          widget.data!.value = value as String;
        });
      },
      validator: (value) {
        if (value.toString().isEmpty) return "";
        return null;
      },
    );
  }
}
