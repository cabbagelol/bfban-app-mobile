import 'package:bfban/component/_loading/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/elui.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

import '/utils/index.dart';
import '/constants/api.dart';
import '/data/index.dart';
import '/component/_privilegesTag/index.dart';
import '/component/_customReply/customReply.dart';
import '/component/_html/html.dart';
import '/widgets/edit/game_type_radio.dart';

class JudgementPage extends StatefulWidget {
  final String? id;

  const JudgementPage({
    super.key,
    this.id,
  });

  @override
  JudgementPageState createState() => JudgementPageState();
}

class JudgementPageState extends State<JudgementPage> {
  final UrlUtil _urlUtil = UrlUtil();

  final Util _util = Util();

  final Storage _storage = Storage();

  final List _reportInfoCheatMethods = [];

  final GlobalKey<FormState> _judgementFormKey = GlobalKey<FormState>();

  /// 裁判
  ManageStatus manageStatus = ManageStatus(
    load: false,
    parame: ManageParame(
      content: "",
      action: "",
      cheatMethods: [],
      toPlayerId: "",
    ),
  );

  final List _cheatingTypes = [];

  @override
  void initState() {
    super.initState();
    AppInfoProvider app = ProviderUtil().ofApp(context);
    Map cheatMethodsGlossary = app.conf.data.cheatMethodsGlossary!;

    setState(() {
      manageStatus.parame!.toPlayerId = widget.id;
      if (app.conf.data.action!["child"] != null) manageStatus.parame!.action = app.conf.data.action!["child"][0]["value"];

      if (cheatMethodsGlossary["child"] != null) {
        cheatMethodsGlossary["child"].forEach((i) {
          setState(() {
            String key = _util.queryCheatMethodsGlossary(i["value"]);
            _cheatingTypes.add({"value": key, "select": false});
          });
        });
      }
    });
  }

  /// [Response]
  /// 发布判决
  void _onRelease() async {
    try {
      FormState? judgementFormKey = _judgementFormKey.currentState;
      bool validate = judgementFormKey!.validate();

      if (!validate) return;
      judgementFormKey.save();

      setState(() {
        manageStatus.load = true;
      });

      Response result = await HttpToken.request(
        Config.httpHost["player_judgement"],
        method: Http.POST,
        data: manageStatus.parame!.toMap,
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
          manageStatus.load = false;
          Navigator.pop(context);
        });
        return;
      }

      setState(() {
        manageStatus.load = false;
      });

      EluiMessageComponent.error(context)(
        child: Text(FlutterI18n.translate(
          context,
          "appStatusCode.${d["code"].replaceAll(".", "_")}",
          translationParams: {"message": d["message"] ?? ""},
        )),
        duration: 3000,
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
    await _storage.set("richedit", value: updateValue ?? manageStatus.parame!.content.toString());

    Map data = await _urlUtil.opEnPage(context, "/richedit");

    /// 按下确认储存富文本编写的内容
    if (data["code"] == 1) {
      return data["html"];
    }

    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(FlutterI18n.translate(context, "detail.info.judgement")),
        actions: [
          manageStatus.load!
              ? ElevatedButton(
            onPressed: () {},
                  child: LoadingWidget(
                    size: 20,
              color: Theme.of(context).progressIndicatorTheme.color!,
            ),
          )
              : IconButton(
            padding: const EdgeInsets.all(16),
            onPressed: () => _onRelease(),
            icon: const Icon(Icons.done),
          ),
        ],
      ),
      body: Consumer<AppInfoProvider>(
        builder: (BuildContext context, AppInfoProvider appInfo, Widget? child) {
          return Form(
            key: _judgementFormKey,
            child: ListView(
              children: [

                /// S 处理意见
                FormField(
                  builder: (FormFieldState field) {
                    return Column(
                      children: [
                        EluiCellComponent(title: FlutterI18n.translate(context, "detail.judgement.behavior")),
                        if (appInfo.conf.data.action!["child"].length > 0)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 15),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(3),
                                side: BorderSide(
                                  color: Theme.of(context).dividerTheme.color!,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  DropdownButton(
                                    isDense: false,
                                    isExpanded: true,
                                    underline: const SizedBox(),
                                    dropdownColor: Theme.of(context).bottomAppBarTheme.color,
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    style: Theme.of(context).dropdownMenuTheme.textStyle,
                                    onChanged: (value) {
                                      field.setState(() {
                                        field.setValue(value.toString());
                                      });

                                      setState(() {
                                        manageStatus.parame!.action = field.value;
                                      });
                                    },
                                    value: field.value,
                                    items: appInfo.conf.data.action!["child"].map<DropdownMenuItem<String>>((i) {
                                      return DropdownMenuItem(
                                        value: i["value"].toString(),
                                        child: Text(
                                          FlutterI18n.translate(context, "basic.action.${_util.queryAction(i["value"])}.text"),
                                          style: TextStyle(fontSize: FontSize.large.value),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  const Divider(height: 1),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        PrivilegesTagWidget(data: appInfo.conf.data.action!["child"].where((element) => element["value"] == field.value).first["privilege"]),
                                        const SizedBox(height: 5),
                                        Text(
                                          FlutterI18n.translate(context, "basic.action.${_util.queryAction(field.value)}.describe"),
                                          style: TextStyle(fontSize: FontSize.small.value, color: Theme.of(context).textTheme.displaySmall!.color),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  initialValue: manageStatus.parame!.action,
                  onSaved: (value) {
                    setState(() {
                      manageStatus.parame!.action = value as String;
                    });
                  },
                  validator: (value) {
                    if (value.toString().isEmpty) return "";
                    return null;
                  },
                ),

                /// E 处理意见

                const SizedBox(height: 10),

                /// S 作弊方式
                if (["kill", "guilt"].contains(manageStatus.parame!.action!))
                  FormField(
                    builder: (FormFieldState field) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        color: field.isValid ? Colors.transparent : Theme.of(context).colorScheme.error.withOpacity(.2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            EluiCellComponent(title: FlutterI18n.translate(context, "report.labels.cheatMethod")),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                              child: Wrap(
                                spacing: 5,
                                runSpacing: 5,
                                children: _cheatingTypes.map((method) {
                                  return GameTypeRadioWidget(
                                    errorHint: field.isValid,
                                    index: method["select"],
                                    child: Tooltip(
                                      message: FlutterI18n.translate(context, "cheatMethods.${_util.queryCheatMethodsGlossary(method["value"])}.describe"),
                                      child: Text(
                                        FlutterI18n.translate(context, "cheatMethods.${_util.queryCheatMethodsGlossary(method["value"])}.title"),
                                        style: Theme.of(context).chipTheme.labelStyle,
                                      ),
                                    ),
                                    onTap: () {
                                      field.setState(() {
                                        method["select"] = method["select"] != true;

                                        if (method["select"]) {
                                          _reportInfoCheatMethods.add(method["value"]);
                                        } else {
                                          _reportInfoCheatMethods.remove(method["value"]);
                                        }

                                        field.setValue(_reportInfoCheatMethods);
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    initialValue: manageStatus.parame!.cheatMethods,
                    onSaved: (value) {
                      setState(() {
                        manageStatus.parame!.cheatMethods = value as List?;
                      });
                    },
                    validator: (value) {
                      if (["kill", "guilt"].contains(manageStatus.parame!.action!) && manageStatus.parame!.cheatMethods!.isNotEmpty) return "";
                      if (value is List && value.isEmpty) return "";
                      return null;
                    },
                  ),

                /// E 作弊方式

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
                                      field.setState(() {
                                        field.setValue(html);
                                      });
                                    },
                                  ),
                                  const Divider(height: 1),
                                  CustomReplyWidget(
                                    type: CustomReplyType.Judgement,
                                    onChange: (String selectTemp) {
                                      field.setState(() {
                                        field.setValue(selectTemp);
                                      });
                                      setState(() {
                                        manageStatus.parame!.content = selectTemp;
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
                  initialValue: manageStatus.parame!.content,
                  onSaved: (value) {
                    setState(() {
                      manageStatus.parame!.content = value as String?;
                    });
                  },
                  validator: (value) {
                    if (value.toString().isEmpty) return "";
                    return null;
                  },
                ),

                /// E 理由
              ],
            ),
          );
        },
      ),
    );
  }
}
