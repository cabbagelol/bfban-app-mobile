/// 举报信息详情

import 'dart:convert';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fluro/fluro.dart';
import 'package:flutter_plugin_elui/elui.dart';

import 'package:bfban/constants/api.dart';
import 'package:bfban/router/router.dart';
import 'package:bfban/utils/index.dart';
import 'package:bfban/widgets/index.dart';

class CheatersPage extends StatefulWidget {
  /// BFBAN举报iD
  final id;

  CheatersPage({
    this.id = "",
  });

  @override
  _CheatersPageState createState() => _CheatersPageState();
}

class _CheatersPageState extends State<CheatersPage> with SingleTickerProviderStateMixin {
  /// 作弊者结果
  Map cheatersInfo = Map();

  /// 作弊者基本信息
  /// 从[cheatersInfo]取的结果，方便取
  Map cheatersInfoUser = Map();

  /// 异步
  Future futureBuilder;

  /// TAB导航控制器
  TabController _tabController;

  /// 导航下标
  int _tabControllerIndex = 0;

  /// 导航个体
  final List<Tab> myTabs = <Tab>[
    Tab(text: '举报信息'),
    Tab(text: '审核记录'),
  ];

  /// 作弊行为
  static Map cheatingTpyes = Config.cheatingTpyes;

  /// 进度状态
  final List<dynamic> startusIng = Config.startusIng;

  static Map _login;

  /// 曾用名按钮状态 or 列表状态
  Map userNameList = {
    "buttonLoad": false,
    "listLoad": false,
  };

  /// 举报记录
  Widget cheatersRecordWidgetList = Container();

  @override
  void initState() {
    super.initState();

    this.ready();
  }

  void ready() async {
    _login = jsonDecode(await Storage.get('com.bfban.login') ?? '{}');
    _tabController = TabController(vsync: this, length: myTabs.length)
      ..addListener(() {
        setState(() {
          _tabControllerIndex = _tabController.index;
        });
      });
    futureBuilder = this._getCheatersInfo();
  }

  /// 获取tracker上用户信息
  Future _getTrackerCheatersInfo(String name, List games) async {
    Response result = await Http.request(
      'api/v2/${games[0]["game"]}/standard/profile/origin/$name',
      method: Http.GET,
      typeUrl: "tracker",
    );

//    if (result.data["error"] == 0) {}
  }

  /// 获取bfban用户信息
  Future _getCheatersInfo() async {
    Response result = await Http.request(
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
//        this._getTrackerCheatersInfo(result.data["data"]["origins"][0]["cheaterGameName"], result.data["data"]["games"]);
      }

      this._getUserInfo();
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

  /// 赞同决议
  static _setConfirm(context, data) async {
    Response result = await Http.request(
      'api/cheaters/confirm',
      data: {
        "userVerifyCheaterId": data["id"],
        "cheatMethods": data["cheatMethods"],
        "userId": _login["userId"],
        "originUserId": data["originUserId"],
      },
      method: Http.POST,
    );

    if (result.data["error"] == 0) {
      EluiMessageComponent.success(context)(
        child: Text("提交成功"),
      );

      Navigator.pop(context);
    } else {
      EluiMessageComponent.error(context)(
        child: Text("提交失败"),
      );
    }
  }

  /// 请求更新用户名称列表
  void _seUpdateUserNameList() async {
    if (userNameList['buttonLoad']) {
      return;
    }

    if (cheatersInfoUser["originUserId"] == "" || cheatersInfoUser["originUserId"] == null) {
      EluiMessageComponent.error(context)(
        child: Text("无法识别ID"),
      );
      return;
    }

    if (_login == null) {
      EluiMessageComponent.error(context)(
        child: Text("请先登录BFBAN"),
      );
      return;
    }

    setState(() {
      userNameList["buttonLoad"] = true;
    });

    Response result = await Http.request(
      'api/cheaters/updateCheaterInfo',
      data: {
        "originUserId": cheatersInfoUser["originUserId"],
      },
      method: Http.POST,
    );

    if (result.data["error"] == 0) {
      this._getCheatersInfo();
    } else {
      EluiMessageComponent.error(context)(
        child: Text("请求异常请联系开发者"),
      );
    }

    setState(() {
      userNameList["buttonLoad"] = false;
    });
  }

  /// 管理员裁判
  dynamic _onAdminEdit(String uid) {
    if (_login == null) {
      EluiMessageComponent.error(context)(
        child: Text("请先登录BFBAN"),
      );
      return null;
    }

    if (_login["userPrivilege"] != 'admin') {
      EluiMessageComponent.error(context)(
        child: Text("该账户非管理员身份"),
      );
      return null;
    }

    Routes.router
        .navigateTo(
          context,
          '/edit/manage/$uid',
          transition: TransitionType.cupertino,
        )
        .then((value) => this._getCheatersInfo());

    return true;
  }

  /// 用户回复
  dynamic _setReply(num Type) {
    if (['admin', 'super'].contains(_login["userPrivilege"])) {
      return () {
        /// 补充（追加）回复
        /// 取第一条举报信息下的userId
        Routes.router
            .navigateTo(
                context,
                '/reply/${jsonEncode({
                  "type": Type ?? 0,
                  "id": cheatersInfoUser["id"],
                  "originUserId": cheatersInfoUser["originUserId"],
                  "foo": cheatersInfo["data"]["reports"][0]["username"],
                })}',
                transition: TransitionType.cupertino)
            .then((value) {
          this._getCheatersInfo();
        });
      };
    }

    return null;
  }

  /// 审核人员判决
  dynamic onAdminSentence() {
    if (['admin', 'super'].contains(_login["userPrivilege"])) {
      return () {
        this._onAdminEdit(cheatersInfo["data"]["cheater"][0]["originUserId"]);
      };
    }
    return null;
  }

  /// 获取用户BFBAN中举报数据
  /// Map cheatersInfo, cheatersInfoUser, startusIng
  void _getUserInfo() {
    List<Widget> list = [];

    /// 数据
    Map _data = cheatersInfo["data"];

    /// 所有用户回复信息
    List _allReply = new List();

    /// 回答0,举报1,审核2,赞同。审核员3
    [
      {0: 'replies', 1: 0},
      {0: 'reports', 1: 1},
      {0: 'verifies', 1: 2},
      {0: 'confirms', 1: 3}
    ].forEach((Map i) {
      String name = i[0];
      int index = i[1];
      if (_data.containsKey(name)) {
        _data[name].forEach((item) {
          item["SystemType"] = index;
          _allReply.add(item);
        });
      }
    });

    /// 排序时间帖子
    /// 序列化时间
    _allReply.sort((time, timeing) =>
        new Date().getTurnTheTimestamp(time["createDatetime"])["millisecondsSinceEpoch"] -
        new Date().getTurnTheTimestamp(timeing["createDatetime"])["millisecondsSinceEpoch"]);

    _allReply.asMap().keys.forEach(
      (i) {
        /// 作弊类型 若干
        List<Widget> _cheatMethods = new List();

        _allReply[i]['cheatMethods'].toString().split(",").forEach((i) {
          _cheatMethods.add(EluiTagComponent(
            value: cheatingTpyes[i] ?? '未知行为',
            textStyle: TextStyle(
              fontSize: 9,
              color: Colors.white,
            ),
            size: EluiTagSize.no2,
            color: EluiTagColor.warning,
          ));
        });

        switch (_allReply[i]["SystemType"].toString()) {
          case "0":
            list.add(
              CheatUserCheaters(
                i: _allReply[i],
                index: i += 1,
                cheatMethods: _cheatMethods,
                cheatersInfo: cheatersInfo,
                cheatersInfoUser: cheatersInfoUser,
              ),
            );
            break;
          case "1":
            list.add(
              CheatReports(
                i: _allReply[i],
                index: i += 1,
                cheatMethods: _cheatMethods,
                cheatersInfo: cheatersInfo,
                cheatersInfoUser: cheatersInfoUser,
              ),
            );
            break;
          case "2":
            list.add(
              CheatVerifies(
                i: _allReply[i],
                index: i += 1,
                cheatMethods: _cheatMethods,
                cheatersInfo: cheatersInfo,
                cheatersInfoUser: cheatersInfoUser,
                login: _login,
                onConfirm: () => _setConfirm(context, cheatersInfoUser),
              ),
            );
            break;
          case "3":
            list.add(
              CheatConfirms(
                i: _allReply[i],
                index: i += 1,
                cheatMethods: _cheatMethods,
                cheatersInfo: cheatersInfo,
                cheatersInfoUser: cheatersInfoUser,
              ),
            );
            break;
        }
      },
    );

    cheatersRecordWidgetList = Column(
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
                '获取时间',
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
                  new Date().getTimestampTransferCharacter(i["createDatetime"])["Y_D_M"],
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
        /// 数据未加载完成时
        if (snapshot.connectionState != ConnectionState.done) {
          return Container(
            color: Color(0xff111b2b),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                title: Text(
                  "",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              body: Center(
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
          );
        }

        /// 数据完成加载
        return Container(
          color: Color(0xff111b2b),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomRight,
                    colors: [Colors.transparent, Colors.black54],
                  ),
                ),
              ),
              title: TabBar(
                unselectedLabelColor: Colors.white38,
                labelColor: Colors.yellow,
                labelStyle: TextStyle(fontSize: 15),
                indicatorWeight: 3,
                indicatorColor: Colors.yellow,
                controller: _tabController,
                labelPadding: EdgeInsets.only(left: 0, right: 0),
                tabs: myTabs,
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.open_in_new,
                  ),
                  onPressed: () {
                    Share().text(
                      title: '联BFBAN分享',
                      text: '走过路过，不要错过咯~ 快乐围观 ${cheatersInfoUser["originId"]} 在联BAN举报信息',
                      linkUrl: 'https://bfban.com/#/cheaters/${cheatersInfoUser["originUserId"]}',
                      chooserTitle: '联BFBAN分享',
                    );
                    Clipboard.setData(
                      ClipboardData(
                        text: 'https://bfban.com/#/cheaters/${cheatersInfoUser["originUserId"]}',
                      ),
                    );
                  },
                ),
              ],
              iconTheme: IconThemeData(
                color: Colors.white,
              ),
              centerTitle: true,
            ),

            /// 内容
            body: DefaultTabController(
              length: myTabs.length,
              child: Column(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: Color(0xff111b2b),
                      child: TabBarView(
                        controller: _tabController,
                        children: <Widget>[
                          /// S 举报信息
                          ListView(
                            padding: EdgeInsets.zero,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(CupertinoPageRoute(
                                    builder: (BuildContext context) {
                                      return PhotoViewSimpleScreen(
                                        imageUrl: cheatersInfoUser["avatarLink"],
                                        imageProvider: NetworkImage(cheatersInfoUser["avatarLink"]),
                                        heroTag: 'simple',
                                      );
                                    },
                                  ));
                                },
                                child: Container(
                                  margin: EdgeInsets.only(top: 140, right: 10, left: 10, bottom: 50),
                                  child: Center(
                                    child: EluiImgComponent(
                                      src: cheatersInfoUser["avatarLink"],
                                      width: 150,
                                      height: 150,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                color: Colors.black12,
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        children: <Widget>[
                                          GestureDetector(
                                            child: Icon(
                                              Icons.code,
                                              color: Colors.white,
                                            ),
                                            onTap: () {
                                              Clipboard.setData(
                                                ClipboardData(
                                                  text: cheatersInfoUser["originId"],
                                                ),
                                              );
                                              EluiMessageComponent.success(context)(
                                                child: Text("复制成功"),
                                              );
                                            },
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),

                                          /// 用户名称
                                          Expanded(
                                            flex: 1,
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
                                          SizedBox(
                                            width: 5,
                                          ),

                                          /// 最终状态
                                          Container(
                                            padding: EdgeInsets.only(
                                              left: 5,
                                              right: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: startusIng[int.parse(cheatersInfo["data"]["cheater"][0]["status"])]["c"],
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(2),
                                              ),
                                            ),
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
                                  ],
                                ),
                              ),
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
                                            (cheatersInfo["data"]["reports"].length + cheatersInfo["data"]["verifies"].length).toString() +
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
                                            "PC",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            "游玩平台",
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
                                padding: EdgeInsets.only(
                                  left: 10,
                                  right: 10,
                                  top: 10,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        "如果无法更新列表或获取,仅出现该用户未游玩过该游戏以及已被封禁二种状态.",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white54,
                                        ),
                                        maxLines: 3,
                                      ),
                                    ),
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
                                        userNameList['buttonLoad'] ? "刷新中" : "刷新",
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      onPressed: () => this._seUpdateUserNameList(),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(
                                  left: 10,
                                  right: 10,
                                  bottom: 10,
                                ),
                                child: userNameList['listLoad']
                                    ? EluiVacancyComponent(
                                        title: "-",
                                      )
                                    : _getUsedname(snapshot.data),
                                margin: EdgeInsets.only(
                                  top: 10,
                                ),
                              ),
                            ],
                          ),

                          /// E 举报信息

                          /// S 审核记录
                          ListView(
                            children: <Widget>[
                              Container(
                                width: double.maxFinite,
                                height: 1,
                                child: Stack(
                                  overflow: Overflow.visible,
                                  children: [
                                    Positioned(
                                      top: -150,
                                      left: 0,
                                      right: 0,
                                      child: Text(
                                        "别看啦,真没有了 /(ㄒoㄒ)/~~",
                                        style: TextStyle(color: Colors.white38),
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  ],
                                ),
                              ),

                              /// S记录
                              cheatersRecordWidgetList,

                              /// E记录
                            ],
                          ),

                          /// E 审核记录
                        ],
                      ),
                    ),
                  ),

                  /// E 主体框架
                ],
              ),
            ),

            /// 底栏
            bottomSheet: _tabControllerIndex == 1
                ? Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    width: 1.0,
                    color: Colors.black12,
                  ),
                ),
              ),
              padding: EdgeInsets.only(
                left: 10,
                right: 10,
                top: 5,
                bottom: 5,
              ),
              height: 50,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: FlatButton(
                      color: Color(0xff111b2b),
                      textColor: Colors.white,
                      disabledColor: Colors.black12,
                      disabledTextColor: Colors.black54,
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 10,
                        children: <Widget>[
                          Icon(
                            Icons.message,
                            color: Colors.orangeAccent,
                          ),
                          Text(
                            "补充证据",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      onPressed: _setReply(0),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      left: 7,
                      right: 7,
                    ),
                    height: 20,
                    width: 1,
                    color: Colors.black12,
                  ),
                  FlatButton(
                    color: Colors.red,
                    textColor: Colors.white,
                    disabledColor: Colors.black12,
                    disabledTextColor: Colors.black54,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "判决",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "管理员选项",
                          style: TextStyle(
                            fontSize: 9,
                          ),
                        )
                      ],
                    ),
                    onPressed: onAdminSentence(),
                  ),
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
                  '$cont',
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
