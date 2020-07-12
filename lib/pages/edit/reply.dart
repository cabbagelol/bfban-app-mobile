import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_plugin_elui/elui.dart';
import 'package:html_editor/html_editor.dart';

class replyPage extends StatefulWidget {
  @override
  _replyPageState createState() => _replyPageState();
}

class _replyPageState extends State<replyPage> {
  static GlobalKey _keyEditor;

  @override
  void initState() {
    super.initState();

    GlobalKey<HtmlEditorState> _keyEditor = GlobalKey();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            'assets/images/bk-companion.jpg',
          ),
          fit: BoxFit.fitHeight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "举报作弊",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        body: ListView(
          children: <Widget>[
            HtmlEditor(
              hint: "Your text here...",
              //value: "text content initial, if any",
              key: _keyEditor,
              height: 400,
            ),
          ],
        ),
      ),
    );
  }
}

