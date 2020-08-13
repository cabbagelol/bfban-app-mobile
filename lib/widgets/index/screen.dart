import 'package:flutter/cupertino.dart';

/// 首页筛选器

import 'package:flutter/material.dart';

import 'package:bfban/constants/api.dart';
import 'package:bfban/widgets/edit/gameTypeRadio.dart';

import 'package:flutter_plugin_elui/elui.dart';

class indexScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> keyname;

  final Function onSucceed;

  final indexData;

  indexScreen({
    this.keyname,
    this.onSucceed,
    this.indexData,
  });

  @override
  _indexScreenState createState() => _indexScreenState();
}

class _indexScreenState extends State<indexScreen> {
  List gameSumStatusData = [
    {
      "s": "所有",
      "t": "所有",
      "c": Colors.white70,
      "value": 100,
    },
  ];

  List gameTypes = [
    {
      "name": "所有",
      "value": "",
      "img": {
        "file": "",
        "network": "",
      },
    },
  ];

  List gameSort = [
    {
      "name": "举报时间倒序",
      "value": "createDatetime",
    },
    {
      "name": "更新时间倒序",
      "value": "updateDatetime",
    },
    {
      "name": "围观次数倒序",
      "value": "n",
    },
    {
      "name": "回复次数倒序",
      "value": "commentsNum",
    }
  ];

  Map<dynamic, dynamic> gameSumStatus = {
    "index": 0,
  };

  int gameTypeIndex = 0;

  int gameStateIndex = 0;

  String gameSortValue = "createDatetime";

  /// 筛选Map集合
  static Map screenInfo = {};

  @override
  void initState() {
    super.initState();

    setState(() {
      gameTypes.addAll(Config.game["type"]);

      gameSumStatusData.addAll(Config.startusIng);
    });
  }

  /// 初始值
  void onInitial() {
    setState(() {
      gameTypeIndex = 0;

      gameSumStatus["index"] = 0;

      screenInfo = {
        "game": gameTypes[0]["value"],
        "status": gameSumStatusData[0]["value"],
        "sort": gameSort[0]["value"],
      };
    });
  }

  /// 确认
  void onChange() {
    setState(() {
      screenInfo = {
        "game": gameTypes[gameTypeIndex]["value"],
        "status": gameSumStatusData[gameSumStatus["index"]]["value"],
        "sort": gameSortValue,
      };
    });

    widget.onSucceed(screenInfo);
    widget.keyname.currentState.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: ListView(
              children: <Widget>[
                /// S 游戏
                Container(
                  padding: EdgeInsets.only(
                    top: 10,
                    left: 20,
                    right: 20,
                    bottom: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "游戏",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          shadows: <Shadow>[
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(1, 2),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: Container(
                          color: Colors.black38,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: gameTypes.asMap().keys.map((index) {
                              return gameTypeRadio(
                                index: gameTypeIndex == index,
                                child: index != 0
                                    ? Wrap(
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            gameTypes[index]["name"].toString(),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                            ),
                                          ),
                                          Container(
                                            color: Colors.red,
                                            child: Text(
                                              widget.indexData["totalSum"] == null
                                                  ? "0"
                                                  : widget.indexData["totalSum"][index - 1]["num"].toString(),
                                              style: TextStyle(
                                                fontSize: 8,
                                                color: Colors.white,
                                              ),
                                            ),
                                          )
                                        ],
                                      )
                                    : Text(
                                        gameTypes[index]["name"].toString(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                        ),
                                      ),
                                onTap: () {
                                  if (index == gameTypeIndex) {
                                    return;
                                  }

                                  setState(() {
                                    gameTypeIndex = index;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                /// E 游戏

                /// S 类型
                Container(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "类型",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          shadows: <Shadow>[
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(1, 2),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        flex: 1,
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(
                            Radius.circular(5),
                          ),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: Container(
                            color: Colors.black26,
                            child: Wrap(
                              children: gameSumStatusData.asMap().keys.map((index) {
                                return gameTypeRadio(
                                  index: gameSumStatus["index"] == index,
                                  child: Text(
                                    gameSumStatusData[index]["s"].toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                  onTap: () {
                                    if (index == this.gameSumStatus["index"]) {
                                      return;
                                    }

                                    setState(() {
                                      gameSumStatus["index"] = index;
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                /// E 类型

                /// S 排序
                Container(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 6,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "排序",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          shadows: <Shadow>[
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(1, 2),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        flex: 1,
                        child: DropdownButton<String>(
                          value: gameSortValue,
                          underline: Container(
                            height: 0,
                            color: Colors.transparent,
                          ),
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          dropdownColor: Colors.black,
                          isDense: false,
                          isExpanded: true,
                          onChanged: (String value) {
                            setState(() {
                              gameSortValue = value;
                            });
                          },
                          items: gameSort.map<DropdownMenuItem<String>>((e) {
                            return DropdownMenuItem(
                              value: e["value"],
                              child: Text(
                                e["name"],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                /// E 排序
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: EluiButtonComponent(
                    theme: EluiButtonTheme(
                      backgroundColor: Color(0xfff2f2f2),
                    ),
                    size: ButtonSize.mini,
                    child: Text(
                      "重置",
                      style: TextStyle(
                        color: Colors.black45,
                      ),
                    ),
                    onTap: () => this.onInitial(),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Expanded(
                  flex: 4,
                  child: EluiButtonComponent(
                    child: Text(
                      "确认",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    size: ButtonSize.mini,
                    theme: EluiButtonTheme(
                      backgroundColor: Color(0xff364e80),
                    ),
                    onTap: () {
                      this.onChange();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
