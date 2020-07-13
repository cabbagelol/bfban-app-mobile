import 'package:bfban/constants/api.dart';
import 'package:bfban/router/router.dart';
import 'package:bfban/utils/index.dart';
import 'package:bfban/widgets/edit/gameTypeRadio.dart';
import 'package:bfban/widgets/index/search.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_plugin_elui/elui.dart';

class homePage extends StatefulWidget {
  @override
  _homePageState createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  var indexDate = new Map();

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
  }

  /// 获取列表
  void _getIndexList() async {
    Response result = await Http.request(
      'api/cheaters/',
      parame: cheatersPost,
      method: Http.GET,
    );

    setState(() {
      indexPagesState = true;
    });

    if (result.data["error"] == 0) {
      setState(() {
        indexDate = result.data;
        if (this.cheatersPost["page"] > 1) {
          result.data["data"].forEach((i) {
            indexDataList.add(i);
          });
        } else {
          indexDataList = result.data["data"];
        }
      });
    } else if (result.data["code"] == -2) {
      EluiMessageComponent.error(context)(
        child: Text("请求异常请联系开发者"),
      );
    }

    setState(() {
      indexPagesState = false;
    });
  }

  /// 筛选
  void _setGameType(int index) {

    if (index == this.gameTypeIndex) {
      return;
    }

    setState(() {
      this.cheatersPost["page"] = 1;
      this.cheatersPost["game"] = index == 0 ? "" : Config.game["type"][index - 1]["name"];
      this.gameTypeIndex = index;
    });

    setState(() => {
          _scrollController.animateTo(
            0.0,
            duration: Duration(milliseconds: 500),
            curve: Curves.decelerate,
          ),
        });

    this._getIndexList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: SearchHead(),
      ),
      body: Column(
        children: <Widget>[
          /// S 游戏类型
          Container(
            color: Color(0xff111b2b),
            padding: EdgeInsets.only(
              top: 20,
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
                    color: Color(0xff364e80),
                    fontSize: 15,
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                Row(
                  children: <Widget>[
                    gameTypeRadio(
                      select: 1,
                      index: gameTypeIndex == 0,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 10,
                          right: 10,
                        ),
                        child: Text(
                          "所有",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                          ),
                        ),
                      ),
                      onTap: () {
                        this._setGameType(0);
                      },
                    ),
                    gameTypeRadio(
                      select: 1,
                      index: gameTypeIndex == 1,
                      child: Image.asset(
                        "assets/images/edit/battlefield-1-logo.png",
                        width: 80,
                      ),
                      onTap: () {
                        this._setGameType(1);
                      },
                    ),
                    gameTypeRadio(
                      select: 3,
                      index: gameTypeIndex == 2,
                      child: Image.asset(
                        "assets/images/edit/battlefield-v-png-logo.png",
                        width: 80,
                      ),
                      onTap: () {
                        this._setGameType(2);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// E 游戏类型

          /// S 状态
//          Container(
//            color: Color(0xff111b2b),
//            padding: EdgeInsets.only(
//              left: 20,
//              right: 20,
//              bottom: 10,
//            ),
//            child: Row(
//              children: <Widget>[
//                Text(
//                  "状态",
//                  style: TextStyle(
//                    color: Color(0xff364e80),
//                    fontSize: 15,
//                  ),
//                ),
//                SizedBox(
//                  width: 15,
//                ),
//                gameTypeRadio(
//                  select: 1,
//                  index: gameStateIndex == 0,
//                  child: Padding(
//                    padding: EdgeInsets.only(
//                      left: 10,
//                      right: 10,
//                    ),
//                    child: Text(
//                      "所有",
//                      style: TextStyle(
//                        color: Colors.white,
//                        fontSize: 9,
//                      ),
//                    ),
//                  ),
//                  onTap: () {
////                    this._setGameType(0);
//                  },
//                ),
//                gameTypeRadio(
//                  select: 1,
//                  index: gameStateIndex == 0,
//                  child: Padding(
//                    padding: EdgeInsets.only(
//                      left: 10,
//                      right: 10,
//                    ),
//                    child: Text(
//                      "所有",
//                      style: TextStyle(
//                        color: Colors.white,
//                        fontSize: 9,
//                      ),
//                    ),
//                  ),
//                  onTap: () {
////                    this._setGameType(0);
//                  },
//                ),
//                gameTypeRadio(
//                  select: 1,
//                  index: gameStateIndex == 0,
//                  child: Padding(
//                    padding: EdgeInsets.only(
//                      left: 10,
//                      right: 10,
//                    ),
//                    child: Text(
//                      "所有",
//                      style: TextStyle(
//                        color: Colors.white,
//                        fontSize: 9,
//                      ),
//                    ),
//                  ),
//                  onTap: () {
////                    this._setGameType(0);
//                  },
//                ),
//              ],
//            ),
//          ),
          /// E 状态

          Expanded(
            flex: 1,
            child: indexDataList.length > 0
                ? RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: indexDataList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return homeItem(
                          item: indexDataList[index],
                        );
                      },
                    ),
                  )
                : EluiVacancyComponent(
                    title: "BFBAN | 数据加载",
                  ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.black,
          size: 40,
        ),
        onPressed: () {
          Routes.router.navigateTo(
            context,
            '/edit',
            transition: TransitionType.cupertino,
          );
        },
        backgroundColor: Colors.yellow,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  /**
   * 加载更多时显示的组件,给用户提示
   */
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

  /**
   * 下拉刷新方法,为list重新赋值
   */
  Future<Null> _onRefresh() async {
    await Future.delayed(Duration(seconds: 1), () {
      this._getIndexList();
    });
  }

  /**
   * 上拉加载更多
   */
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

class homeItem extends StatelessWidget {
  final item;

  homeItem({
    this.item,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Routes.router.navigateTo(
          context,
          '/detail/cheaters/${item["originUserId"]}',
          transition: TransitionType.cupertino,
        );
      },
      child: Container(
        color: Color.fromRGBO(0, 0, 0, .3),
        margin: EdgeInsets.only(bottom: 1),
        padding: EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              margin: EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(100),
                image: DecorationImage(
                  image: NetworkImage(
                    item["avatarLink"],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(item["originId"], style: TextStyle(color: Colors.white, fontSize: 20)),
                  Row(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.visibility,
                            color: Colors.white,
                            size: 13,
                          ),
                          Text(item["n"].toString() ?? "", style: TextStyle(color: Colors.white, fontSize: 12))
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.add_comment,
                            color: Colors.white,
                            size: 13,
                          ),
                          Text(item["commentsNum"].toString() ?? "", style: TextStyle(color: Colors.white, fontSize: 13))
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  "发布日期:",
                  style: TextStyle(
                    color: Color.fromRGBO(255, 255, 255, .6),
                    fontSize: 12,
                  ),
                ),
                Text(
                  new Date().getTimestampTransferCharacter(item["createDatetime"])["Y_D_M"],
                  style: TextStyle(
                    color: Color.fromRGBO(255, 255, 255, .6),
                    fontSize: 13,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
