/// 举报页面
library;

import 'dart:core';
import 'dart:convert';

import 'package:bfban/component/_captcha/index.dart';
import 'package:bfban/component/_loading/index.dart';
import 'package:flutter/material.dart';

import 'package:flutter_elui_plugin/elui.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import 'package:bfban/utils/index.dart';
import 'package:bfban/constants/api.dart';
import 'package:bfban/widgets/edit/game_type_radio.dart';

import '../../component/_customReply/customReply.dart';
import '../../component/_html/html.dart';
import '../../data/index.dart';

class ReportPage extends StatefulWidget {
  final dynamic data;

  const ReportPage({
    Key? key,
    this.data,
  }) : super(key: key);

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final UrlUtil _urlUtil = UrlUtil();

  final Util _util = Util();

  final GlobalKey<FormState> _reportFormKey = GlobalKey<FormState>();

  ReportStatus reportStatus = ReportStatus(
    load: false,
    param: ReportStatusParam(
      game: "",
      originName: "",
      cheatMethods: [],
      videoLink: "",
      description: "",
    ),
  );

  List reportInfoCheatMethods = [];

  // 视频Widget列表
  List videoWidgetList = [];

  // 视频信息
  Map videoInfo = {
    "value": "",
    "videoIndex": 0,
    "maxStringLang": 255,
    "maxCount": 10,
    "links": [
      {
        "value": 0,
        "placeholder": "http(s)://",
      },
    ],
  };

  final List _cheatingTypes = [];

  @override
  void initState() {
    super.initState();

    Map cheatMethodsGlossary = ProviderUtil().ofApp(context).conf.data.cheatMethodsGlossary!;

    // Update User Db id
    if (jsonDecode(widget.data)["originName"].toString().isNotEmpty) {
      reportStatus.param!.originName = jsonDecode(widget.data)["originName"];
    }

    setState(() {
      if (cheatMethodsGlossary["child"] != null) {
        cheatMethodsGlossary["child"].forEach((i) {
          String _key = Util().queryCheatMethodsGlossary(i["value"]);
          _cheatingTypes.add({"value": _key, "select": false});
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// [Response]
  /// 提交举报
  _onSubmit(BuildContext context) async {
    try {
      FormState? reportFormKey = _reportFormKey.currentState;
      bool validate = reportFormKey!.validate();

      if (!validate) return;
      reportFormKey.save();

      setState(() {
        reportStatus.load = true;
      });

      // 处理视频格式
      reportStatus.param!.videoLink = videoWidgetList.where((data) => data.toString().isNotEmpty).join(",");

      Response<dynamic> result = await HttpToken.request(
        Config.httpHost["player_report"],
        data: reportStatus.param!.toMap,
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

        _urlUtil.opEnPage(context, "/report/publish_results/success").then((value) {
          switch (value) {
            case "continue":
              break;
            default:
              _onReset();
              break;
          }
        });

        setState(() {
          reportStatus.load = false;
        });
        return;
      }

      setState(() {
        reportStatus.load = false;
        _urlUtil.opEnPage(context, "/report/publish_results/error").then((value) {
          switch (value) {
            case "continue":
              break;
            default:
              _onReset();
              break;
          }
        });
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
  /// video剩余可输入长度
  int _getVideoCharacterLength() {
    return videoWidgetList.where((data) => data.toString().isNotEmpty).join(",").length;
  }

  /// [Event]
  /// 视频链接容量溢出添加到描述
  void _addOverflowVideoLinkDescriptionBox() {
    String videoHtmlList = "";
    for (var i in videoWidgetList) {
      videoHtmlList = "$videoHtmlList<li><a href='$i'>$i</a></li>";
    }

    String html = """
    <p>${FlutterI18n.translate(context, "detail.info.videoLink")}</p>
    <ul>$videoHtmlList</ul>
    """;

    setState(() {
      videoWidgetList = [];
      reportStatus.param!.description = '${reportStatus.param!.description!}\t\n$html';
    });
  }

  /// [Event]
  /// 重置表单
  _onReset() {
    setState(() {
      reportStatus = ReportStatus(
        load: false,
        param: ReportStatusParam(
          game: "",
          originName: "",
          cheatMethods: [],
          videoLink: "",
          description: "",
        ),
      );
      reportInfoCheatMethods = [];
      videoWidgetList = [];
      videoInfo = {
        "value": "",
        "videoIndex": 0,
        "maxStringLang": 255,
        "maxCount": 10,
        "links": [
          {
            "value": 0,
            "placeholder": "http(s)://",
          },
        ],
      };
      if (Config.game["child"].isNotEmpty) {
        reportStatus.param!.game = Config.game["child"][0]["value"];
      }
    });
  }

  /// [Event]
  /// 打开编辑页面
  Future<String> _opEnRichEdit({updateValue}) async {
    await Storage().set("richedit", value: updateValue ?? reportStatus.param!.description.toString());

    Map data = await _urlUtil.opEnPage(context, "/richedit");

    /// 按下确认储存富文本编写的内容
    if (data["code"] == 1) {
      return data["html"];
    }

    return "";
  }

  /// [Event]
  /// 添加视频链接
  _addVideoLink() {
    return videoWidgetList.length < videoInfo["maxCount"] && _getVideoCharacterLength() < videoInfo["maxStringLang"]
        ? () {
            setState(() {
              videoWidgetList.add("");
            });
          }
        : null;
  }

  /// [Event]
  /// 删除视频链接
  void _removeVideoLink(index) {
    setState(() {
      videoWidgetList.removeAt(index);
    });
  }

  /// [Event]
  /// 举报用户填写
  void _changeReportUserInput(String value) {
    if (value.isNotEmpty) {
      setState(() {
        reportStatus.param!.originName = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(FlutterI18n.translate(context, "app.report.title")),
        actions: <Widget>[
          reportStatus.load!
              ? ElevatedButton(
                  onPressed: () {},
                  child: LoadingWidget(
                    size: 20,
                    color: Theme.of(context).progressIndicatorTheme.color!,
                  ),
                )
              : IconButton(
                  onPressed: () => _onSubmit(context),
                  icon: const Icon(Icons.done),
                ),
        ],
      ),
      body: Form(
        key: _reportFormKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          children: <Widget>[
            /// S 游戏ID
            FormField(
              builder: (FormFieldState field) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  color: field.isValid ? Colors.transparent : Theme.of(context).colorScheme.error.withOpacity(.2),
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                      side: BorderSide(
                        color: field.isValid ? Theme.of(context).dividerTheme.color! : Theme.of(context).colorScheme.error,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        EluiInputComponent(
                          internalstyle: true,
                          theme: EluiInputTheme(
                            textStyle: TextStyle(
                              fontSize: 25,
                              fontFamily: "UbuntuMono",
                              color: Theme.of(context).textTheme.bodyMedium!.color,
                            ),
                          ),
                          textInputAction: TextInputAction.next,
                          value: reportStatus.param!.originName!,
                          placeholder: FlutterI18n.translate(context, "report.labels.hackerId"),
                          onChange: (data) {
                            String value = data["value"];
                            field.didChange(value);
                            setState(() {
                              reportStatus.param!.originName = data["value"];
                            });
                          },
                        )..setValue = reportStatus.param!.originName!,
                        const Divider(height: 1),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                          child: Text(
                            FlutterI18n.translate(context, "report.info.idNotion1"),
                            style: TextStyle(color: Theme.of(context).textTheme.displayMedium!.color, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              initialValue: reportStatus.param!.originName,
              onSaved: (value) {
                _changeReportUserInput(value as String);
              },
              validator: (value) {
                if (value.toString().isEmpty) return "";
                return null;
              },
            ),

            /// E 游戏ID

            /// S 游戏
            FormField(
              builder: (FormFieldState field) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  color: field.isValid ? Colors.transparent : Theme.of(context).colorScheme.error.withOpacity(.2),
                  child: PopupMenuButton(
                    offset: const Offset(1, 55),
                    onSelected: (value) {
                      field.didChange(value);
                      setState(() {
                        reportStatus.param!.game = value as String;
                      });
                    },
                    itemBuilder: (context) => Config.game["child"].map<PopupMenuItem>((i) {
                      return PopupMenuItem(
                        value: i["value"],
                        child: Text(FlutterI18n.translate(context, "basic.games.${i["value"]}")),
                      );
                    }).toList(),
                    child: EluiCellComponent(
                      title: FlutterI18n.translate(context, "report.labels.game"),
                      theme: EluiCellTheme(backgroundColor: Colors.transparent, labelColor: Theme.of(context).textTheme.labelLarge!.color),
                      cont: Wrap(
                        runAlignment: WrapAlignment.center,
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (field.value != null && field.value != "")
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(3),
                                side: BorderSide(
                                  color: Theme.of(context).dividerTheme.color!,
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                child: Tooltip(
                                  message: FlutterI18n.translate(context, "basic.games.${field.value}"),
                                  child: Image.asset(
                                    "assets/images/games/${field.value}/logo.png",
                                    height: 16,
                                  ),
                                ),
                              ),
                            ),
                          if (field.value == null || field.value == "")
                            Row(
                              children: [
                                Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(3),
                                    side: BorderSide(
                                      color: Theme.of(context).colorScheme.error,
                                      width: 1,
                                    ),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    child: Wrap(
                                      spacing: 5,
                                      children: [Icon(Icons.gamepad, size: 15), Text("Game")],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          if (field.isValid)
                            IconButton(
                              onPressed: () {
                                field.didChange("");
                              },
                              icon: const Icon(Icons.clear),
                            )
                        ],
                      ),
                    ),
                  ),
                );
              },
              initialValue: reportStatus.param!.game,
              onSaved: (value) {
                setState(() {
                  reportStatus.param!.game = value.toString();
                });
              },
              validator: (value) {
                if (value.toString().isEmpty) return "";
                return null;
              },
            ),

            /// E 游戏

            /// S 作弊方式
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
                                child: Text(FlutterI18n.translate(context, "cheatMethods.${_util.queryCheatMethodsGlossary(method["value"])}.title")),
                              ),
                              onTap: () {
                                method["select"] = method["select"] != true;

                                if (method["select"]) {
                                  reportInfoCheatMethods.add(method["value"]);
                                } else {
                                  reportInfoCheatMethods.remove(method["value"]);
                                }

                                field.didChange(reportInfoCheatMethods);
                                setState(() {
                                  reportStatus.param!.cheatMethods = reportInfoCheatMethods as List?;
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
              initialValue: reportStatus.param!.cheatMethods,
              onSaved: (value) {
                setState(() {
                  reportStatus.param!.cheatMethods = value as List?;
                });
              },
              validator: (value) {
                if (value is List && value.isEmpty) return "";
                return null;
              },
            ),

            /// E 作弊方式

            const SizedBox(height: 10),

            /// S 视频链接
            EluiCellComponent(
              title: FlutterI18n.translate(context, "detail.info.videoLink"),
              label: "${videoWidgetList.length}/${videoInfo["maxCount"]}",
              cont: videoWidgetList.length < videoInfo["maxCount"]
                  ? Wrap(
                      children: [
                        if (_getVideoCharacterLength() > videoInfo["maxStringLang"])
                          Icon(
                            Icons.help,
                            color: Theme.of(context).colorScheme.error,
                            size: 15,
                          ),
                        OutlinedButton(
                          onPressed: _addVideoLink(),
                          child: const Icon(Icons.add),
                        )
                      ],
                    )
                  : Container(),
            ),

            if (_getVideoCharacterLength() > videoInfo["maxStringLang"])
              Column(
                children: [
                  EluiTipComponent(
                    type: EluiTip.warning,
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 5,
                      children: [
                        Text(FlutterI18n.translate(context, "app.report.overflowLength")),
                        TextButton(
                          onPressed: () => _addOverflowVideoLinkDescriptionBox(),
                          style: ButtonStyle(padding: WidgetStateProperty.all(const EdgeInsets.all(0)), textStyle: WidgetStateProperty.all(const TextStyle(fontSize: 12)), visualDensity: const VisualDensity(vertical: -3, horizontal: 2)),
                          child: Text(FlutterI18n.translate(context, "app.report.overflowLengthButton")),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),

            if (videoWidgetList.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: videoWidgetList.asMap().keys.map((index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 5, left: 15, right: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                      side: BorderSide(
                        color: Theme.of(context).dividerTheme.color!,
                        width: 1,
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Input(
                              type: TextInputType.url,
                              textInputAction: TextInputAction.next,
                              textStyle: Theme.of(context).textTheme.bodyMedium,
                              contentPadding: const EdgeInsets.symmetric(vertical: 10),
                              value: videoWidgetList[index],
                              onChange: (data) {
                                setState(() {
                                  videoWidgetList[index] = data["value"].toString();
                                });
                              },
                              placeholder: videoInfo["links"][videoInfo["videoIndex"]]["placeholder"],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _removeVideoLink(index),
                            child: const Icon(Icons.delete),
                          )
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

            /// E 视频链接

            const SizedBox(height: 10),

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
                                    reportStatus.param!.description = selectTemp;
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
              initialValue: reportStatus.param!.description,
              onSaved: (value) {
                setState(() {
                  reportStatus.param!.description = value as String?;
                });
              },
              validator: (value) {
                if (value.toString().length < 0 && value.toString().length > 5000) return "";
                if (value.toString().isEmpty) return "";
                return null;
              },
            ),

            /// E 理由

            /// S 验证码
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
                        setState(() {
                          reportStatus.param!.value = data["value"];
                        });
                      },
                      right: CaptchaWidget(
                        onChange: (Captcha captcha) => reportStatus.param!.setCaptcha(captcha),
                      ),
                      maxLenght: 4,
                      placeholder: FlutterI18n.translate(context, "captcha.title"),
                    ),
                  ),
                );
              },
              initialValue: reportStatus.param!.value,
              onSaved: (value) {
                if ((value as String).isEmpty) {
                  return;
                }

                setState(() {
                  reportStatus.param!.value = value;
                });
              },
              validator: (value) {
                if (value.toString().isEmpty) return "";
                return null;
              },
            ),

            /// E 验证码

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
