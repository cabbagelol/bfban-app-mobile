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
  /// 举报列表
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

  /// 筛选widget
  Widget homeScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 40,
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 20,
          ),
          child: Wrap(
            spacing: 5,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Icon(
                Icons.filter,
                color: Colors.white,
                size: 40,
              ),
              Text(
                "筛选",
                style: TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 10,
        ),

        /// S 游戏
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
                          if (index == gameTypeIndex) {
                            return;
                          }

                          setState(() {
                            gameTypeIndex = index;
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

        /// E 游戏

        /// S 类型
        Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 6,
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

        /// E 类型
      ],
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
        title: titleSearch(
          theme: titleSearchTheme.black,
        ),
      ),
      drawerScrimColor: Colors.black87,
      drawer: homeScreen(),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: !indexPagesState
                ? RefreshIndicator(
                    onRefresh: _onRefresh,
                    color: Colors.white,
                    backgroundColor: Colors.yellow,
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
