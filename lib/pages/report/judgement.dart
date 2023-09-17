import 'package:bfban/component/_privilegesTag/index.dart';
import 'package:flutter/material.dart';

import 'package:bfban/utils/index.dart';
import 'package:bfban/constants/api.dart';
import 'package:bfban/data/index.dart';

import 'package:flutter_elui_plugin/elui.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

import '../../component/_customReply/customReply.dart';
import '../../widgets/edit/game_type_radio.dart';

class JudgementPage extends StatefulWidget {
  final String? id;

  const JudgementPage({
    Key? key,
    this.id,
  }) : super(key: key);

  @override
  _JudgementPageState createState() => _JudgementPageState();
}

class _JudgementPageState extends State<JudgementPage> {
  final UrlUtil _urlUtil = UrlUtil();

  final Util _util = Util();

  List _reportInfoCheatMethods = [];

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

  /// [Event]
  /// 表单验证
  Map _onVerification() {
    if (manageStatus.parame!.action == "1") {
      if (manageStatus.parame!.cheatMethods.toString().isEmpty) {
        return {
          "code": -1,
          "msg": "detail.messages.fillEverything",
        };
      }
    }

    if (manageStatus.parame!.content!.isEmpty || manageStatus.parame!.content!.trim().isEmpty) {
      return {
        "code": -1,
        "msg": "detail.messages.pleaseExplain",
      };
    }

    return {
      "code": 0,
      "msg": "detail.messages.fillEverything",
    };
  }

  /// [Response]
  /// 发布判决
  void _onRelease() async {
    dynamic verification = _onVerification();

    if (verification["code"] != 0) {
      EluiMessageComponent.error(context)(
        child: Text(FlutterI18n.translate(context, verification["msg"])),
      );
      return;
    }

    setState(() {
      manageStatus.load = true;
    });

    Response result = await Http.request(
      Config.httpHost["player_judgement"],
      method: Http.POST,
      data: manageStatus.parame!.toMap,
    );

    if (result.data["success"] == 1) {
      EluiMessageComponent.success(context)(
        child: Text(FlutterI18n.translate(context, "detail.messages.submitSuccess")),
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
      child: Text("${result.data["code"]}:${result.data["message"]}"),
    );
  }

  /// [Event]
  /// 复选举报游戏作弊行为
  List<Widget> _setCheckboxIndex() {
    List<Widget> list = [];

    for (var method in _cheatingTypes) {
      list.add(GameTypeRadioWidget(
        index: method["select"],
        child: Text(FlutterI18n.translate(context, "cheatMethods.${_util.queryCheatMethodsGlossary(method["value"])}.title")),
        onTap: () {
          method["select"] = method["select"] != true;

          if (method["select"]) {
            _reportInfoCheatMethods.add(method["value"]);
          } else {
            _reportInfoCheatMethods.remove(method["value"]);
          }

          setState(() {
            manageStatus.parame!.cheatMethods = _reportInfoCheatMethods;
          });
        },
      ));
    }

    return list;
  }

  /// [Event]
  /// 打开编辑页面
  _opEnRichEdit() async {
    await Storage().set("richedit", value: manageStatus.parame!.content);

    _urlUtil.opEnPage(context, "/richedit").then((data) {
      /// 按下确认储存富文本编写的内容
      if (data["code"] == 1) {
        setState(() {
          manageStatus.parame!.content = data["html"];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(FlutterI18n.translate(context, "detail.info.judgement")),
        actions: [
          manageStatus.load!
              ? ElevatedButton(
                  onPressed: () {},
                  child: ELuiLoadComponent(
                    type: "line",
                    lineWidth: 2,
                    size: 20,
                    color: Theme.of(context).progressIndicatorTheme.color!,
                  ),
                )
              : IconButton(
                  onPressed: () => _onRelease(),
                  icon: const Icon(Icons.done),
                ),
        ],
      ),
      body: Consumer<AppInfoProvider>(
        builder: (BuildContext context, AppInfoProvider appInfo, Widget? child) {
          return ListView(
            children: [
              /// S 处理意见
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
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: DropdownButton(
                        isDense: false,
                        isExpanded: true,
                        underline: const SizedBox(),
                        dropdownColor: Theme.of(context).bottomAppBarTheme.color,
                        style: Theme.of(context).dropdownMenuTheme.textStyle,
                        onChanged: (value) {
                          setState(() {
                            manageStatus.parame!.action = value.toString();
                          });
                        },
                        value: manageStatus.parame!.action,
                        items: appInfo.conf.data.action!["child"].map<DropdownMenuItem<String>>((i) {
                          return DropdownMenuItem(
                            value: i["value"].toString(),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        FlutterI18n.translate(context, "basic.action.${_util.queryAction(i["value"])}.text"),
                                        style: TextStyle(fontSize: FontSize.large.value),
                                      ),
                                      const SizedBox(height: 2),
                                      PrivilegesTagWidget(data: i["privilege"]),
                                    ],
                                  ),
                                ),
                                Tooltip(
                                  message: FlutterI18n.translate(context, "basic.action.${_util.queryAction(i["value"])}.describe"),
                                  child: const Icon(Icons.help, size: 14),
                                )
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),

              /// E 处理意见

              const SizedBox(
                height: 10,
              ),

              /// S 作弊方式
              Offstage(
                offstage: !["kill", "guilt"].contains(manageStatus.parame!.action!),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    EluiCellComponent(
                      title: FlutterI18n.translate(context, "detail.judgement.methods"),
                      cont: _reportInfoCheatMethods.isEmpty
                          ? const Icon(
                              Icons.warning,
                              color: Colors.yellow,
                              size: 15,
                            )
                          : Container(),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child: Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: _setCheckboxIndex(),
                      ),
                    ),
                  ],
                ),
              ),

              /// E 作弊方式

              /// S 理由
              EluiCellComponent(
                title: FlutterI18n.translate(context, "detail.judgement.content"),
                cont: manageStatus.parame!.content!.isEmpty
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
                  child: GestureDetector(
                    child: Container(
                      padding: EdgeInsets.zero,
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
                                Html(data: manageStatus.parame!.content!.toString()),
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
                                        onPressed: () => _opEnRichEdit(),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                          CustomReplyWidget(
                            type: CustomReplyType.Judgement,
                            onChange: (String selectTemp) {
                              setState(() {
                                manageStatus.parame!.content = selectTemp;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              /// E 理由
            ],
          );
        },
      ),
    );
  }
}
