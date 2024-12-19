import 'package:flutter/material.dart';

class FileWidgetUI extends StatefulWidget {
  final dynamic i;

  final Function onSucceed;

  const FileWidgetUI({
    super.key,
    this.i,
    required this.onSucceed,
  });

  @override
  FileWidgetUIState createState() => FileWidgetUIState();
}

class FileWidgetUIState extends State<FileWidgetUI> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.only(
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
