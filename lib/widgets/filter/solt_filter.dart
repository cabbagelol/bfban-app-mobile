import 'package:bfban/constants/api.dart';
import 'package:flutter/material.dart';

import '../../component/_filter/class.dart';
import '../../component/_filter/framework.dart';

class SoltFilterPanel extends FilterPanelWidget {
  SoltFilterPanel({
    Key? key,
  }) : super(key: key);

  @override
  _SoltFilterPanelState createState() => _SoltFilterPanelState();
}

class _SoltFilterPanelState extends State<SoltFilterPanel> {
  /// solt
  List soltList = [
    {"value": "createTime", "name": "创建时间"},
    {"value": "updateTime", "name": "更新时间"},
    {"value": "viewNum", "name": "围观次数"},
    {"value": "commentNum", "name": "回复次数"},
  ];

  @override
  void initState() {
    super.initState();

    if (!widget.isInit) {
      widget.data = FilterPanelData(
        value: "updateTime",
        name: "slot",
      );
    }

    widget.isInit = true;
  }

  /// [Event]
  /// 设置单选下标
  void _setIndex(int index) {
    setState(() {
      widget.data!.value = soltList[index]["value"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: soltList.asMap().keys.map((index) {
        Map i = soltList[index];

        return GestureDetector(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            color: widget.data!.value == i["value"] ? Theme.of(context).textSelectionTheme.selectionColor : Theme.of(context).scaffoldBackgroundColor.withOpacity(.9),
            child: Center(
              child: Center(
                child: Text(
                  i["name"].toString(),
                  style: TextStyle(
                    color: widget.data!.value == i["value"] ? Theme.of(context).textTheme.bodyText1!.color : Theme.of(context).textTheme.subtitle2!.color,
                    fontWeight: widget.data!.value == i["value"] ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
          onTap: () => _setIndex(index),
        );
      }).toList(),
    );
  }
}
