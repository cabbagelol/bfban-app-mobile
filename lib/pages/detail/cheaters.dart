import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';

import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:flutter_plugin_elui/elui.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:bfban/constants/api.dart';
import 'package:bfban/router/router.dart';
import 'package:bfban/utils/index.dart';

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

  /// 作弊行为
  static Map cheatingTpyes = Config.cheatingTpyes;

  /// 进度状态
  final List<dynamic> startusIng = Config.startusIng;

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

    print("22333: " + result.toString());

//    if (result.data["error"] == 0) {}
  }

  /// 获取bfban用户信息
  Future _getCheatersInfo() async {
    var result = await Http.request(
      'api/cheaters/${widget.id}',
      method: Http.GET,
    );

    if (result.data != null && result.data["error"] == 0) {
      setState(() {
        cheatersInfo = result.data ?? new Map();
        cheatersInfoUser = result.data["data"]["cheater"][0];
      });

      /// 取最新ID查询
      if (result.data["data"]["origins"].length > 0) {
        this._getTrackerCheatersInfo(result.data["data"]["origins"][0]["cheaterGameName"], result.data["data"]["games"]);
      }

      return cheatersInfo;
    }
  }

  /// 获取游戏类型
  String _getGames(List games) {
    String t = "";
    games.forEach((element) {
      t += "${element["game"].toString().toUpperCase()} ";
    });
    return t;
  }

  /// 回复链接执行
  static _onPeUrl(String url) async {
    if (url.length < 0) {
      return;
    }
    await launch(url);
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

  /// 对比评论身份
  static getUsetIdentity(type) {
    switch (type) {
      case "admin":
        return ["管理员", Colors.white, Colors.redAccent];
        break;
      case "normal":
        return ["玩家", Colors.black, Colors.amber];
        break;
      case "super":
        return ["超管", Colors.white, Colors.blueAccent];
        break;
      default:
        return ["未知", Colors.black, Colors.white12];
    }
  }

  /// 获取用户BFBAN中举报数据
  static Widget _getUserInfo(context, Map cheatersInfo, cheatersInfoUser, startusIng) {
    List<Widget> list = [];

    /// 数据
    Map _data = cheatersInfo["data"];

    /// 所有用户回复信息
    List _allReply = new List();

    /// 回答
    (_data["replies"] ?? []).forEach((i) => {
          i["SystemType"] = 0,
          _allReply.add(i),
        });

    /// 举报
    (_data["reports"] ?? []).forEach((i) => {
          i["SystemType"] = 1,
          _allReply.add(i),
        });

    /// 审核
    (_data["verifies"] ?? []).forEach((i) => {
          i["SystemType"] = 2,
          _allReply.add(i),
        });

    /// 赞同。审核员
    (_data["confirms"] ?? []).forEach((i) => {
          i["SystemType"] = 3,
          _allReply.add(i),
        });

    /// 排序时间帖子
    /// 序列化时间
    _allReply.sort((time, timeing) =>
        new Date().getTurnTheTimestamp(time["createDatetime"])["millisecondsSinceEpoch"] -
        new Date().getTurnTheTimestamp(timeing["createDatetime"])["millisecondsSinceEpoch"]);

    _allReply.forEach(
      (i) {
        /// 作弊类型 若干
        List<Widget> _cheatMethods = new List();
        i['cheatMethods'].toString().split(",").forEach((i) {
          _cheatMethods.add(EluiTagComponent(
            value: cheatingTpyes[i] ?? '未知行为',
            size: EluiTagSize.no2,
            color: EluiTagColor.warning,
          ));
        });

        switch (i["SystemType"].toString()) {
          case "0":
            list.add(
              Container(
                padding: EdgeInsets.only(
                  top: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      width: 10,
                      color: Color(0xfff2f2f2),
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          decoration: new BoxDecoration(
                            color: getUsetIdentity(i["fooPrivilege"])[2],
                            borderRadius: BorderRadius.all(
                              Radius.circular(15.0),
                            ),
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
                            "${getUsetIdentity(i["fooPrivilege"])[0]}",
                            style: TextStyle(
                              color: getUsetIdentity(i["fooPrivilege"])[1],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "${i["foo"]} 回复",
                              //${cheatersInfoUser["originId"]}
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "发布时间: ${new Date().getTimestampTransferCharacter(i['createDatetime'])["Y_D_M"]}",
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

                    /// Html评论内容
                    Container(
                      color: Colors.white,
                      child: Html(
                        data: i["content"],
                        onLinkTap: (src) {
                          _onPeUrl(i["bilibiliLink"].toString());
                        },
                      ),
                    )
                  ],
                ),
              ),
            );
            break;
          case "1":
            list.add(
              Container(
                padding: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      width: 10,
                      color: Color(0xfff2f2f2),
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          decoration: new BoxDecoration(
                            color: getUsetIdentity(i["privilege"])[2],
                            borderRadius: BorderRadius.all(
                              Radius.circular(15.0),
                            ),
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
                                "${i["username"]} 举报在${i["game"]}作弊",
                                //${cheatersInfoUser["originId"]}
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: <Widget>[
                                  Text(
                                    "行为: ",
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Wrap(
                                    spacing: 2,
                                    runSpacing: 2,
                                    children: _cheatMethods,
                                  ),
                                ],
                              ),
                              Text(
                                "发布时间: ${new Date().getTimestampTransferCharacter(i['createDatetime'])["Y_D_M"]}",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          child: Container(
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
                          ),
                          onTap: () {
                            /// 帖子回复
                            Routes.router.navigateTo(
                              context,
                              '/reply/${jsonEncode({
                                "type": 1,
                                "id": cheatersInfoUser["id"],
                                "originUserId": cheatersInfoUser["originUserId"],
                                "userId": cheatersInfo["data"]["reports"][0]["userId"],
                                "toUserId": i["userId"],
                                "foo": i["username"],

                                /// 取第一条举报信息下的userId
                              })}',
                              transition: TransitionType.cupertino,
                            );
                          },
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
                        ),
                      ),
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
                          GestureDetector(
                            child: Icon(
                              Icons.link,
                              color: Colors.blueAccent,
                            ),
                            onTap: () {
                              _onPeUrl(i["bilibiliLink"].toString());
                            },
                          ),
                        ],
                      ),
                    ),

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
                        onLinkTap: (src) {
                          _onPeUrl(src);
                        },
                      ),
                    )
                  ],
                ),
              ),
            );
            break;
          case "2":
            list.add(
              Container(
                padding: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      width: 10,
                      color: Color(0xfff2f2f2),
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          decoration: new BoxDecoration(
                            color: getUsetIdentity(i["privilege"])[2],
                            borderRadius: BorderRadius.all(
                              Radius.circular(15.0),
                            ),
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
                                "${i["username"]} 认为 ${startusIng[int.parse(i["status"])]["s"]}, 作弊判决：",
                                //${cheatersInfoUser["originId"]}
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Wrap(
                                spacing: 2,
                                children: _cheatMethods,
                              ),
                              Text(
                                "发布时间: ${new Date().getTimestampTransferCharacter(i['createDatetime'])["Y_D_M"]}",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            ],
                          ),
                        ),
                        GestureDetector(
                          child: Container(
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
                          ),
                          onTap: () {
                            /// 帖子回复
                            Routes.router.navigateTo(
                              context,
                              '/reply/${jsonEncode({
                                "type": 1,
                                "id": cheatersInfoUser["id"],
                                "originUserId": cheatersInfoUser["originUserId"],
                                "userId": cheatersInfo["data"]["reports"][0]["userId"],
                                "toUserId": i["userId"],
                                "foo": i["foo"],
                                /// 取第一条举报信息下的userId
                              })}',
                              transition: TransitionType.cupertino,
                            );
                          },
                        ),
                      ],
                    ),

                    /// Html评论内容
                    Container(
                      color: Colors.white,
                      child: Html(
                        data: i["suggestion"],
                        onLinkTap: (src) {
                          _onPeUrl(src);
                        },
                      ),
                    )
                  ],
                ),
              ),
            );
            break;
          case "3":
            list.add(
              Container(
                padding: EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      width: 10,
                      color: Color(0xfff2f2f2),
                    ),
                  ),
                ),
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
                                "${i["username"]} 同意该决定",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Wrap(
                                spacing: 2,
                                children: _cheatMethods,
                              ),
                              Text(
                                "发布时间: ${new Date().getTimestampTransferCharacter(i['createDatetime'])["Y_D_M"]}",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            ],
                          ),
                        ),
                        GestureDetector(
                          child: Container(
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
                          ),
                          onTap: () {
                            /// 帖子回复
                            Routes.router.navigateTo(
                              context,
                              '/reply/${jsonEncode({
                                "type": 1,
                                "id": cheatersInfoUser["id"],
                                "originUserId": cheatersInfoUser["originUserId"],
                                "userId": cheatersInfo["data"]["reports"][0]["userId"],
                                "toUserId": i["userId"],
                                "foo": i["foo"],
                                /// 取第一条举报信息下的userId
                              })}',
                              transition: TransitionType.cupertino,
                            );
                          },
                        ),
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
                          Expanded(
                            flex: 1,
                            child: Html(
                              data: (i["suggestion"] ?? ""), //  startusIng[int.parse(i["status"])]["t"] + ";" +
                              onLinkTap: (src) {
                                _onPeUrl(src);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
            break;
        }
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
                                                  ? new Date().getTimestampTransferCharacter(cheatersInfoUser["createDatetime"])["Y_D_M"]
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
                                                  ? new Date().getTimestampTransferCharacter(cheatersInfoUser["updateDatetime"])["Y_D_M"]
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
                                              cheatersInfo["data"] != null ? this._getGames(cheatersInfo["data"]["games"]) : "",
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
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    left: BorderSide(
                                                      width: 1,
                                                      color: Colors.white12,
                                                    ),
                                                  ),
                                                ),
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
//                                Container(
//                                  padding: EdgeInsets.all(20),
//                                  child: Text(
//                                    "管理记录",
//                                    style: TextStyle(
//                                      fontSize: 20,
//                                      fontWeight: FontWeight.bold,
//                                      color: Colors.white,
//                                    ),
//                                  ),
//                                ),
//                                Container(
//                                  color: Colors.white,
//                                  child: Column(
//                                    children: this._getExamineLog(),
//                                  ),
//                                ),
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
                                _getUserInfo(context, snapshot.data, cheatersInfoUser, startusIng),

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
                            child: GestureDetector(
                              child: Text(
                                "补充证据",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              onTap: () {
                                /// 补充（追加）回复
                                Routes.router.navigateTo(
                                  context,
                                  '/reply/${jsonEncode({
                                    "type": 0,
                                    "id": cheatersInfoUser["id"],
                                    "originUserId": cheatersInfoUser["originUserId"],
                                    "userId": cheatersInfo["data"]["reports"][0]["userId"],
                                    "foo": cheatersInfo["data"]["reports"][0]["username"],

                                    /// 取第一条举报信息下的userId
                                  })}',
                                  transition: TransitionType.cupertino,
                                );
                              },
                            ))
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
