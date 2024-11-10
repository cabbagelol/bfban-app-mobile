/// 筛选 游戏类型选择面板

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import 'package:bfban/constants/api.dart';

import '../../player/filter/class.dart';
import '../../player/filter/framework.dart';

class SearchSortFilterPanel extends FilterPanelWidget {
  SearchSortFilterPanel({
    Key? key,
  }) : super(key: key);

  @override
  SearchSortFilterPanelState createState() => SearchSortFilterPanelState();
}

class SearchSortFilterPanelState extends State<SearchSortFilterPanel> {
  /// 排行方式
  List sortList = [
    {"value": "default"},
    {"value": "latest"},
    {"value": "mostViewed"},
    {"value": "mostComments"},
  ];

  @override
  void initState() {
    widget.data ??= FilterPanelData(
      values: ["default"],
      names: ["sort"],
    );

    super.initState();
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
                  field.setState(() {
                    field.setValue(value.toString());
                  });

                  setState(() {
                    widget.data!.values[0] = field.value;
                  });
                },
                value: field.value,
                items: sortList.asMap().keys.map<DropdownMenuItem<String>>((index) {
                  Map i = sortList[index];

                  return DropdownMenuItem(
                    value: i["value"].toString(),
                    child: Text(FlutterI18n.translate(context, "search.sort.${i["value"]}")),
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
          widget.data!.values[0] = value as String;
        });
      },
      validator: (value) {
        if (value.toString().isEmpty) return "";
        return null;
      },
    );
  }
}
