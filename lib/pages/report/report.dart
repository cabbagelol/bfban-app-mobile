/// 举报页面

import 'dart:core';
import 'dart:convert';

import 'package:bfban/component/_captcha/index.dart';
import 'package:bfban/component/_empty/index.dart';
import 'package:flutter/material.dart';

import 'package:flutter_elui_plugin/elui.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:bfban/utils/index.dart';
import 'package:bfban/constants/api.dart';
import 'package:bfban/widgets/edit/game_type_radio.dart';

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

  // 举报
  ReportStatus reportStatus = ReportStatus(
    load: false,
    param: ReportParam(
      captcha: Captcha(
        value: "",
        hash: "",
        captchaSvg: "",
        load: false,
      ),
      data: {
        "game": "",
        "originName": "",
        "cheatMethods": [],
        "videoLink": "",
        "description": "",
      },
    ),
  );

  List reportInfoCheatMethods = [];

  // 视频Widget列表
  List videoWidgetList = [];

  // 视频信息
  Map videoInfo = {
    "value": "",
    "videoIndex": 0,
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
      reportStatus.param!.data!["originName"] = jsonDecode(widget.data)["originName"];
    }

    setState(() {
      cheatMethodsGlossary["child"].forEach((i) {
        String _key = Util().queryCheatMethodsGlossary(i["value"], cheatMethodsGlossary["child"]);
        _cheatingTypes.add({"value": _key, "select": false});
      });

      if (Config.game["child"].isNotEmpty) {
        reportStatus.param!.data!["game"] = Config.game["child"][0]["value"];
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// [Response]
  /// 提交举报
  _onSubmit() async {
    _urlUtil.opEnPage(context, "/report/publish_results/success").then((value) {
      switch (value) {
        case "continue":
          _onReset();
          break;
      }
    });
    if (!_onVerification()) return;

    if (reportStatus.param!.captcha!.value.isEmpty) {
      return;
    }

    setState(() {
      reportStatus.load = true;
    });

    // 处理视频格式
    reportStatus.param!.data!["videoLink"] = videoWidgetList.where((data) => data.toString().isNotEmpty).join(",");

    Response<dynamic> result = await Http.request(
      Config.httpHost["player_report"],
      data: reportStatus.toMap,
      method: Http.POST,
    );

    if (result.data["success"] == 1) {
      EluiMessageComponent.success(context)(
        child: Text(result.data["code"]),
      );
      _urlUtil.opEnPage(context, "/report/publish_results/success").then((value) {
        switch (value) {
          case "continue":
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
      _urlUtil.opEnPage(context, "/report/publish_results/error");
    });
    EluiMessageComponent.warning(context)(
      child: Text("${result.data["code"]}:${result.data["message"]}"),
    );
  }

  /// [Event]
  /// 表单验证
  bool _onVerification() {
    Map param = reportStatus.toMap;

    if (param["game"] == "") {
      EluiMessageComponent.warning(context)(
        child: const Text("选择游戏类型"),
      );
      return false;
    }

    if (param["cheatMethods"] == "") {
      EluiMessageComponent.warning(context)(
        child: const Text("至少选择一个作弊方式"),
      );
      return false;
    }

    if (param["description"] == "") {
      EluiMessageComponent.warning(context)(
        child: const Text("至少填写描述内容, 有力的证据"),
      );
      return false;
    }

    if (param["videoLink"] == "") {
      EluiMessageComponent.warning(context)(
        child: const Text("填写有效的举报视频"),
      );
      return false;
    }

    return true;
  }

  /// [Event]
  /// 重置表单
  _onReset() {
    setState(() {
      reportStatus = ReportStatus(
        load: false,
        param: ReportParam(
          captcha: Captcha(
            value: "",
            hash: "",
            captchaSvg: "",
            load: false,
          ),
          data: {
            "game": "",
            "originName": "",
            "cheatMethods": [],
            "videoLink": "",
            "description": "",
          },
        ),
      );
      reportInfoCheatMethods = [];
      videoWidgetList = [];
      videoInfo = {
        "value": "",
        "videoIndex": 0,
        "maxCount": 10,
        "links": [
          {
            "value": 0,
            "placeholder": "http(s)://",
          },
        ],
      };
      if (Config.game["child"].isNotEmpty) {
        reportStatus.param!.data!["game"] = Config.game["child"][0]["value"];
      }
    });
  }

  /// [Event]
  /// 复选举报游戏作弊行为
  List<Widget> _reportCheckboxType() {
    List<Widget> widgets = [];
    for (var method in _cheatingTypes) {
      widgets.add(GameTypeRadioWidget(
        index: method["select"],
        child: Tooltip(
          message: FlutterI18n.translate(context, "cheatMethods.${method["value"]}.describe"),
          child: Text(FlutterI18n.translate(context, "cheatMethods.${method["value"]}.title")),
        ),
        onTap: () {
          setState(() {
            method["select"] = method["select"] != true;

            if (method["select"]) {
              reportInfoCheatMethods.add(method["value"]);
            } else {
              reportInfoCheatMethods.remove(method["value"]);
            }

            reportStatus.param!.data!["cheatMethods"] = reportInfoCheatMethods;
          });
        },
      ));
    }
    return widgets;
  }

  /// [Event]
  /// 打开编辑页面
  _opEnRichEdit() async {
    await Storage().set("richedit", value: reportStatus.param!.data!["description"].toString());

    _urlUtil.opEnPage(context, "/richedit").then((data) {
      /// 按下确认储存富文本编写的内容
      if (data["code"] == 1) {
        setState(() {
          reportStatus.param!.data!["description"] = data["html"];
        });
      }
    });
  }

  /// [Event]
  /// 添加视频链接
  _addVideoLink() {
    return videoWidgetList.length < videoInfo["maxCount"]
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
  void _changeReportUserInput(dynamic data) {
    setState(() {
      reportStatus.param!.data!["originName"] = data["value"].toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        title: Text(FlutterI18n.translate(context, "report.title")),
        actions: <Widget>[
          TextButton(
            onPressed: () => _onSubmit(),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                Theme.of(context).appBarTheme.backgroundColor,
              ),
            ),
            child: reportStatus.load!
                ? const Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: ELuiLoadComponent(
                      type: "line",
                      size: 20,
                      lineWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.done),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          /// S 游戏ID
          Container(
            margin: const EdgeInsets.only(top: 20, left: 15, right: 15),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(
                      top: 20,
                      left: 20,
                      bottom: 5,
                      right: 20,
                    ),
                    child: Column(
                      children: <Widget>[
                        Text(
                          reportStatus.param!.data!["originName"] == "" ? "USER ID" : reportStatus.param!.data!["originName"].toString(),
                          style: TextStyle(
                            color: reportStatus.param!.data!["originName"] == "" ? Colors.white12 : Colors.white,
                            fontSize: 30,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Offstage(
                          offstage: reportStatus.param!.data!["originName"].toString().isNotEmpty,
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
                                "请填写作弊者人名称",
                                style: TextStyle(
                                  color: Colors.yellow,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Center(
                          child: Text(
                            FlutterI18n.translate(context, "report.info.idNotion1"),
                            style: const TextStyle(color: Colors.white12, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  EluiInputComponent(
                    title: FlutterI18n.translate(context, "report.labels.hackerId"),
                    value: reportStatus.param!.data!["originName"],
                    placeholder: FlutterI18n.translate(context, "report.labels.hackerId"),
                    onChange: (data) => _changeReportUserInput(data),
                  )..setValue = reportStatus.param!.data!["originName"],
                ],
              ),
            ),
          ),

          /// E 游戏ID

          /// S 游戏
          PopupMenuButton(
            onSelected: (value) {
              setState(() {
                reportStatus.param!.data!["game"] = value;
              });
            },
            itemBuilder: (context) => Config.game["child"].map<PopupMenuItem>((i) {
              return CheckedPopupMenuItem(
                value: i["value"],
                checked: reportStatus.param!.data!["game"] == i["value"],
                child: Text(FlutterI18n.translate(context, "basic.games.${i["value"]}")),
              );
            }).toList(),
            child: EluiCellComponent(
              title: FlutterI18n.translate(context, "report.labels.game"),
              theme: EluiCellTheme(backgroundColor: Colors.transparent, labelColor: Theme.of(context).textTheme.subtitle2!.color),
              cont: Wrap(
                runAlignment: WrapAlignment.center,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (reportStatus.param!.data!["game"] != null)
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                        side: BorderSide(
                          color: Theme.of(context).dividerColor,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: Text(
                          FlutterI18n.translate(context, "basic.games.${reportStatus.param!.data!["game"]}"),
                        ),
                      ),
                    ),
                  const Icon(Icons.keyboard_arrow_right),
                ],
              ),
            ),
          ),

          /// E 游戏

          /// S 作弊方式
          EluiCellComponent(
            title: FlutterI18n.translate(context, "report.labels.cheatMethod"),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Wrap(
              children: _reportCheckboxType(),
            ),
          ),

          /// E 作弊方式

          const SizedBox(
            height: 10,
          ),

          /// S 视频链接
          EluiCellComponent(
            title: "${FlutterI18n.translate(context, "detail.info.videoLink")} (${videoWidgetList.length}/${videoInfo["maxCount"]})",
            cont: TextButton(
              onPressed: _addVideoLink(),
              child: const Icon(Icons.add),
            ),
          ),
          videoWidgetList.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: videoWidgetList.asMap().keys.map((index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: EluiInputComponent(
                                title: "",
                                value: videoWidgetList[index],
                                internalstyle: false,
                                onChange: (data) {
                                  setState(() {
                                    videoWidgetList[index] = data["value"].toString();
                                  });
                                },
                                placeholder: videoInfo["links"][videoInfo["videoIndex"]]["placeholder"],
                              ),
                            ),
                            IconButton(
                              onPressed: () => _removeVideoLink(index),
                              icon: const Icon(Icons.delete),
                            )
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                )
              : const EmptyWidget(),

          /// E 视频链接

          const SizedBox(
            height: 10,
          ),

          /// S 理由
          EluiCellComponent(
            title: FlutterI18n.translate(context, "report.labels.description"),
            cont: Offstage(
              offstage: reportStatus.param!.data!["description"].toString().isNotEmpty,
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
              clipBehavior: Clip.hardEdge,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
                side: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
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
                      Html(data: reportStatus.param!.data!["description"]),
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

          const SizedBox(
            height: 20,
          ),

          /// S 验证码
          EluiInputComponent(
            internalstyle: true,
            onChange: (data) {
              setState(() {
                reportStatus.param!.captcha!.value = data["value"];
              });
            },
            right: CaptchaWidget(
              onChange: (Captcha cap) => reportStatus.param!.captcha = cap,
            ),
            maxLenght: 4,
            placeholder: FlutterI18n.translate(context, "captcha.title"),
          ),

          /// E 验证码

          const SizedBox(
            height: 100,
          ),
        ],
      ),
    );
  }
}
