
import 'package:flutter/material.dart';

import 'package:bfban/utils/index.dart';
import 'package:bfban/constants/api.dart';
import 'package:bfban/data/index.dart';

import 'package:flutter_elui_plugin/elui.dart';

import '../../widgets/edit/game_type_radio.dart';

class ManagePage extends StatefulWidget {
  final id;

  const ManagePage({
    Key? key,
    this.id,
  }) : super(key: key);

  @override
  _ManagePageState createState() => _ManagePageState();
}

class _ManagePageState extends State<ManagePage> {
  final UrlUtil _urlUtil = UrlUtil();

  List reportInfoCheatMethods = [];

  Map suggestionInfo = {
    "videoIndex": 0,
    "links": [
      {
        "value": "1",
        "content": "存在作弊",
      },
      {
        "value": "2",
        "content": "再观察",
      },
      {
        "value": "3",
        "content": "清白",
      },
      {
        "value": "4",
        "content": "回收站",
      }
    ],
  };

  /// 裁判
  ManageStatus manageStatus = ManageStatus(
    load: false,
    data: ManageData(
      captcha: Captcha(),
      content: "",
      action: "1",
      cheatMethods: "",
      toPlayerId: "",
    ),
  );

  final List _cheatingTpyes = [];

  @override
  void initState() {
    super.initState();

    setState(() {
      manageStatus.data!.toPlayerId = widget.id;

      setState(() {
        Config.cheatingTpyes.forEach((key, value) {
          _cheatingTpyes.add({
            "name": value,
            "value": key,
            "select": false,
          });
        });
      });
    });
  }

  /// [Event]
  /// 验证
  Map _onVerification() {
    if (manageStatus.data!.action == "1") {
      if (manageStatus.data!.cheatMethods.toString().isEmpty) {
        return {
          "code": -1,
          "msg": "请选择作弊方式",
        };
      }
    }

    if (manageStatus.data!.content!.isEmpty) {
      return {
        "code": -1,
        "msg": "请填写理由",
      };
    }

    return {
      "code": 0,
      "msg": "",
    };
  }

  /// [Response]
  /// 发布判决
  void _onRelease() async {
    dynamic _verification = _onVerification();

    if (_verification["code"] != 0) {
      EluiMessageComponent.error(context)(
        child: Text(_verification["msg"]),
      );
      return;
    }

    setState(() {
      manageStatus.load = true;
    });

    Response result = await Http.request(
      Config.httpHost["player_judgement"],
      method: Http.POST,
      data: manageStatus.data!.toMap,
    );

    if (result.data["success"] == 1) {
      EluiMessageComponent.success(context)(
        child: const Text("判决成功"),
      );

      Navigator.pop(context);
    } else {
      EluiMessageComponent.error(context)(
        child: const Text("处理错误"),
      );
    }

    setState(() {
      manageStatus.load = false;
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

              manageStatus.data!.cheatMethods = _value;
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
    await Storage().set("com.cabbagelol.richedit", value: manageStatus.data!.content);

    _urlUtil.opEnPage(context, "/richedit").then((data) {
      /// 按下确认储存富文本编写的内容
      if (data["code"] == 1) {
        setState(() {
          manageStatus.data!.content = data["html"];
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
        title: const Text("裁判"),
        actions: [
          manageStatus.load!
              ? const ELuiLoadComponent(
                  type: "line",
                  lineWidth: 2,
                  color: Colors.black,
                )
              : IconButton(
                  onPressed: () {
                    _onRelease();
                  },
                  icon: const Icon(Icons.done),
                ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          /// S 处理意见
          const EluiCellComponent(title: "\u610f\u89c1"),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: DropdownButton(
                  isDense: true,
                  isExpanded: true,
                  underline: Container(),
                  onChanged: (index) {
                    setState(() {
                      manageStatus.data!.action = index.toString();
                    });
                  },
                  value: manageStatus.data!.action,
                  items: suggestionInfo["links"].map<DropdownMenuItem<String>>((i) {
                    return DropdownMenuItem(
                      value: i["value"].toString(),
                      child: Text(i["content"]),
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
            offstage: manageStatus.data!.action != "1",
            child: Column(
              children: [
                const EluiCellComponent(title: "\u4f5c\u5f0a\u65b9\u5f0f"),
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
            title: "理由",
            cont: Offstage(
              offstage: manageStatus.data!.content!.isNotEmpty,
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
                      Text(manageStatus.data!.content!.toString()),
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
                                manageStatus.data!.content!.isEmpty ? "填写理由" : "编辑",
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
        ],
      ),
    );
  }
}
