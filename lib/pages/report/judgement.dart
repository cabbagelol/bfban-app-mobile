import 'package:flutter/material.dart';

import 'package:bfban/utils/index.dart';
import 'package:bfban/constants/api.dart';
import 'package:bfban/data/index.dart';

import 'package:flutter_elui_plugin/elui.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

import '../../component/_captcha/index.dart';
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

  List _reportInfoCheatMethods = [];

  /// 裁判
  ManageStatus manageStatus = ManageStatus(
    load: false,
    parame: ManageData(
      captcha: Captcha(),
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

    Map cheatMethodsGlossary = ProviderUtil().ofApp(context).conf!.data.cheatMethodsGlossary!;

    setState(() {
      manageStatus.parame!.toPlayerId = widget.id;
      manageStatus.parame!.action = ProviderUtil().ofApp(context).conf!.data.action!["child"][0]["value"];

      setState(() {
        cheatMethodsGlossary["child"].forEach((i) {
          String _key = Util().queryCheatMethodsGlossary(i["value"], cheatMethodsGlossary["child"]);
          _cheatingTypes.add({"value": _key, "select": false});
        });
      });
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
    Navigator.pop(context);
    return;
    dynamic _verification = _onVerification();

    if (_verification["code"] != 0) {
      EluiMessageComponent.error(context)(
        child: Text(FlutterI18n.translate(context, _verification["msg"])),
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
        child: Text(FlutterI18n.translate(context, "cheatMethods.${method["value"]}.title")),
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
                  child: const ELuiLoadComponent(
                    type: "line",
                    lineWidth: 2,
                    size: 25,
                    color: Colors.white,
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
            children: <Widget>[
              /// S 处理意见
              EluiCellComponent(title: FlutterI18n.translate(context, "detail.judgement.behavior")),
              if (appInfo.conf!.data.action!["child"].length > 0)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  child: Card(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: DropdownButton(
                        isDense: true,
                        isExpanded: true,
                        elevation: 0,
                        underline: const SizedBox(),
                        onChanged: (value) {
                          setState(() {
                            manageStatus.parame!.action = value.toString();
                          });
                        },
                        value: manageStatus.parame!.action,
                        items: appInfo.conf!.data.action!["child"].map<DropdownMenuItem<String>>((i) {
                          return DropdownMenuItem<String>(
                            alignment: AlignmentDirectional.topCenter,
                            value: i["value"].toString(),
                            child: Row(
                              children: [
                                Text(FlutterI18n.translate(context, "basic.action.${i["value"]}.text")),
                                // PrivilegesTagWidget(data: i["privilege"]),
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
                    EluiCellComponent(title: FlutterI18n.translate(context, "detail.judgement.methods")),
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
                cont: Offstage(
                  offstage: manageStatus.parame!.content!.isNotEmpty,
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
                        FlutterI18n.translate(context, "detail.messages.fillEverything"),
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
                  elevation: 0,
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
                  ),
                ),
              ),

              /// E 理由

              /// S 验证码
              EluiInputComponent(
                onChange: (data) {
                  setState(() {
                    manageStatus.parame!.captcha!.value = data["value"];
                  });
                },
                right: CaptchaWidget(
                  onChange: (Captcha cap) => manageStatus.parame!.captcha = cap,
                ),
                maxLenght: 4,
                placeholder: FlutterI18n.translate(context, "captcha.title"),
              ),

              /// E 验证码
            ],
          );
        },
      ),
    );
  }
}
