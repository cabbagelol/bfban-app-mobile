/// 首页

import 'dart:convert';

import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:bfban/constants/api.dart';
import 'package:bfban/router/router.dart';
import 'package:bfban/utils/index.dart';
import 'package:bfban/widgets/edit/gameTypeRadio.dart';
import 'package:bfban/widgets/index.dart';

import 'package:flutter/rendering.dart';
import 'package:flutter_plugin_elui/elui.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map indexData = new Map();

  List indexDataList = new List();

  Map<String, dynamic> cheatersPost = {
    "game": "bf1",
    "status": 100,
    "sort": "updateDatetime",
    "page": 1,
    "tz": "Asia%2FShanghai",
    "limit": 40,
  };

  bool indexPagesState = true;

  Map<dynamic, dynamic> gameSumStatus = {
    "index": 0,
  };

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

  int gameTypeIndex = 0;

  int gameStateIndex = 0;

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    this._getIndexList();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _getMore();
      }
    });

    setState(() {
      gameTypes.addAll(Config.game["type"]);

      gameSumStatusData.addAll(Config.startusIng);
    });
  }

  /// 获取列表
  void _getIndexList() async {
    setState(() {
      indexPagesState = true;
    });

    Response result = await Http.request(
      'api/cheaters/',
      parame: cheatersPost,
      method: Http.GET,
    );

    setState(() {
      if (result.data["error"] == 0) {
        indexData = result.data;

        if (this.cheatersPost["page"] > 1) {
          result.data["data"].forEach((i) {
            indexDataList.add(i);
          });
        } else {
          indexDataList = result.data["data"];
        }
      } else if (result.data["code"] == -2) {
        EluiMessageComponent.error(context)(
          child: Text("请求异常请联系开发者"),
        );
      }
    });

    setState(() {
      indexPagesState = false;
    });
  }

  /// 筛选
  void _setGameType() {
    print("233");
    setState(() {
      this
          .cheatersPost
          .addAll({"page": 1, "game": gameTypes[gameTypeIndex]["value"], "status": gameSumStatusData[gameSumStatus["index"]]["value"]});

      _scrollController.animateTo(
        0.0,
        duration: Duration(milliseconds: 500),
        curve: Curves.decelerate,
      );
    });

    this._getIndexList();
  }

  /// 搜索
  void _onSearch(String value) {
    if (value == "") {
      EluiMessageComponent.warning(context)(
        child: Text("请填写搜索内容"),
      );
      return;
    }

    Routes.router.navigateTo(
      context,
      '/search/${jsonEncode({
        "id": value,
      })}',
      transition: TransitionType.cupertino,
    );
  }

  /// 发布举报信息
  void _opEnEdit() async {
    dynamic _login = await Storage.get('com.bfban.login');

    if (_login == null) {
      EluiMessageComponent.error(context)(
        child: Text("请先登录BFBAN"),
      );
      return;
    }

    Routes.router.navigateTo(
      context,
      '/edit',
      transition: TransitionType.cupertinoFullScreenDialog,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: SearchHead(
          onSearch: (String value) => this._onSearch(value),
        ),
      ),
      body: Column(
        children: <Widget>[
          /// S 游戏类型
          Container(
            padding: EdgeInsets.only(
              top: 10,
              left: 20,
              right: 20,
              bottom: 6,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  "游戏",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
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
                                  children: <Widget>[
                                    Text(
                                      gameTypes[index]["name"].toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Container(
                                      color: Colors.red,
                                      child: Text(
                                        indexData["totalSum"] == null ? "0" : indexData["totalSum"][index - 1]["num"].toString(),
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
                            if (index == this.gameTypeIndex) {
                              return;
                            }

                            setState(() {
                              this.gameTypeIndex = index;
                            });

                            this._setGameType();
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// E 游戏类型

          /// S 状态
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
                  "类型",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
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
                      color: Colors.black38,
                      height: 28,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: gameSumStatusData.asMap().keys.map((index) {
                          return gameTypeRadio(
                            index: gameSumStatus["index"] == index,
                            child: Wrap(
                              children: <Widget>[
                                Text(
                                  gameSumStatusData[index]["s"].toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
//                              Container(
//                                color: Colors.red,
//                                child: Text(
//                                  indexDate["sum"][index]["status"].toString(),
//                                  style: TextStyle(
//                                    fontSize: 8,
//                                    color: Colors.white,
//                                  ),
//                                ),
//                              )
                              ],
                            ),
                            onTap: () {
                              if (index == this.gameSumStatus["index"]) {
                                return;
                              }

                              setState(() {
                                gameSumStatus["index"] = index;
                              });

                              this._setGameType();
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

          /// E 状态

          Expanded(
            flex: 1,
            child: !indexPagesState
                ? RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: indexDataList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return CheatListCard(
                          item: indexDataList[index],
                          onTap: () {
                            Routes.router.navigateTo(
                              context,
                              '/detail/cheaters/${indexDataList[index]["originUserId"]}',
                              transition: TransitionType.cupertino,
                            );
                          },
                        );
                      },
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Opacity(
                          opacity: 0.8,
                          child: textLoad(
                            value: "BFBAN",
                            fontSize: 30,
                          ),
                        ),
                        Text(
                          "Legion of BAN Coalition",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white38,
                          ),
                        )
                      ],
                    ),
                  ),
          ),

          /// S 管理面板
          Container(
            padding: EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 10),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border(
                top: BorderSide(
                  width: 1,
                  color: Colors.white12,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
//                    Text(
//                      "${indexData == null ? 0 : indexData["sum"][0]["num"]}/条",
//                      style: TextStyle(
//                        fontSize: 16,
//                        color: Colors.white,
//                      ),
//                    ),
                    Text(
                      "待审核",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
//                    Text(
//                      "${indexData == null ? 0 : indexData["sum"][2]["num"]}/条",
//                      style: TextStyle(
//                        fontSize: 16,
//                        color: Colors.white,
//                      ),
//                    ),
                    Text(
                      "未处理",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),

          /// E 管理面板
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.mode_edit,
          color: Colors.black,
          size: 30,
        ),
        tooltip: "发布",
        onPressed: () => this._opEnEdit(),
        backgroundColor: Colors.yellow,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  /// 加载更多时显示的组件,给用户提示
  Widget _getMoreWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              '加载中...     ',
              style: TextStyle(fontSize: 16.0),
            ),
            CircularProgressIndicator(
              strokeWidth: 1.0,
            )
          ],
        ),
      ),
    );
  }

  /// 下拉刷新方法,为list重新赋值

  Future<Null> _onRefresh() async {
    await Future.delayed(Duration(seconds: 1), () {
      this._getIndexList();
    });
  }

  /// 上拉加载更多
  Future _getMore() async {
    await Future.delayed(Duration(seconds: 1), () {
      if (indexPagesState) {
        return;
      }

      setState(() {
        this.cheatersPost["page"] += 1;
      });

      this._getIndexList();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }
}
