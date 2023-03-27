import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/_tag/tag.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class CheatMethodsTagWidget extends StatefulWidget {
  late List data;

  CheatMethodsTagWidget({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  State<CheatMethodsTagWidget> createState() => _CheatMethodsTagWidgetState();
}

class _CheatMethodsTagWidgetState extends State<CheatMethodsTagWidget> {
  List methods = [];

  @override
  void initState() {
    super.initState();

    methods = widget.data;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 5,
      spacing: 5,
      children: methods.isEmpty ? [
        EluiTagComponent(
          color: EluiTagType.none,
          round: true,
          size: EluiTagSize.no2,
          theme: EluiTagTheme(
            backgroundColor: Theme.of(context).cardColor,
            textColor: Theme.of(context).textTheme.subtitle1!.color!,
          ),
          value: "N/A",
        )
      ] : methods.map<Widget>((i) {
        return Tooltip(
          message: FlutterI18n.translate(context, "cheatMethods.$i.describe"),
          child: EluiTagComponent(
            color: EluiTagType.none,
            size: EluiTagSize.no2,
            theme: EluiTagTheme(
              backgroundColor: Theme.of(context).cardColor,
              textColor: Theme.of(context).textTheme.subtitle1!.color!,
            ),
            value: FlutterI18n.translate(context, "cheatMethods.$i.title"),
            onTap: () {},
          ),
        );
      }).toList(),
    );
  }
}
