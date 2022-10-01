import 'dart:convert';

import 'package:bfban/provider/userinfo_provider.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

import 'package:flutter_elui_plugin/elui.dart';
import 'package:bfban/constants/api.dart';
import 'package:bfban/utils/index.dart';
import 'package:bfban/data/index.dart';
import 'package:provider/provider.dart';

class ReplyPage extends StatefulWidget {
  dynamic data;

  ReplyPage({
    Key? key,
    this.data,
  }) : super(key: key);

  @override
  _ReplyPageState createState() => _ReplyPageState();
}

class _ReplyPageState extends State<ReplyPage> {
  final UrlUtil _urlUtil = UrlUtil();

  dynamic _data;

  // 回复
  ReplyStatus replyStatus = ReplyStatus(
    load: false,
    data: ReplyData(
      toCommentId: 0,
      toPlayerId: 0,
      toFloor: -1,
      content: "",
    ),
  );

  @override
  void initState() {
    super.initState();

    if (widget.data.toString().isEmpty) return;
    dynamic _data = jsonDecode(widget.data);
    if (_data["toCommentId"] != null) replyStatus.data!.toCommentId = _data["toCommentId"];
    if (_data["toPlayerId"] != null) replyStatus.data!.toPlayerId = _data["toPlayerId"];
    if (_data["toFloor"] != null) replyStatus.data!.toFloor = _data["toFloor"];
  }

  /// [Response]
  /// 回复
  void _onReply(isLogin) async {
    if (!isLogin) {
      EluiMessageComponent.warning(context)(
        child: const Text("\u8bf7\u767b\u5f55"),
      );
      return;
    }

    if (replyStatus.data!.content == "") {
      EluiMessageComponent.warning(context)(
        child: const Text("\u8bf7\u586b\u5199\u56de\u590d\u5185\u5bb9"),
      );
      return;
    }

    setState(() {
      replyStatus.load = true;
    });

    // 过滤空数据
    dynamic data = replyStatus.data!.toMap;
    data["data"].removeWhere((key, value) => value.toString().isEmpty);

    Response result = await Http.request(
      Config.httpHost["player_reply"],
      data: replyStatus.data!.toMap,
      method: Http.POST,
    );

    if (result.data["success"] == 1) {
      EluiMessageComponent.success(context)(
        child: const Text("\u53d1\u5e03\u6210\u529f"),
      );
      Navigator.pop(context, "cheatersCardTypes");
    } else {
      EluiMessageComponent.error(context)(
        child: const Text("\u53d1\u5e03\u5931\u8d25\u4e86 Q^Q"),
      );
    }

    setState(() {
      replyStatus.load = false;
    });
  }

  /// [Event]
  /// 打开编辑页面
  _opEnRichEdit() async {
    await Storage().set("com.bfban.richedit", value: replyStatus.data!.content.toString());

    _urlUtil.opEnPage(context, "/richedit", transition: TransitionType.cupertino).then((data) {
      /// 按下确认储存富文本编写的内容
      if (data["code"] == 1) {
        setState(() {
          replyStatus.data!.content = data["html"];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserInfoProvider>(
      builder: (BuildContext context, data, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            actions: <Widget>[
              replyStatus.load!
                  ? const Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: ELuiLoadComponent(
                        type: "line",
                        size: 20,
                        lineWidth: 2,
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.done),
                      onPressed: () => _onReply(data.isLogin),
                    ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              /// S 理由
              EluiCellComponent(
                title: "理由",
                cont: Offstage(
                  // offstage: reportStatus.param!.data!["description"].toString().isNotEmpty,
                  child: Wrap(
                    spacing: 5,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: const <Widget>[
                      Icon(
                        Icons.warning,
                        color: Colors.yellow,
                        size: 15,
                      ),
                      Text(
                        "请填写有力证据的举报内容",
                        style: TextStyle(
                          color: Colors.yellow,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: Card(
                  elevation: 10,
                  clipBehavior: Clip.hardEdge,
                  child: GestureDetector(
                    child: Container(
                      color: Colors.white38,
                      constraints: const BoxConstraints(
                        minHeight: 150,
                        maxHeight: 280,
                      ),
                      padding: EdgeInsets.zero,
                      child: Stack(
                        children: <Widget>[
                          Text(replyStatus.data!.content.toString()),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              height: 100,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.transparent, Colors.black54],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            left: 0,
                            bottom: 0,
                            right: 0,
                            child: Container(
                              color: const Color.fromRGBO(0, 0, 0, 0.2),
                              child: Center(
                                child: TextButton.icon(
                                  icon: const Icon(Icons.edit),
                                  label: Text(
                                    replyStatus.data!.content.toString().isEmpty ? "填写回复" : "编辑",
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  onPressed: () {
                                    _opEnRichEdit();
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              /// E 理由
            ],
          ),
        );
      },
    );
  }
}
