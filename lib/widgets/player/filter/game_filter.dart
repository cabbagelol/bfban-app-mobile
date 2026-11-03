/// 筛选 游戏类型选择面板

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import 'package:bfban/constants/api.dart';

import 'class.dart';
import 'framework.dart';

class GameNameFilterPanel extends FilterPanelWidget {
  GameNameFilterPanel({
    super.key,
    FilterPanelData? data,
  }) : super(
          data: data ??
              FilterPanelData(
                values: ["all"],
                names: ["game"],
              ),
        );

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
    setState(() {
      final List gameChildList = (Config.game["child"] is List) ? (Config.game["child"] as List) : [];
      gameList.addAll(gameChildList);
    });

    super.initState();
  }

  /// [Event]
  /// 更新数据
  upData() {
    gameList = [
      {"value": "all"}
    ];
    setState(() {
      final List gameChildList = (Config.game["child"] is List) ? (Config.game["child"] as List) : [];
      gameList.addAll(gameChildList);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FormField(
      builder: (FormFieldState field) {
        return Card(
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
                isDense: false,
                isExpanded: true,
                underline: const SizedBox(),
                dropdownColor: Theme.of(context).bottomAppBarTheme.color,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                style: Theme.of(context).dropdownMenuTheme.textStyle,
                onChanged: (value) {
                  field.didChange(value.toString());

                  setState(() {
                    widget.data!.values[0] = field.value;
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
        );
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      initialValue: widget.data!.values[0],
      onSaved: (value) {
        setState(() {
          widget.data!.values[0] = (value ?? "").toString();
        });
      },
      validator: (value) {
        if (value.toString().isEmpty) return "";
        return null;
      },
    );
  }
}
