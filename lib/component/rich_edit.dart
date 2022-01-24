// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';

class FileWidgetUI extends StatefulWidget {
  final i;

  final Function onSucceed;

  FileWidgetUI({Key? key,
    this.i,
    required this.onSucceed,
  }) : super(key: key);

  @override
  _FileWidgetUIState createState() => _FileWidgetUIState();
}

class _FileWidgetUIState extends State<FileWidgetUI> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.only(
          top: 20,
          bottom: 20,
        ),
        child: Center(
          child: Wrap(
            spacing: 10,
            children: <Widget>[
              Icon(
                widget.i["icon"],
                size: 20,
                color: Colors.black,
              ),
              Text(widget.i["name"]),
            ],
          ),
        ),
      ),
      onTap: () async {
        widget.onSucceed();
      },
    );
  }
}
