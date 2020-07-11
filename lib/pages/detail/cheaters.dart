import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_plugin_elui/elui.dart';

import 'package:bfban/utils/index.dart';
import 'package:flutter_html/style.dart';

class cheatersPage extends StatefulWidget {
  final id;

  cheatersPage({this.id = ""});

  @override
  _cheatersPageState createState() => _cheatersPageState();
}

class _cheatersPageState extends State<cheatersPage> with SingleTickerProviderStateMixin {
  Map cheatersInfo = Map();

  Map cheatersInfoUser = Map();

  Future futureBuilder;

  TabController _tabController;

  /// 导航个体
  final List<Tab> myTabs = <Tab>[
    Tab(text: '举报信息'),
    Tab(text: '审核记录'),
    Tab(text: '曾用名称'),
    Tab(text: '比赛表'),
  ];

  /// 进度状态
  final List<dynamic> startusIng = [
    {
      "s": "未处理",
      "t": "还未处理",
      "c": Colors.white70,
    },
    {
      "s": "作弊玩家",
      "t": "确定存在作弊行为",
      "c": Colors.red,
    },
    {
      "s": "待观察",
      "t": "存在嫌疑,待观察",
      "c": Colors.red,
    }
  ];

  @override
  void initState() {
    super.initState();
    this._getCheatersInfo();

    _tabController = TabController(vsync: this, length: myTabs.length);

    futureBuilder = this._getCheatersInfo();
  }

  /// 获取tracker上用户信息
  Future _getTrackerCheatersInfo(String name, List games) async {
    var result = await Http.request(
      'api/v2/${games[0]["game"]}/standard/profile/origin/${name}',
      method: Http.GET,
      typeUrl: "tracker",
    );

    if (result["error"] == 0) {}
  }

  /// 获取bfban用户信息
  Future _getCheatersInfo() async {
    var result = await Http.request(
      'api/cheaters/${widget.id}',
      method: Http.GET,
    );

    if (result != null && result["error"] == 0) {
      setState(() {
        cheatersInfo = result ?? new Map();
        cheatersInfoUser = result["data"]["cheater"][0];
      });

      /// 取最新ID查询
      if (result["data"]["origins"].length > 0) {
        this._getTrackerCheatersInfo(result["data"]["origins"][0]["cheaterGameName"], result["data"]["games"]);
      }

      return cheatersInfo;
    }
  }

  /// 请求更新用户名称列表
  void _seUpdateUserNameList() async {
    var result = await Http.request(
      'api/cheaters/updateCheaterInfo',
      method: Http.POST,
    );

    if (result["error"] == 0) {
      this._getCheatersInfo();
    } else {
      EluiMessageComponent.error(context)(
        child: Text("请求异常请联系开发者"),
      );
    }
  }

  /// 获取管理记录
  List<Widget> _getExamineLog() {
    List<Widget> list = [];

    /// 赞同
    var confirms = cheatersInfo["data"]["confirms"] ?? [];

    /// 管理审计
    var verofies = cheatersInfo["verifies"] ?? [];

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
                          data: startusIng[int.parse(i["status"])]["t"] + ";" + i["suggestion"],
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

  /// 对比评论身份
  static getUsetIdentity(type) {
    switch (type) {
      case "admin":
        return ["管理员", Colors.white, Colors.redAccent];
        break;
      case "normal":
        return ["玩家", Colors.black, Colors.amber];
        break;
      default:
        return ["未知", Colors.black, Colors.white12];
    }
  }

  /// 获取用户BFBAN中举报数据
  static Widget _getUserInfo(cheatersInfo, cheatersInfoUser) {
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
                            i["bilibiliLink"] == "" ? "暂无视频" : i["bilibiliLink"],
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

  /// 曾经使用过的名称
  static Widget _getUsedname(cheatersInfo) {
    List<TableRow> list = [
      new TableRow(
        children: <Widget>[
          new TableCell(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                '游戏ID',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          new TableCell(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                '更改时间',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    ];

    cheatersInfo["data"]["origins"].forEach((i) {
      list.add(
        TableRow(
          children: <Widget>[
            TableCell(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  i["cheaterGameName"],
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            TableCell(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  i["createDatetime"],
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });

    return Container(
      color: Colors.black12,
      child: Table(
        border: new TableBorder.all(
          width: 1.0,
          color: Color.fromRGBO(251, 251, 251, 0.01),
        ),
        children: list,
      ),
    );
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
                                    labelPadding: EdgeInsets.only(
                                      left: 0,
                                      right: 0,
                                    ),
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
                                  child: Row(
                                    children: <Widget>[
                                      /// 用户名称
                                      Text(
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

                                      /// 最终状态 ?
//                                      Chip(
//                                        label: Text(cheatersInfo["data"]["confirms"][0]["cheatMethods"].toString()),
//                                      ),
                                      Container(
                                        padding: EdgeInsets.only(
                                          left: 5,
                                          right: 5,
                                        ),
                                        margin: EdgeInsets.only(
                                          left: 4,
                                        ),
                                        color: startusIng[int.parse(cheatersInfo["data"]["cheater"][0]["status"])]["c"],
                                        child: Text(
                                          startusIng[int.parse(cheatersInfo["data"]["cheater"][0]["status"])]["s"].toString(),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
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
                            /// S 举报信息
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
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
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Container(
                                        child: Column(
                                          children: <Widget>[
                                            Text(
                                              cheatersInfoUser != null
                                                  ? cheatersInfoUser["createDatetime"].replaceAll("T", " ").replaceAll("Z", " ")
                                                  : "",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
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
                                            Text(
                                              cheatersInfoUser != null
                                                  ? cheatersInfoUser["updateDatetime"].replaceAll("T", " ").replaceAll("Z", " ")
                                                  : "",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
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
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Container(
                                        child: Column(
                                          children: <Widget>[
                                            Text(
                                              cheatersInfo["data"] != null ? cheatersInfo["data"]["games"][0]["game"] : "",
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
                                              cheatersInfoUser != null ? cheatersInfo["data"]["cheater"][0]["n"].toString() + "/次" : "",
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
                                              (cheatersInfo["data"]["reports"].length + cheatersInfo["data"]["verifies"].length)
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
                                Container(
                                  padding: EdgeInsets.all(20),
                                  child: Text(
                                    "判决",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
//                                (cheatersInfo["data"]["confirms"])
                                cheatersInfo["data"]["confirms"].length > 0
                                    ? Container(
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
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                              constraints: BoxConstraints(
                                                minHeight: 60,
                                                maxHeight: 100,
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    cheatersInfo["data"]["confirms"][0]["username"].toString(),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                  Text(
                                                    "裁决人",
                                                    style: TextStyle(
                                                      color: Colors.white54,
                                                      fontSize: 12,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              padding: EdgeInsets.only(
                                                right: 20,
                                              ),
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  right: BorderSide(
                                                    width: 1,
                                                    color: Colors.white12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Container(
                                                child: Column(
                                                  children: <Widget>[
                                                    Text(
                                                      "石锤作弊",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 30,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                    Text(
                                                      cheatersInfo["data"]["confirms"][0]["cheatMethods"].toString(),
                                                      style: TextStyle(
                                                        color: Colors.white54,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    : Container(
                                        color: Colors.black12,
                                        margin: EdgeInsets.only(
                                          left: 10,
                                          right: 10,
                                        ),
                                        padding: EdgeInsets.all(120),
                                        child: Center(
                                          child: Text(
                                            "该玩家没有违规行为",
                                            style: TextStyle(
                                              color: Colors.white12,
                                            ),
                                          ),
                                        ),
                                      ),
                              ],
                            ),

                            /// E 举报信息

                            /// S 审核记录
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
                                _getUserInfo(snapshot.data, cheatersInfoUser),

                                /// E记录
                              ],
                            ),

                            /// E 审核记录

                            /// S 曾用名称
                            Container(
                              padding: EdgeInsets.only(
                                top: 5,
                                left: 10,
                                right: 10,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                          child: Column(
                                        children: <Widget>[
                                          Text(
                                            "过去该用户使用的账户名称",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            "如果无法更新列表或获取,仅出现该用户未游玩过该游戏以及已被封禁二种状态.",
                                            style: TextStyle(
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white54,
                                            ),
                                          ),
                                        ],
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                      )),
                                      FlatButton.icon(
                                        color: Colors.black12,
                                        padding: EdgeInsets.zero,
                                        icon: Icon(
                                          Icons.refresh,
                                          size: 25,
                                          color: Colors.white,
                                        ),
                                        textTheme: ButtonTextTheme.primary,
                                        label: Text(
                                          "刷新",
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        onPressed: () => {
                                          this._seUpdateUserNameList(),
                                        },
                                      )
                                    ],
                                  ),
                                  Container(
                                    child: _getUsedname(snapshot.data),
                                    margin: EdgeInsets.only(
                                      top: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// E 曾用名称

                            /// S 比赛表
                            Column(
                              children: <Widget>[],
                            )

                            /// E 比赛表
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
        color: type == '0' ? Color.fromRGBO(0, 0, 0, .3) : Color.fromRGBO(255, 255, 255, .07),
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
