/// 富文本页面

import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:bfban/widgets/richText.dart';

class richEditPage extends StatefulWidget {
  final data;

  richEditPage({
    this.data,
  });

  @override
  _richEditPageState createState() => _richEditPageState();
}

class _richEditPageState extends State<richEditPage> {
  SimpleRichEditController controller;

  Map data;

  @override
  void initState() {
    data = jsonDecode(widget.data);

    /// 返回的值是否为存文字
    /// data["isText"]

    setState(() {
      data["isText"] = (data["isText"] ?? false);

      controller = SimpleRichEditController(
        context: context,
        isImageIcon: (data["isText"] ?? false) ? false : true,
        isVideoIcon: false,
      );

      controller.generateView(
        Uri.decodeComponent(
          jsonDecode(widget.data)["html"],
        ),
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.white,
            size: 25,
          ),
          onPressed: () {
            Navigator.pop(
              context,
              {"code": 2},
            );
          },
        ),
        actions: <Widget>[
          RaisedButton(
            color: Color(0xff364e80),
            child: Text(
              "确认",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            onPressed: () {
              Navigator.pop(
                context,
                {
                  "code": 1,
                  "html": data["isText"] ? controller.generateText() : controller.generateHtml(),
                },
              );
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.only(
          top: 20,
        ),
        child: richText(
          controller: controller,
        ),
      ),
    );
  }
}
