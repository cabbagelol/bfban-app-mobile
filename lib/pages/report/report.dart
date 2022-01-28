/// 举报页面

import 'dart:core';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_elui_plugin/elui.dart';

import 'package:flutter_svg/flutter_svg.dart';

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
    captcha: Captcha(
      value: "",
      hash: "",
      captchaSvg: "",
      load: false,
    ),
    param: ReportParam(
      data: {
        "originName": "",
        "description": "",
      },
      encryptCaptcha: "",
      captcha: "",
    ),
  );

  List reportInfoCheatMethods = [];

  // 视频列表
  List videoList = [];

  // 视频信息
  Map videoInfo = {
    "value": "",
    "videoIndex": 0,
    "links": [
      {
        "value": 0,
        "s": "https://www.bilibili.com/video/",
        "content": "原地址",
        "placeholder": "http(s)://",
      },
      {
        "value": 1,
        "S": "",
        "content": "BiliBili",
        "placeholder": "AV/BV",
      },
    ],
  };

  final List _cheatingTpyes = [];

  @override
  void initState() {
    super.initState();

    // 更新id
    if (jsonDecode(widget.data)["originName"].toString().isNotEmpty) {
      reportStatus.param!.data!["originName"] = jsonDecode(widget.data)["originName"];
    }

    setState(() {
      Config.cheatingTpyes.forEach((key, value) {
        _cheatingTpyes.add({
          "name": value,
          "value": key,
          "select": false,
        });
      });
    });

    _getCaptcha();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// [Response]
  /// 更新验证码
  void _getCaptcha() async {
    String time = DateTime.now().millisecondsSinceEpoch.toString();

    setState(() {
      reportStatus.captcha!.load = true;
    });

    Response result = await Http.request(
      '${Config.httpHost["captcha"]}?t=$time',
      method: Http.GET,
    );

    if (result.data["success"] == 1) {
      result.headers['set-cookie']?.forEach((i) {
        reportStatus.captcha!.cookie += i + ';';
      });
      reportStatus.captcha!.captchaSvg = result.data["data"]["content"];
      reportStatus.captcha!.hash = result.data["data"]["hash"];
    }

    setState(() {
      reportStatus.captcha!.load = false;
    });
  }

  /// [Event]
  /// 提交前验证
  bool _onVerification() {
    Map param = reportStatus.param!.toMap!;

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
  /// 提交举报
  Future _onSubmit() async {
    String _token = ProviderUtil().ofUser(context).getToken;

    if (!_onVerification()) {
      return;
    }

    setState(() {
      reportStatus.load = true;
    });

    // 更新验证码hash
    reportStatus.param!.encryptCaptcha = reportStatus.captcha!.hash;
    reportStatus.param!.captcha = reportStatus.param!.toMap["captcha"];

    // 更新视频
    reportStatus.param!.data!["videoLink"] = videoList.where((data) => data.toString().isNotEmpty).join(",");

    Response<dynamic> result = await Http.request(
      Config.httpHost["player_report"],
      headers: {
        "token": _token,
      },
      data: reportStatus.param!.toMap,
      method: Http.POST,
    );

    if (result.data["error"] > 0) {
      EluiMessageComponent.warning(context)(
        child: const Text("至少填写描述内容, 有力的证据"),
      );
    } else if (result.data["error"] == 0) {
      EluiMessageComponent.success(context)(
        child: const Text("发布成功"),
      );
      UrlUtil().opEnPage(context, "/report/publishResultsPage");
    }

    setState(() {
      reportStatus.load = false;
    });
  }

  /// [Event]
  /// 复选举报游戏作弊行为
  List<Widget> _setCheckboxIndex() {
    List<Widget> list = [];
    String _value = "";
    num _valueIndex = 0;

    for (var element in _cheatingTpyes) {
      list.add(
        gameTypeRadio(
          index: element["select"],
          child: Text(element["name"]),
          onTap: () {
            setState(() {
              element["select"] = element["select"] != true;

              if (element["select"]) {
                reportInfoCheatMethods.add(element["value"]);
              } else {
                reportInfoCheatMethods.remove(element["value"]);
              }

              for (var element in reportInfoCheatMethods) {
                _value += element + (_valueIndex >= reportInfoCheatMethods.length - 1 ? "" : ",");
                _valueIndex += 1;
              }

              reportStatus.param!.data!["cheatMethods"] = _value;
            });
          },
        ),
      );
    }

    return list;
  }

  /// [Event]
  /// 打开编辑页面
  _opEnRichEdit() async {
    await Storage().set("com.cabbagelol.richedit", value: reportStatus.param!.data!["description"].toString());

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
  /// 打开草稿箱
  _openDrafts() {
    _urlUtil.opEnPage(context, "/drafts").then((value) {
      if (value == null) {
        return;
      }
    });
  }

  /// [Event]
  /// 提交
  void _onSubmitMore() {
    if (!_onVerification()) {
      return;
    }

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          children: <Widget>[
            SimpleDialogOption(
              child: Column(
                children: <Widget>[
                  const Text('\u53d1\u5e03'),
                  Text(
                    '\u5c06\u4e3e\u62a5\u0049\u0044\u53d1\u5e03\u5230\u0042\u0046\u0042\u0041\u004e\u4e0a',
                    style: TextStyle(color: Theme.of(context).textTheme.subtitle2!.color),
                  ),
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
              onPressed: () async {
                if (reportStatus.param!.captcha == "") {
                  EluiMessageComponent.warning(context)(
                    child: const Text("请填写验证码"),
                  );
                  return;
                }

                await _onSubmit();
                Navigator.pop(context);
              },
            ),
            SimpleDialogOption(
              child: Column(
                children: <Widget>[
                  const Text('草稿箱'),
                  Text(
                    '储存到草稿箱,不会被发布',
                    style: TextStyle(color: Theme.of(context).textTheme.subtitle2!.color),
                  ),
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
              onPressed: () async {
                // List? _drafts = jsonDecode(await Storage().get("drafts"));
                // reportInfo["date"] = DateTime.now().millisecondsSinceEpoch;
                // if (_drafts!.isNotEmpty) {
                //   List.generate(_drafts.length, (index) {
                //     if (reportInfo["originName"] == _drafts[index]["originName"]) {
                //       _drafts.removeAt(index);
                //     }
                //   });
                // }
                // _drafts.add(reportInfo);
                // Storage().set(
                //   "drafts",
                //   value: jsonEncode(_drafts),
                // );
                // Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "举报",
        ),
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
                  color: Theme.of(context).backgroundColor.withOpacity(.09),
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
                        const Center(
                          child: Text(
                            "检查用户id是否举报正确",
                            style: TextStyle(color: Colors.white12, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  EluiInputComponent(
                    title: "游戏ID",
                    value: reportStatus.param!.data!["originName"],
                    placeholder: "输入作弊玩家游戏ID",
                    onChange: (data) {
                      setState(() {
                        reportStatus.param!.data!["originName"] = data["value"].toString();
                      });
                    },
                  )..setValue = reportStatus.param!.data!["originName"],
                ],
              ),
            ),
          ),

          /// E 游戏ID

          /// S 游戏
          EluiCellComponent(
            title: "游戏类型",
            theme: EluiCellTheme(backgroundColor: Colors.transparent, labelColor: Theme.of(context).textTheme.subtitle2!.color),
            label: reportStatus.param!.data!["game"] ?? "请选择举报游戏",
            cont: PopupMenuButton(
              icon: const Icon(Icons.chevron_right),
              onSelected: (value) {
                setState(() {
                  reportStatus.param!.data!["game"] = value;
                });
              },
              itemBuilder: (context) => Config.game["child"].map<PopupMenuItem>((i) {
                return CheckedPopupMenuItem(
                  value: i["value"],
                  checked: reportStatus.param!.data!["game"] == i["value"],
                  child: Image.asset(i["app_assets_logo_file"], height: 18),
                );
              }).toList(),
            ),
          ),

          /// E 游戏

          const SizedBox(
            height: 10,
          ),

          /// S 作弊方式
          EluiCellComponent(
            title: "作弊方式",
            cont: Offstage(
              offstage: reportStatus.param!.data!["cheatMethods"].toString().isNotEmpty,
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
                    "请至少选择一下举报行为",
                    style: TextStyle(
                      color: Colors.yellow,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Wrap(
              spacing: 5,
              runSpacing: 5,
              children: _setCheckboxIndex(),
            ),
          ),

          /// E 作弊方式

          const SizedBox(
            height: 10,
          ),

          /// S 视频链接
          EluiCellComponent(
            title: "视频链接 (${videoList.length}/20)",
            cont: TextButton(
              child: const Icon(Icons.add),
              onPressed: () {
                if (videoList.length > 19) return;
                setState(() {
                  videoList.add("");
                });
              },
            ),
          ),
          videoList.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: videoList.asMap().keys.map((index) {
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
                                value: videoList[index],
                                internalstyle: false,
                                onChange: (data) {
                                  setState(() {
                                    videoList[index] = data["value"].toString();
                                  });
                                },
                                placeholder: videoInfo["links"][videoInfo["videoIndex"]]["placeholder"],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  videoList.removeAt(index);
                                });
                              },
                              icon: const Icon(Icons.delete),
                            )
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                )
              : Card(
                  margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    child: Text(
                      "空",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.subtitle2!.color,
                      ),
                    ),
                  ),
                ),

          /// E 视频链接

          const SizedBox(
            height: 10,
          ),

          /// S 理由
          EluiCellComponent(
            title: "理由",
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
                      Text(reportStatus.param!.data!["description"].toString()),
                      // Html(
                      //   data: reportStatus.param!.data!["description"],
                      //   style: _detailApi.styleHtml(context),
                      //   customRenders: _detailApi.customRenders(context),
                      // ),
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
                                reportStatus.param!.data!["description"].toString().isEmpty ? "填写理由" : "编辑",
                                style: const TextStyle(fontSize: 18),
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
            title: "验证码",
            onChange: (data) {
              setState(() {
                reportStatus.param!.captcha = data["value"];
              });
            },
            right: GestureDetector(
              child: SizedBox(
                width: 80,
                height: 40,
                child: !reportStatus.captcha!.load
                    ? SvgPicture.string(
                        reportStatus.captcha!.captchaSvg,
                        color: Colors.white,
                      )
                    : const SizedBox(
                        child: CircularProgressIndicator(),
                        width: 10,
                        height: 10,
                      ),
              ),
              onTap: () => _getCaptcha(),
            ),
            maxLenght: 4,
            placeholder: "输入验证码",
          ),

          /// E 验证码

          const SizedBox(
            height: 100,
          ),
        ],
      ),

      /// 底部
      bottomNavigationBar: Container(
        height: 70,
        decoration: const BoxDecoration(
          color: Colors.black,
          border: Border(
            top: BorderSide(
              width: 1.0,
              color: Colors.black12,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextButton(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                children: const <Widget>[
                  Text(
                    "草稿箱",
                    style: TextStyle(
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              onPressed: () {
                return null;
                _openDrafts();
              },
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: TextButton(
                child: reportStatus.load!
                    ? const CircularProgressIndicator()
                    : Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 10,
                        children: const <Widget>[
                          Icon(
                            Icons.done,
                            color: Colors.orangeAccent,
                          ),
                          Text(
                            "确认",
                            style: TextStyle(
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                onPressed: () => _onSubmit(),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Theme.of(context).appBarTheme.backgroundColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: () => _onSubmitMore(),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
