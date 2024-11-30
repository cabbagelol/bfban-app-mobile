import 'dart:convert';

import 'package:bfban/component/_loading/index.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';
import 'package:flutter_elui_plugin/elui.dart';

import 'package:bfban/constants/api.dart';
import 'package:bfban/utils/index.dart';
import 'package:bfban/data/index.dart';
import 'package:bfban/provider/userinfo_provider.dart';

import 'package:bfban/component/_captcha/index.dart';

import '../../component/_customReply/customReply.dart';
import '../../component/_html/html.dart';

class ReplyPage extends StatefulWidget {
  final dynamic data;

  const ReplyPage({
    super.key,
    this.data,
  });

  @override
  ReplyPageState createState() => ReplyPageState();
}

class ReplyPageState extends State<ReplyPage> {
  final UrlUtil _urlUtil = UrlUtil();

  final Storage _storage = Storage();

  final GlobalKey<FormState> _replyFormKey = GlobalKey<FormState>();

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
    try {
      FormState? reportFormKey = _replyFormKey.currentState;
      bool validate = reportFormKey!.validate();
      bool isLogin = ProviderUtil().ofUser(context).isLogin;

      if (!validate) return;
      reportFormKey.save();

      if (!isLogin) {
        EluiMessageComponent.warning(context)(
          child: Text(FlutterI18n.translate(context, "detail.info.replyManual4")),
        );
        return;
      }

      setState(() {
        replyStatus.load = true;
      });

      // 过滤空数据
      dynamic data = replyStatus.parame!.toMap;
      data["data"].removeWhere((key, value) => value.toString().isEmpty);

      Response result = await HttpToken.request(
        Config.httpHost["player_reply"],
        data: replyStatus.parame!.toMap,
        method: Http.POST,
      );

      dynamic d = result.data;

      if (result.data["success"] == 1) {
        EluiMessageComponent.success(context)(
          child: Text(FlutterI18n.translate(
            context,
            "appStatusCode.${d["code"].replaceAll(".", "_")}",
            translationParams: {"message": d["message"] ?? ""},
          )),
        );

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
        child: Text(FlutterI18n.translate(
          context,
          "appStatusCode.${d["code"].replaceAll(".", "_")}",
          translationParams: {"message": d["message"] ?? ""},
        )),
        duration: 20000,
      );
    } catch (err) {
      EluiMessageComponent.error(context)(
        child: Text(err.toString()),
      );
    }
  }

  /// [Event]
  /// 打开编辑页面
  _opEnRichEdit({updateValue}) async {
    await _storage.set("richedit", value: updateValue ?? replyStatus.parame!.content.toString());

    Map data = await _urlUtil.opEnPage(context, "/richedit", transition: TransitionType.cupertino);

    /// 按下确认储存富文本编写的内容
    if (data["code"] == 1) {
      return data["html"];
    }

    return "";
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
                      child: LoadingWidget(
                        size: 20,
                        color: Theme.of(context).progressIndicatorTheme.color!,
                      ),
                    )
                  : IconButton(
                padding: const EdgeInsets.all(16),
                      icon: const Icon(Icons.done),
                      onPressed: () => _onReply(),
                    ),
            ],
          ),
          body: Form(
            key: _replyFormKey,
            child: ListView(
              children: [
                EluiTipComponent(
                  type: EluiTip.warning,
                  child: Text(FlutterI18n.translate(context, "detail.info.appealManual1")),
                ),

                /// S 理由
                FormField(
                  builder: (FormFieldState field) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      color: field.isValid ? Colors.transparent : Theme.of(context).colorScheme.error.withOpacity(.2),
                      child: Column(
                        children: [
                          EluiCellComponent(
                            title: FlutterI18n.translate(context, "report.labels.description"),
                            cont: field.isValid
                                ? null
                                : Icon(
                                    Icons.help,
                                    color: Theme.of(context).colorScheme.error,
                                    size: 15,
                                  ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 15),
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Card(
                              clipBehavior: Clip.hardEdge,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(3),
                                side: BorderSide(
                                  color: field.isValid ? Theme.of(context).dividerColor : Theme.of(context).colorScheme.error,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  InkWell(
                                    child: Container(
                                      constraints: const BoxConstraints(minHeight: 100),
                                      child: Opacity(
                                        opacity: field.value.isNotEmpty ? 1 : .5,
                                        child: HtmlCore(data: field.value.isNotEmpty ? field.value : FlutterI18n.translate(context, "app.richedit.placeholder")),
                                      ),
                                    ),
                                    onTap: () async {
                                      String html = await _opEnRichEdit(updateValue: field.value);
                                      field.didChange(html);
                                    },
                                  ),
                                  const Divider(height: 1),
                                  CustomReplyWidget(
                                    type: CustomReplyType.general,
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
                        ],
                      ),
                    );
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  initialValue: replyStatus.parame!.content,
                  onSaved: (value) {
                    setState(() {
                      replyStatus.parame!.content = value as String?;
                    });
                  },
                  validator: (value) {
                    if (value.toString().length < 0 && value.toString().length > 5000) return "";
                    if (value.toString().isEmpty) return "";
                    return null;
                  },
                ),

                /// E 理由

                FormField(
                  builder: (FormFieldState field) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      color: field.isValid ? Colors.transparent : Theme.of(context).colorScheme.error.withOpacity(.2),
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3),
                          side: BorderSide(
                            color: field.isValid ? Theme.of(context).dividerColor : Theme.of(context).colorScheme.error,
                            width: 1,
                          ),
                        ),
                        child: EluiInputComponent(
                          theme: EluiInputTheme(textStyle: Theme.of(context).textTheme.bodyMedium),
                          textInputAction: TextInputAction.done,
                          onChange: (data) {
                            field.didChange(data["value"]);
                          },
                          right: CaptchaWidget(
                            onChange: (Captcha captcha) => replyStatus.parame!.setCaptcha(captcha),
                          ),
                          maxLenght: 4,
                          placeholder: FlutterI18n.translate(context, "captcha.title"),
                        ),
                      ),
                    );
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  initialValue: replyStatus.parame!.value,
                  onSaved: (value) {
                    setState(() {
                      replyStatus.parame!.value = value as String;
                    });
                  },
                  validator: (value) {
                    if (value.toString().isEmpty) return "";
                    return null;
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
