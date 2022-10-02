import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class actionsFilterWidget extends StatelessWidget {
  final Function? onReset;
  final Function? onChange;

  const actionsFilterWidget({
    Key? key,
    this.onReset,
    this.onChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ButtonBar(
        alignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        buttonAlignedDropdown: true,
        overflowButtonSpacing: 10.0,
        buttonMinWidth: 100,
        buttonHeight: 100,
        buttonTextTheme: ButtonTextTheme.primary,
        buttonPadding: EdgeInsets.zero,
        children: <Widget>[
          TextButton(
            child: Text(
              FlutterI18n.translate(context, "basic.button.reset"),
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () => onReset!(),
          ),
          TextButton(
            child: Text(
              FlutterI18n.translate(context, "basic.button.commit"),
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () => onChange!(),
          ),
        ],
      ),
    );
  }
}
