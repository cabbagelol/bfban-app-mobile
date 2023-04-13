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
      runSpacing: 3,
      spacing: 3,
      children: methods.isEmpty
          ? [
              EluiTagComponent(
                color: EluiTagType.none,
                size: EluiTagSize.no2,
                theme: EluiTagTheme(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  textColor: Theme.of(context).textTheme.displayMedium!.color!,
                ),
                value: "N/A",
              )
            ]
          : methods.map<Widget>((i) {
              return Tooltip(
                message: FlutterI18n.translate(context, "cheatMethods.$i.describe"),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    border: Border.all(color: Theme.of(context).dividerTheme.color!),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    FlutterI18n.translate(context, "cheatMethods.$i.title"),
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ),
              );
            }).toList(),
    );
  }
}
