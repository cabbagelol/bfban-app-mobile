/// 回复

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_plugin_elui/elui.dart';

import 'package:bfban/utils/index.dart';
import 'package:bfban/widgets/richText.dart';

class replyPage extends StatefulWidget {
  final data;

  replyPage({
    this.data,
  });

  @override
  _replyPageState createState() => _replyPageState();
}

class _replyPageState extends State<replyPage> {
  SimpleRichEditController controller;

  Map replyInfo = {
    "content": "",
  };

  Map login;

  Map<String, dynamic> data = new Map();

  bool replyLoad = false;

  @override
  void initState() {
    setState(() {
      controller = SimpleRichEditController(
        context: context,
        isImageIcon: true,
        isVideoIcon: false,
      );

      data = json.decode(widget.data);
    });
    super.initState();
  }

  /// 回复
  void _onReply() async {
    var _data = new Map();

    login = jsonDecode(await Storage.get("com.bfban.login") ?? '{}');

    replyInfo["content"] = controller.generateHtml();

    if (login == null || login.isEmpty) {
      EluiMessageComponent.warning(context)(
        child: Text("请登录"),
      );
      return;
    }

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
          "toFloor": data["toFloor"],
          "toUserId": data["toUserId"],
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
      color: Color(0xff111b2b),
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(20),
              child: Row(
                children: <Widget>[
                  Text(
                    "回复人:",
                    style: TextStyle(
                      color: Colors.white54,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  EluiTagComponent(
                    value: "@${data["foo"].toString()}",
                    size: EluiTagSize.no4,
                    color: EluiTagColor.primary,
                  ),
                ],
              ),
            ),
//            EluiTextareaComponent(
//              placeholder: "请填写回复内容",
//              maxLines: 15,
//              maxLength: 500,
//              onChange: (data) {
//                setState(() {
//                  replyInfo["content"] = data["value"];
//                });
//              },
//            ),
            Expanded(
              flex: 5,
              child: richText(
                controller: controller,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
