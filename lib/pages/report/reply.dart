import 'dart:convert';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';
import 'package:flutter_elui_plugin/elui.dart';

import 'package:bfban/constants/api.dart';
import 'package:bfban/utils/index.dart';
import 'package:bfban/data/index.dart';
import 'package:bfban/provider/userinfo_provider.dart';

import 'package:bfban/component/_captcha/index.dart';

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
      toPlayerId: 0,
      toCommentId: null,
      content: ""
    ),
    captcha: Captcha(
      load: false,
      value: ""
    )
  );

  @override
  void initState() {
    super.initState();

    if (widget.data.toString().isEmpty) return;
    dynamic _data = jsonDecode(widget.data);
    if (_data["toCommentId"] != null) replyStatus.data!.toCommentId = _data["toCommentId"];
    if (_data["toPlayerId"] != null) replyStatus.data!.toPlayerId = _data["toPlayerId"];
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

    if (replyStatus.data!.content!.isEmpty && replyStatus.captcha!.value.isEmpty) {
      EluiMessageComponent.warning(context)(
        child: const Text("\u8bf7\u586b\u5199\u56de\u590d\u5185\u5bb9"),
      );
      return;
    }

    setState(() {
      replyStatus.load = true;
    });

    // 过滤空数据
    dynamic data = replyStatus.toMap;
    data["data"].removeWhere((key, value) => value.toString().isEmpty);

    Response result = await Http.request(
      Config.httpHost["player_reply"],
      data: replyStatus.toMap,
      method: Http.POST,
    );

    if (result.data["success"] == 1) {
      EluiMessageComponent.success(context)(
        child: Text(result.data["message"]),
      );
      Navigator.pop(context, "cheatersCardTypes");
    } else {
      EluiMessageComponent.error(context)(
        child: Text(result.data["code"]),
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
                        color: Colors.white,
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
                title: "",
                cont: Offstage(
                  // offstage: reportStatus.param!.data!["description"].toString().isNotEmpty,
                  child: Wrap(
                    spacing: 5,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      const Icon(
                        Icons.warning,
                        color: Colors.yellow,
                        size: 15,
                      ),
                      Text(
                        FlutterI18n.translate(context, "detail.info.giveOpinion"),
                        style: const TextStyle(
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
                          Html(data: replyStatus.data!.content),
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
              const SizedBox(
                height: 20,
              ),

              Card(
                clipBehavior: Clip.none,
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: EluiInputComponent(
                  internalstyle: true,
                  placeholder: FlutterI18n.translate(context, "captcha.title"),
                  maxLenght: 4,
                  right: CaptchaWidget(
                    onChange: (Captcha cap) => replyStatus.captcha = cap,
                  ),
                  onChange: (data) => replyStatus.captcha!.value = data["value"],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
