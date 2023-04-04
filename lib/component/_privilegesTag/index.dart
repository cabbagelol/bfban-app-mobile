import 'package:bfban/utils/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/_tag/tag.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class PrivilegesTagWidget extends StatefulWidget {
  List<dynamic>? data;

  PrivilegesTagWidget({
    Key? key,
    this.data,
  }) : super(key: key);

  @override
  State<PrivilegesTagWidget> createState() => _PrivilegesTagWidgetState();
}

class _PrivilegesTagWidgetState extends State<PrivilegesTagWidget> {
  List? privileges = [];

  @override
  void initState() {
    super.initState();
    dynamic originalPrivilege = ProviderUtil().ofApp(context).conf.data.privilege!;

    if (originalPrivilege["child"] != null) {
      List privilegeArray = List.from(originalPrivilege!["child"]).where((i) {
        return widget.data!.isEmpty ? originalPrivilege.contains(i["value"]) : widget.data!.contains(i["value"]);
      }).toList();

      setState(() {
        privileges = privilegeArray;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 5,
      spacing: 5,
      children: privileges!.map<Widget>((i) {
        return EluiTagComponent(
          color: EluiTagType.none,
          size: EluiTagSize.no2,
          theme: EluiTagTheme(
            backgroundColor: Theme.of(context).colorScheme.primary!.withOpacity(.2),
          ),
          value: FlutterI18n.translate(context, "basic.privilege.${i["value"]}"),
        );
      }).toList(),
    );
  }
}
