/// 回复

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_plugin_elui/elui.dart';
// import 'package:flutter_rich_html/main.dart';

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
  // List<RichHtmlLabelType> _richhtmlSupport;
  // MySimpleRichHtmlController _richhtmlController;

  Map replyInfo = {
    "content": "",
  };

  Map login;

  Map<String, dynamic> data = new Map();

  bool replyLoad = false;

  @override
  void initState() {
    setState(() {
      // _richhtmlSupport = [
      //   RichHtmlLabelType.IMAGE,
      //   RichHtmlLabelType.P,
      //   RichHtmlLabelType.TEXT,
      // ];

      // _richhtmlController = MySimpleRichHtmlController(
      //   context,
      //   theme: RichHtmlTheme(
      //     mainColor: Colors.deepPurple,
      //     viewTheme: RichHtmlViewTheme(
      //       color: Colors.white,
      //     ),
      //   ),
      // )..html = "";

      data = json.decode(widget.data);
    });
    super.initState();
  }

  /// 回复
  void _onReply() async {
    var _data = new Map();

    login = jsonDecode(await Storage.get("com.bfban.login") ?? '{}');

    // replyInfo["content"] = _richhtmlController.html;

    if (login == null || login.isEmpty) {
      EluiMessageComponent.warning(context)(
        child: Text("\u8bf7\u767b\u5f55"),
      );
      return;
    }

    if (replyInfo["content"] == "") {
      EluiMessageComponent.warning(context)(
        child: Text("\u8bf7\u586b\u5199\u56de\u590d\u5185\u5bb9"),
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

    if (result.data["error"] == 0) {
      EluiMessageComponent.success(context)(
        child: Text("\u53d1\u5e03\u6210\u529f"),
      );
      Navigator.pop(context, "cheatersCardTypes");
    } else {
      EluiMessageComponent.error(context)(
        child: Text("\u53d1\u5e03\u5931\u8d25\u4e86 Q^Q"),
      );
    }

    setState(() {
      replyLoad = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text("\u56de\u590d"),
        actions: <Widget>[
          replyLoad
              ? Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: ELuiLoadComponent(
                    type: "line",
                    color: Theme.of(context).primaryTextTheme.headline1.color,
                    size: 20,
                    lineWidth: 2,
                  ),
                )
              : IconButton(
                  icon: Icon(Icons.done),
                  onPressed: () => this._onReply(),
                ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(20),
            child: Row(
              children: <Widget>[
                Text(
                  "\u56de\u590d\u4eba:",
                  style: TextStyle(
                    color: Colors.black54,
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
          SizedBox(
            child: Container(
              height: 1,
              color: Color(0xfff2f2f2),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              color: Colors.white,
              // child: RichHtml(
              //   _richhtmlController,
              //   richhtmlSupportLabel: _richhtmlSupport,
              // ),
            ),
          ),
        ],
      ),
    );
  }
}
