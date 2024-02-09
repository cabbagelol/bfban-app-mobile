import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../../../component/_filter/class.dart';
import '../../../component/_filter/framework.dart';

class SoltFilterPanel extends FilterPanelWidget {
  SoltFilterPanel({
    Key? key,
  }) : super(key: key);

  @override
  _SoltFilterPanelState createState() => _SoltFilterPanelState();
}

class _SoltFilterPanelState extends State<SoltFilterPanel> {
  /// solt
  List<Map<String, String>> soltList = [
    {"value": "createTime"},
    {"value": "updateTime"},
    {"value": "viewNum"},
    {"value": "commentsNum"},
  ];

  @override
  void initState() {
    super.initState();

    widget.data = FilterPanelData(
      value: "updateTime",
      name: "sortBy",
    );

    widget.isInit = true;
  }

  @override
  void didUpdateWidget(covariant SoltFilterPanel oldWidget) {
    widget.data ??= FilterPanelData(
      value: "updateTime",
      name: "sortBy",
    );

    super.didUpdateWidget(oldWidget);
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
    return FormField(
      builder: (FormFieldState field) {
        return Column(
          children: [
            Container(
              child: Card(
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
                          widget.data!.value = field.value;
                        });
                      },
                      value: field.value,
                      items: soltList.asMap().keys.map<DropdownMenuItem<String>>((index) {
                        Map i = soltList[index];

                        return DropdownMenuItem(
                          value: i["value"].toString(),
                          child: Text(FlutterI18n.translate(context, "list.filters.sortBy.${i["value"]}")),
                        );
                      }).toList(),
                    ),
                  ],
                ),
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
