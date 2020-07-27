/// 回复

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_plugin_elui/elui.dart';
import 'package:html_editor/html_editor.dart';

import 'package:bfban/utils/index.dart';

class replyPage extends StatefulWidget {
  final data;

  replyPage({
    this.data,
  });

  @override
  _replyPageState createState() => _replyPageState();
}

class _replyPageState extends State<replyPage> {
  Map replyInfo = {
    "content": "",
  };

  dynamic login;

  Map<String, dynamic> data = new Map();

  bool replyLoad = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      data = json.decode(widget.data);
    });
  }

  /// 回复
  void _onReply() async {
    var _data = new Map();

    login = jsonDecode(await Storage.get("com.bfban.login"));

    if (replyInfo["content"] == "") {
      EluiMessageComponent.warning(context)(
        child: Text("请填写回复内容"),
      );
      return;
    }

    switch (data["type"].toString()) {
      case "0":

        /// 追加
        _data = {};
        break;
      case "1":

        /// 帖子回复
        _data = {
//          "toFloor": "",
//          "toUserId": "",
        };
        break;
    }

    _data.addAll({
      "cheaterId": data["id"],
      "originUserId": data["originUserId"],
      "content": replyInfo["content"],
      "userId": login["userId"],
    });

    setState(() {
      replyLoad = true;
    });

    Response<dynamic> result = await Http.request(
      'api/cheaters/reply',
      data: _data,
      method: Http.POST,
    );

    print(result);

    if (result.data["error"] == 0) {
      EluiMessageComponent.success(context)(
        child: Text("发布成功"),
      );
      Navigator.pop(context, "cheatersCardTypes");
    } else {
      EluiMessageComponent.error(context)(
        child: Text("发布失败了 Q^Q"),
      );
    }

    setState(() {
      replyLoad = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xff111b2b),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Color(0xff364e80),
          elevation: 0,
          centerTitle: true,
          title: Text(
            "回复",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          actions: <Widget>[
            replyLoad
                ? RaisedButton(
                    child: Icon(
                      Icons.update,
                      color: Colors.white,
                    ),
                  )
                : RaisedButton(
                    color: Color(0xff364e80),
                    child: Text(
                      "提交",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    onPressed: () => this._onReply(),
                  )
          ],
        ),
        body: ListView(
          children: <Widget>[
//            Expanded(
////              flex: 1,
////              child: HtmlEditor(
////                hint: "",
////                decoration: BoxDecoration(
////                  color: Colors.black12,
////                ),
////                //value: "text content initial, if any",
////                key: _keyEditor,
////                showBottomToolbar: false,
////                height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - 150,
////              ),
////            )
            Container(
              padding: EdgeInsets.all(20),
              child: Text(
                "@${data["foo"].toString()}", // ${widget.data["foo"]??"未知"}
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            EluiTextareaComponent(
              placeholder: "请填写回复内容",
              maxLines: 15,
              maxLength: 500,
              onChange: (data) {
                setState(() {
                  replyInfo["content"] = data["value"];
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
