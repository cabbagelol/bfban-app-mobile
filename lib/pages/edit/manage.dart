/// 管理

import 'package:flutter/material.dart';

import 'package:bfban/utils/index.dart';
import 'package:bfban/constants/api.dart';

import 'package:flutter_plugin_elui/elui.dart';

class ManagePage extends StatefulWidget {
  final id;

  ManagePage({
    this.id,
  });

  @override
  _ManagePageState createState() => _ManagePageState();
}

class _ManagePageState extends State<ManagePage> {
  List reportInfoCheatMethods = new List();

  Map suggestionInfo = {
    "videoIndex": 0,
    "links": [
      {
        "value": 1,
        "content": "存在作弊",
      },
      {
        "value": 2,
        "content": "再观察",
      },
      {
        "value": 3,
        "content": "清白",
      },
      {
        "value": 4,
        "content": "回收站",
      }
    ],
  };

  bool manageLoad = false;

  Map manageData = {
    "status": 1,
    "suggestion": "",
    "cheatMethods": "",
    "originUserId": "",
  };

  @override
  void initState() {
    super.initState();

    setState(() {
      manageData["originUserId"] = widget.id;
    });
  }

  /// 验证
  Map _onVerification () {
    if (manageData["status"] == 1) {
      if (manageData["cheatMethods"].toString().length == 0) {
        return {
          "code": -1,
          "msg": "请选择作弊方式",
        };
      }
    }

    if (manageData["suggestion"].toString().length == 0) {
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

  /// 发布
  void _onRelease() async {
    setState(() {
      manageLoad = true;
    });

    dynamic _verification = this._onVerification();

    if (_verification["code"] != 0) {
      EluiMessageComponent.error(context)(
        child: Text(_verification["msg"]),
      );
      return;
    }

    Response result = await Http.request(
      'api/cheaters/verify',
      method: Http.POST,
      data: manageData,
    );

    if (result.data["error"] == 0) {
      EluiMessageComponent.success(context)(
        child: Text("判决成功"),
      );

      Navigator.pop(context);
    } else {
      EluiMessageComponent.error(context)(
        child: Text("处理错误"),
      );
    }

    setState(() {
      manageLoad = false;
    });
  }

  /// 复选举报游戏作弊行为
  List<Widget> _setCheckboxIndex() {
    List<Widget> list = new List();

    List _cheatingTpyes = new List();

    String _value = "";

    num _valueIndex = 0;

    Config.cheatingTpyes.forEach((key, value) {
      _cheatingTpyes.add({
        "name": value,
        "value": key,
      });
    });

    _cheatingTpyes.forEach((element) {
      list.add(
        EluiCheckboxComponent(
          color: Colors.amber,
          child: Text(
            element["name"],
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          onChanged: (bool) {
            print(bool);
            setState(() {
              if (bool) {
                reportInfoCheatMethods.add(element["value"]);
              } else {
                reportInfoCheatMethods.remove(element["value"]);
              }
            });
          },
        ),
      );
    });

    reportInfoCheatMethods.forEach((element) {
      _value += element + (_valueIndex >= reportInfoCheatMethods.length - 1 ? "" : ",");
      _valueIndex += 1;
    });

    setState(() {
      manageData["cheatMethods"] = _value;
    });

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff111b2b),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          "管理员裁判",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        children: <Widget>[
          /// S 意见
          EluiCellComponent(
            title: "意见",
            label: "选择一项判决决议",
            theme: EluiCellTheme(
              backgroundColor: Colors.transparent,
            ),
            cont: DropdownButton(
              isDense: true,
              isExpanded: true,
              dropdownColor: Colors.black,
              style: TextStyle(color: Colors.white),
              focusColor: Colors.white24,
              onChanged: (index) {
                setState(() {
                  suggestionInfo["videoIndex"] = index;
                  manageData["status"] = index;
                });
              },
              value: this.manageData["status"],
              items: this.suggestionInfo["links"].map<DropdownMenuItem>((value) {
                return DropdownMenuItem(
                  value: value["value"],
                  child: Text(
                    value["content"],
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          /// E 意见

          Container(
            height: 10,
            color: Colors.black,
          ),

          /// S 作弊方式
          Offstage(
            offstage: manageData["status"] != 1,
            child: EluiCellComponent(
              title: "作弊方式",
              theme: EluiCellTheme(
                backgroundColor: Colors.transparent,
              ),
              cont: Container(
                height: 25,
                margin: EdgeInsets.only(
                  left: 10,
                ),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: this._setCheckboxIndex(),
                    )
                  ],
                ),
              ),
            ),
          ),
          /// E 作弊方式

          /// S 理由
          EluiTextareaComponent(
            color: Colors.white,
            placeholder: "请填写备注内容",
            maxLength: 500,
            maxLines: 15,
            onChange: (data) {
              setState(() {
                manageData["suggestion"] = data["value"];
              });
            },
          ),

          /// E 理由

          Container(
            padding: EdgeInsets.all(20),
            child: Text(
              "1. 不要轻易下判断，如果不能做出处理判断，就使用上方回复参与讨论，等待举报者回复。 \n\n2.管理员的任何处理操作都会对作弊者的现有状态造成改变，如果不是100％确定，请使用回复留言讨论",
              style: TextStyle(
                fontSize: 12,
                color: Colors.white12,
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(20),
            child: EluiButtonComponent(
              type: ButtonType.succeed,
              child: Text("提交"),
              onTap: () => this._onRelease(),
            ),
          ),
        ],
      ),
    );
  }
}
