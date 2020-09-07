/// 富文本页面

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rich_html/main.dart';

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
  List<RichHtmlLabelType> _richhtmlSupport;
  MySimpleRichHtmlController _richhtmlController;

  Map data;

  @override
  void initState() {
    data = jsonDecode(widget.data);

    setState(() {
      data["isText"] = (data["isText"] ?? false);

      _richhtmlSupport = [
        RichHtmlLabelType.IMAGE,
        RichHtmlLabelType.P,
        RichHtmlLabelType.TEXT,
      ];

      _richhtmlController = MySimpleRichHtmlController(
        context,
        theme: RichHtmlTheme(
          mainColor: Colors.deepPurple,
          viewTheme: RichHtmlViewTheme(
            color: Colors.white,
          )
        ),
      )..html = Uri.decodeComponent(
          jsonDecode(widget.data)["html"],
        );
    });
    super.initState();
  }

  /// 确认

  void _onSubmit() {
    Navigator.pop(
      context,
      {
        "code": 1,
        "html": data["isText"] ? _richhtmlController.text : _richhtmlController.html,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.pop(
              context,
              {"code": 2},
            );
          },
        ),
        title: Text("编辑"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.done),
            onPressed: () => _onSubmit(),
          ),
        ],
      ),
      body: RichHtml(
        _richhtmlController,
        richhtmlSupportLabel: _richhtmlSupport,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              width: 1,
              color: Color(0xfff2f2f2),
            ),
          ),
        ),
        child: RichHtmlToolbar(
          _richhtmlController,
          children: <RichHtmlTool>[
            RichHtmlToolSizedBox(
              flex: 1,
            ),
           !data["isText"] ? RichHtmlToolImages() : RichHtmlToolSizedBox(),
          ],
        ),
      ),
    );
  }
}
