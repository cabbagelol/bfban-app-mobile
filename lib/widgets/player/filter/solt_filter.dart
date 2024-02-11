import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import 'class.dart';
import 'framework.dart';

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
    widget.data ??= FilterPanelData(
      values: ["updateTime"],
      names: ["sortBy"],
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
