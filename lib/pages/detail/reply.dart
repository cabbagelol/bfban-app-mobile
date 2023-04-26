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

import '../../component/_customReply/customReply.dart';

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

  final Storage _storage = Storage();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // 回复
  ReplyStatus replyStatus = ReplyStatus(
    load: false,
    parame: ReplyStatusParame(
      toPlayerId: 0,
      toCommentId: null,
      content: "",
    ),
  );

  @override
  void initState() {
    super.initState();

    if (jsonDecode(widget.data).isEmpty) return;
    dynamic data = jsonDecode(widget.data);
    if (data["toCommentId"] != null) replyStatus.parame!.toCommentId = data["toCommentId"];
    if (data["toPlayerId"] != null) replyStatus.parame!.toPlayerId = data["toPlayerId"];
  }

  /// [Response]
  /// 回复
  void _onReply() async {
    ReplyStatusParame parame = replyStatus.parame!;
    bool isLogin = ProviderUtil().ofUser(context).isLogin;

    if (!isLogin) {
      EluiMessageComponent.warning(context)(
        child: Text(FlutterI18n.translate(context, "detail.info.replyManual4")),
      );
      return;
    }

    if (parame.content!.isEmpty && parame.value.isEmpty) {
      EluiMessageComponent.warning(context)(
        child: Text(FlutterI18n.translate(context, "signup.fillIn")),
      );
      return;
    }

    setState(() {
      replyStatus.load = true;
    });

    // 过滤空数据
    dynamic data = replyStatus.parame!.toMap;
    data["data"].removeWhere((key, value) => value.toString().isEmpty);

    Response result = await Http.request(
      Config.httpHost["player_reply"],
      data: replyStatus.parame!.toMap,
      method: Http.POST,
    );

    if (result.data["success"] == 1) {
      setState(() {
        replyStatus.load = false;
        Navigator.pop(context, "cheatersCardTypes");
      });
      return;
    }

    setState(() {
      replyStatus.load = false;
    });

    EluiMessageComponent.error(context)(
      child: Text("${result.data["code"]}:${result.data["message"]}"),
    );
  }

  /// [Event]
  /// 打开编辑页面
  _opEnRichEdit() async {
    await _storage.set("richedit", value: replyStatus.parame!.content.toString());

    _urlUtil.opEnPage(context, "/richedit", transition: TransitionType.cupertino).then((data) {
      /// 按下确认储存富文本编写的内容
      if (data["code"] == 1) {
        setState(() {
          replyStatus.parame!.content = data["html"];
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
                  ? ElevatedButton(
                      onPressed: () {},
                      child: ELuiLoadComponent(
                        type: "line",
                        lineWidth: 2,
                        size: 20,
                        color: Theme.of(context).appBarTheme.iconTheme!.color!,
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.done),
                      onPressed: () => _onReply(),
                    ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              children: [
                EluiTipComponent(
                  type: EluiTip.warning,
                  child: Text(FlutterI18n.translate(context, "detail.info.appealManual1")),
                ),

                /// S 理由
                EluiCellComponent(
                  title: "",
                  cont: replyStatus.parame!.content!.isEmpty
                      ? const Icon(
                          Icons.warning,
                          color: Colors.yellow,
                          size: 15,
                        )
                      : Container(),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  child: Card(
                    clipBehavior: Clip.hardEdge,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                      side: BorderSide(
                        color: Theme.of(context).dividerTheme.color!,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          color: Colors.white38,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minHeight: 100,
                            maxHeight: 180,
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: <Widget>[
                              Html(data: replyStatus.parame!.content),
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
                                      label: const Text(
                                        "Edit",
                                        style: TextStyle(fontSize: 18),
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
                        const Divider(height: 1),
                        CustomReplyWidget(
                          type: CustomReplyType.General,
                          onChange: (String selectTemp) {
                            setState(() {
                              replyStatus.parame!.content = selectTemp;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                /// E 理由
                const SizedBox(
                  height: 20,
                ),

                EluiInputComponent(
                  internalstyle: true,
                  placeholder: FlutterI18n.translate(context, "captcha.title"),
                  maxLenght: 4,
                  theme: EluiInputTheme(textStyle: Theme.of(context).textTheme.bodyMedium),
                  right: CaptchaWidget(
                    onChange: (Captcha captcha) => replyStatus.parame!.setCaptcha(captcha),
                  ),
                  onChange: (data) => replyStatus.parame!.value = data["value"],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
