import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:bfban/utils/index.dart';
import 'package:flutter_html/style.dart';

class cheatersPage extends StatefulWidget {
  final id;

  cheatersPage({this.id = ""});

  @override
  _cheatersPageState createState() => _cheatersPageState();
}

class _cheatersPageState extends State<cheatersPage>
    with SingleTickerProviderStateMixin {
  Map cheatersInfo = Map();

  Map cheatersInfoUser = Map();

  Future futureBuilder;

  TabController _tabController;

  /// 导航个体
  final List<Tab> myTabs = <Tab>[
    Tab(text: '举报信息'),
    Tab(text: '审核记录'),
    Tab(text: '曾用名称'),
  ];

  /// 进度状态
  final List startusIng = ["", "确定存在作弊行为", "存在嫌疑,待观察"];

  @override
  void initState() {
    super.initState();
    this._getCheatersInfo();

    _tabController = TabController(vsync: this, length: myTabs.length);

    futureBuilder = this._getCheatersInfo();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: this.futureBuilder,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bk-companion.jpg'),
                fit: BoxFit.fitHeight,
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                title: Text(
                  "加载中",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bk-companion.jpg'),
              fit: BoxFit.fitHeight,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
            ),

            /// 内容
            body: DefaultTabController(
              length: myTabs.length,
              child: ListView(
                children: <Widget>[
                  /// S 主体框架
                  Container(
                    margin: EdgeInsets.only(
                      top: 100,
                    ),
                    color: Color(0xff111b2b),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        /// S header
                        Row(
                          children: <Widget>[
                            Stack(
                              overflow: Overflow.visible,
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.only(
                                    left: 100,
                                  ),
                                  color: Color(0xff364e80),
                                  height: 50,
                                  width: MediaQuery.of(context).size.width,

                                  /// Tab 导航
                                  child: TabBar(
                                    unselectedLabelColor: Colors.white38,
                                    labelColor: Colors.yellow,
                                    labelStyle: TextStyle(
                                      fontSize: 15,
                                    ),
                                    indicatorColor: Colors.yellow,
                                    controller: _tabController,
                                    tabs: myTabs,
                                    onTap: (i) {
                                      setState(() {
                                        this._tabController.index = i;
                                      });
                                    },
                                  ),
                                ),
                                Positioned(
                                  top: -25,
                                  left: 100,
                                  child: Text(
                                    cheatersInfoUser["originId"].toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      shadows: <Shadow>[
                                        Shadow(
                                          color: Colors.black12,
                                          offset: Offset(1, 2),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: -30,
                                  left: 10,
                                  child: Image.network(
                                    cheatersInfoUser["avatarLink"] ?? "",
                                    width: 70,
                                    height: 70,
                                  ),
                                )
                              ],
                            )
                          ],
                        ),

                        /// E header

                        IndexedStack(
                          index: _tabController.index,
                          children: <Widget>[
                            /// 举报信息
                            Column(
                              children: <Widget>[
                                /// S 信息方块
                                Container(
                                  color: Colors.black12,
                                  margin: EdgeInsets.only(
                                    top: 20,
                                    left: 10,
                                    right: 10,
                                  ),
                                  padding: EdgeInsets.only(
                                    top: 10,
                                    bottom: 10,
                                    left: 10,
                                    right: 10,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Container(
                                        child: Column(
                                          children: <Widget>[
//                                            Text(
//                                              cheatersInfoUser != null
//                                                  ? cheatersInfoUser["createDatetime"].replaceAll("T", " ").replaceAll("Z", " ")
//                                                  : "",
//                                              style: TextStyle(
//                                                color: Colors.white,
//                                                fontSize: 16,
//                                              ),
//                                              overflow: TextOverflow.ellipsis,
//                                              maxLines: 1,
//                                            ),
                                            Text(
                                              "第一次举报时间",
                                              style: TextStyle(
                                                color: Colors.white54,
                                                fontSize: 12,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        child: Column(
                                          children: <Widget>[
//                                            Text(
//                                              cheatersInfoUser != null
//                                                  ? cheatersInfoUser["updateDatetime"].replaceAll("T", " ").replaceAll("Z", " ")
//                                                  : "",
//                                              style: TextStyle(
//                                                color: Colors.white,
//                                                fontSize: 16,
//                                              ),
//                                              overflow: TextOverflow.ellipsis,
//                                              maxLines: 1,
//                                            ),
                                            Text(
                                              "最后更新",
                                              style: TextStyle(
                                                color: Colors.white54,
                                                fontSize: 12,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  color: Colors.black12,
                                  margin: EdgeInsets.only(
                                    left: 10,
                                    right: 10,
                                  ),
                                  padding: EdgeInsets.only(
                                    top: 10,
                                    bottom: 10,
                                    left: 10,
                                    right: 10,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Container(
                                        child: Column(
                                          children: <Widget>[
                                            Text(
                                              cheatersInfo["data"] != null
                                                  ? cheatersInfo["data"]
                                                      ["games"][0]["game"]
                                                  : "",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              "被举报游戏",
                                              style: TextStyle(
                                                color: Colors.white54,
                                                fontSize: 12,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        child: Column(
                                          children: <Widget>[
                                            Text(
                                              cheatersInfoUser != null
                                                  ? cheatersInfo["data"]["cheater"][0]["n"].toString() + "/次"
                                                  : "",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              "围观",
                                              style: TextStyle(
                                                color: Colors.white54,
                                                fontSize: 12,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        child: Column(
                                          children: <Widget>[
                                            Text(
                                              (cheatersInfo["data"]["reports"]
                                                              .length +
                                                          cheatersInfo["data"]
                                                                  ["verifies"]
                                                              .length)
                                                      .toString() +
                                                  "/条",
                                              //cheatersInfo["data"]["verifies"]
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              "回复",
                                              style: TextStyle(
                                                color: Colors.white54,
                                                fontSize: 12,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                /// E 信息方块
                              ],
                            ),

                            /// 审核记录
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                /// S记录
                                Container(
                                  padding: EdgeInsets.all(20),
                                  child: Text(
                                    "管理记录",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Container(
                                  color: Colors.white,
                                  child: Column(
                                    children: this._getExamineLog(),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 10),
                                  padding: EdgeInsets.all(20),
                                  child: Text(
                                    "玩家举报记录",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                _gelPL(snapshot.data, cheatersInfoUser),

                                /// E记录
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),

                  /// E 主体框架
                ],
              ),
            ),

            /// 底部栏
            bottomNavigationBar: _tabController.index == 1
                ? Container(
                    decoration: BoxDecoration(
                      color: Color(0xffffffff),
                      border: Border(
                        top: BorderSide(
                          width: 1.0,
                          color: Colors.black12,
                        ),
                      ),
                    ),
                    padding: EdgeInsets.only(
                      top: 10,
                      left: 20,
                      right: 20,
                      bottom: 10,
                    ),
                    height: 50,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.message,
                          color: Colors.orangeAccent,
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            "补充证据",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }

  /// 获取房源相册
  Future _getCheatersInfo() async {
    var result =
    await Http.request('api/cheaters/${widget.id}', method: Http.GET);

    if (result.data != null && result.data["error"] == 0) {
      setState(() {
        cheatersInfo = result.data ?? new Map();
        cheatersInfoUser = result.data["data"]["cheater"][0];
      });

      return cheatersInfo;
    }
  }

  /// 获取管理记录
  List<Widget> _getExamineLog() {
    List<Widget> list = [];

    /// 赞同
    var confirms = cheatersInfo["data"]["confirms"] ?? [];
    /// 管理审计
    var verofies = cheatersInfo["data"]["verifies"] ?? [];

    (verofies).forEach((i) {
      list.add(
        Container(
          padding: EdgeInsets.only(top: 10, bottom: 10),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    decoration: new BoxDecoration(
                      color: getUsetIdentity(i["privilege"])[2],
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    ),
                    margin: EdgeInsets.only(
                      left: 20,
                      top: 5,
                      bottom: 5,
                      right: 10,
                    ),
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 10,
                      top: 1,
                      bottom: 1,
                    ),
                    child: Text(
                      "${getUsetIdentity(i["privilege"])[0]}",
                      style: TextStyle(
                        color: getUsetIdentity(i["privilege"])[1],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "${i["username"]}审查",
                          //${cheatersInfoUser["originId"]}
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "认定行为: ${i['cheatMethods'] ?? "保持沉默"}",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "发布时间: ${i['createDatetime']}",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      right: 10,
                    ),
                    child: Text(
                      "回复",
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 14,
                      ),
                    ),
                  )
                ],
              ),

              /// Html评论内容
              Container(
                  margin: EdgeInsets.only(
                    top: 2,
                  ),
                  color: Colors.white,
                  child: Row(
                    children: <Widget>[
                      Padding(
                        child: Text(
                          "\“",
                          style: TextStyle(
                            fontSize: 40,
                            color: Colors.black12,
                          ),
                        ),
                        padding: EdgeInsets.only(left: 20),
                      ),
                      Flexible(
                        flex: 1,
                        child: Html(
                          data: startusIng[int.parse(i["status"])] +
                              ";" +
                              i["suggestion"],
                        ),
                      )
                    ],
                  ))
            ],
          ),
        ),
      );
    });
    return list;
  }

  static getUsetIdentity(type) {
    switch (type) {
      case "admin":
        return ["管理员", Colors.white, Colors.redAccent];
        break;
      case "normal":
        return ["玩家", Colors.black, Colors.amber];
        break;
    }
  }

  static _gelPL(cheatersInfo, cheatersInfoUser) {
    var style = TextStyle(
        color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500);
    List<Widget> list = [];

    cheatersInfo["data"]["reports"].forEach(
      (i) {
        list.add(
          Container(
            padding: EdgeInsets.only(top: 10),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      decoration: new BoxDecoration(
                        color: getUsetIdentity(i["privilege"])[2],
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                      ),
                      margin: EdgeInsets.only(
                        left: 20,
                        top: 5,
                        bottom: 5,
                        right: 10,
                      ),
                      padding: EdgeInsets.only(
                        left: 10,
                        right: 10,
                        top: 1,
                        bottom: 1,
                      ),
                      child: Text(
                        "${getUsetIdentity(i["privilege"])[0]}",
                        style: TextStyle(
                          color: getUsetIdentity(i["privilege"])[1],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "${i["username"]}的举报",
                          //${cheatersInfoUser["originId"]}
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "行为: ${i['cheatMethods']}",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "发布时间: ${i['createDatetime']}",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      ],
                    ),
                  ],
                ),

                /// S 评论视频
                Container(
                    margin: EdgeInsets.only(
                      top: 5,
                      left: 10,
                      right: 10,
                    ),
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 10,
                      top: 4,
                      bottom: 4,
                    ),
                    decoration: BoxDecoration(
                        color: Color(0xfff2f2f2),
                        border: Border.all(
                          color: Colors.black12,
                          width: 1,
                        )),
                    child: Row(
                      children: <Widget>[
                        Text(
                          "附加 ",
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            i["bilibiliLink"] == ""
                                ? "暂无视频"
                                : i["bilibiliLink"],
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.link,
                          color: Colors.blueAccent,
                        )
                      ],
                    )),

                /// E 评论视频

                /// Html评论内容
                Container(
                  color: Colors.white,
                  child: Html(
                    data: i["description"],
                    style: {
                      "img": Style(
                        border: Border.all(
                          width: 1.0,
                          color: Colors.black12,
                        ),
                      ),
                    },
                    onImageTap: (src) {
                      // Display the image in large form.
                    },
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
    return Column(
      children: list,
    );
  }
}

/// WG九宫格
class detailCellCard extends StatelessWidget {
  final text;
  final value;

  detailCellCard({
    this.text = "",
    this.value = "",
  });

  @override
  Widget build(BuildContext context) {
    throw Column(
      children: <Widget>[
        Text(
          text ?? "",
          style: TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        )
      ],
    );
  }
}

/// WG单元格
class detailCheatersCard extends StatelessWidget {
  final value;
  final cont;
  final type;
  final onTap;
  final fontSize;

  detailCheatersCard({
    this.value,
    this.cont,
    this.type = '0',
    this.fontSize,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        color: type == '0'
            ? Color.fromRGBO(0, 0, 0, .3)
            : Color.fromRGBO(255, 255, 255, .07),
        padding: EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    value,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize ?? 20,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  '${cont}',
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
      onTap: onTap != null ? onTap : null,
    );
  }
}
