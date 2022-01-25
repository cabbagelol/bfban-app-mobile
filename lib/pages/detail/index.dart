/// 举报信息详情

import 'dart:convert';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fluro/fluro.dart';
import 'package:flutter_elui_plugin/elui.dart';

import 'package:bfban/data/index.dart';
import 'package:bfban/constants/api.dart';
import 'package:bfban/router/router.dart';
import 'package:bfban/utils/index.dart';
import 'package:bfban/widgets/index.dart';
import 'package:provider/provider.dart';

import '../../provider/userinfo_provider.dart';

class PlayerDetailPage extends StatefulWidget {
  /// bfban.com 内部举报id
  final String id;

  const PlayerDetailPage({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  _PlayerDetailPageState createState() => _PlayerDetailPageState();
}

class _PlayerDetailPageState extends State<PlayerDetailPage> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  final UrlUtil _urlUtil = UrlUtil();

  /// 作弊者参数
  PlayerStatus playerStatus = PlayerStatus(
    data: {},
    load: true,
    parame: PlayerParame(
      history: true,
      personaId: "",
    ),
  );

  /// 日历
  PlayerTimelineStatus playerTimelineStatus = PlayerTimelineStatus(
    index: 0,
    list: [],
    load: false,
    parame: PlayerTimelineParame(
      skip: 0,
      limit: 10,
      personaId: "",
    ),
  );

  /// 异步
  Future? futureBuilder;

  /// TAB导航控制器
  TabController? _tabController;

  /// 导航下标
  int _tabControllerIndex = 0;

  /// 导航个体
  List<Tab> cheatersTabs = <Tab>[const Tab(text: "contnet"), const Tab(text: "list")];

  /// 进度状态
  final Map startusIng = Config.startusIng;

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

    playerStatus.parame!.personaId = widget.id;
    playerTimelineStatus.parame!.personaId = playerStatus.parame!.personaId;

    ready();
  }

  void ready() async {
    _tabController = TabController(vsync: this, length: cheatersTabs.length)
      ..addListener(() {
        setState(() {
          _tabControllerIndex = _tabController!.index;
        });
      });

    futureBuilder = _getCheatersInfo();
    _getTimeline();
  }

  /// [Response]
  /// 获取作弊玩家 日历
  Future _getTimeline() async {
    setState(() {
      playerTimelineStatus.load = true;
    });

    Response result = await Http.request(
      Config.httpHost["account_timeline"],
      parame: playerTimelineStatus.parame!.toMap,
      method: Http.GET,
    );

    if (result.data["success"] == 1) {
      final d = result.data["data"]["result"];

      setState(() {
        playerTimelineStatus.list = d;
      });
    }

    setState(() {
      playerTimelineStatus.load = false;
    });

    return playerTimelineStatus.list;
  }

  /// [Response]
  /// 获取作弊玩家 档案
  Future _getCheatersInfo() async {
    setState(() {
      playerStatus.load = true;
    });

    Response result = await Http.request(
      Config.httpHost["player"],
      parame: playerStatus.parame?.toMap,
      method: Http.GET,
    );

    if (result.data["success"] == 1) {
      final d = result.data["data"];

      setState(() {
        playerStatus.data = d;
      });
    } else {
      EluiMessageComponent.error(context)(
        child: Text(
          "获取失败, 结果: " + (result.data["error"] ?? '-1') + result.data.toString(),
        ),
      );
    }

    setState(() {
      playerStatus.load = false;
    });

    return playerStatus.data;
  }

  /// [Event]
  /// 作弊玩家信息 刷新
  Future<void> _onRefreshCheatersInfo() async {
    await _getCheatersInfo();
  }

  /// [Event]
  /// 作弊玩家日历 刷新
  Future<void> _onRefreshTimeline() async {
    await _getTimeline();
  }

  /// [Event]
  /// 获取游戏类型
  String _getGames(List games) {
    String t = "";
    for (var element in games) {
      t += "${element["game"].toString().toUpperCase()} ";
    }
    return t;
  }

  /// [Event]
  /// 评论内回复
  void _onReplySucceed(value) async {
    if (value == null) {
      return;
    }
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  /// [Response]
  /// 赞同决议
  /// data举报者信息 R单条评论
  void _setConfirm(context, data, R) async {
    Response result = await Http.request(
      'api/cheaters/confirm',
      data: Map.from({
        "userVerifyCheaterId": data["id"],
        "cheatMethods": R["cheatMethods"],
        "userId": R["userId"], //_login["userId"]
        "originUserId": data["originUserId"],
      }),
      method: Http.POST,
    );

    if (result.data["error"] == 0) {
      EluiMessageComponent.success(context)(
        child: const Text("提交成功"),
      );

      await _getCheatersInfo();
    } else {
      EluiMessageComponent.error(context)(
        child: const Text("提交失败"),
      );
    }
  }

  /// [Response]
  /// 请求更新用户名称列表
  void _seUpdateUserNameList(bool isLogin) async {
    // 检查登录状态
    if (!ProviderUtil().ofUser(context).checkLogin()) return;

    if (userNameList['buttonLoad']) {
      return;
    }

    if (playerStatus.data["originUserId"] == "" || playerStatus.data["originUserId"] == null) {
      EluiMessageComponent.error(context)(
        child: const Text("无法识别ID"),
      );
      return;
    }

    if (isLogin == null) {
      EluiMessageComponent.error(context)(
        child: const Text("请先登录BFBAN"),
      );
      return;
    }

    setState(() {
      userNameList["buttonLoad"] = true;
    });

    Response result = await Http.request(
      Config.httpHost["player_update"],
      data: {
        "originUserId": playerStatus.data["originUserId"],
      },
      method: Http.POST,
    );

    if (result.data["success"] == 1) {
      _getCheatersInfo();
    } else {
      EluiMessageComponent.error(context)(
        child: const Text("请求异常请联系开发者"),
      );
    }

    setState(() {
      userNameList["buttonLoad"] = false;
    });
  }

  /// [Event]
  /// 用户回复
  dynamic _setReply(num type, {num floor = 0}) {
    return () {
      // 检查登录状态
      if (!ProviderUtil().ofUser(context).checkLogin()) return;

      String content = "";

      switch (type) {
        case 0:
          // 回复
          content = jsonEncode({
            "type": type,
            "toCommentId": playerStatus.data["id"],
            "toPlayerId": playerStatus.data["toPlayerId"],
          });
          break;
        case 1:
          // 楼层回复
          content = jsonEncode({
            "type": type,
            "toFloor": floor,
            "toCommentId": playerStatus.data["id"],
            "toPlayerId": playerStatus.data["toPlayerId"],
          });
          break;
      }

      _urlUtil.opEnPage(context, "/reply/$content", transition: TransitionType.cupertino).then((value) {
        if (value != null) {
          _getCheatersInfo();
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    };
  }

  /// [Event]
  /// 补充举报用户信息
  dynamic _onReport() {
    return () {
      // 检查登录状态
      if (!ProviderUtil().ofUser(context).checkLogin()) return null;

      _urlUtil.opEnPage(context, '/report/${jsonEncode({"originName": playerStatus.data["originName"]})}', transition: TransitionType.cupertinoFullScreenDialog).then((value) {
        if (value != null) {
          _getCheatersInfo();
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    };
  }

  /// [Event]
  /// 审核人员判决
  dynamic onAdminSentence() {
    return () {
      // 检查登录状态
      // if (!ProviderUtil().ofUser(context).checkLogin()) return;

      _urlUtil.opEnPage(context, "/report/manage/${playerStatus.data["originPersonaId"]}").then((value) {
        if (value != null) {
          _getCheatersInfo();
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    };
  }

  /// [Event]
  /// 查看图片
  void _onEnImgInfo(context) {
    Navigator.of(context).push(CupertinoPageRoute(
      builder: (BuildContext context) {
        return PhotoViewSimpleScreen(
          imageUrl: playerStatus.data["avatarLink"],
          imageProvider: NetworkImage(playerStatus.data["avatarLink"]),
          heroTag: 'simple',
        );
      },
    ));
  }

  /// [Event]
  /// 曾经使用过的名称
  static Widget _getUsedname(playerInfo) {
    List<DataRow> list = [];

    playerInfo["history"].asMap().keys.forEach((index) {
      var i = playerInfo["history"][index];

      list.add(
        DataRow(
          cells: [
            DataCell(
              Wrap(
                spacing: 5,
                children: [
                  Visibility(
                    visible: index >= playerInfo["history"].length - 1,
                    child: EluiTagComponent(
                      size: EluiTagSize.no2,
                      theme: EluiTagTheme(
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                      ),
                      value: "最新",
                    ),
                  ),
                  SelectableText(i["originName"]),
                ],
              ),
            ),
            DataCell(
              Text(
                Date().getFriendlyDescriptionTime(i["fromTime"]),
              ),
            ),
          ],
        ),
      );
    });

    return DataTable(
      sortAscending: true,
      sortColumnIndex: 0,
      columns: const [
        DataColumn(
          label: Text(
            "游戏id",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        DataColumn(
          label: Text(
            "获取时间",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
      rows: list,
    );
  }

  @override
  Widget build(BuildContext context) {
    cheatersTabs = <Tab>[
      const Tab(text: '举报信息'),
      Tab(
        child: Wrap(
          spacing: 5,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text("审核记录"),
            playerTimelineStatus.load!
                ? const SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(strokeWidth: 1),
                  )
                : EluiTagComponent(
                    value: playerTimelineStatus.list!.length.toString(),
                    size: EluiTagSize.no2,
                    theme: EluiTagTheme(
                      textColor: _tabControllerIndex == 1 ? Colors.black : Colors.red,
                      backgroundColor: _tabControllerIndex == 1 ? Colors.red : Colors.transparent,
                    ),
                  ),
          ],
        ),
      ),
    ];

    return FutureBuilder(
      future: futureBuilder,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        /// 数据未加载完成时
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            return Scaffold(
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                flexibleSpace: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomRight,
                      colors: [Colors.transparent, Colors.black54],
                    ),
                  ),
                ),
                title: TabBar(
                  labelStyle: const TextStyle(fontSize: 15),
                  controller: _tabController,
                  labelPadding: const EdgeInsets.only(left: 0, right: 0),
                  tabs: cheatersTabs,
                ),
                elevation: 0,
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(
                      Icons.open_in_new,
                    ),
                    onPressed: () {
                      Share().text(
                        title: '联BFBAN分享',
                        text: '走过路过，不要错过咯~ 快乐围观 ${snapshot.data!["originId"]} 在联BAN举报信息',
                        linkUrl: 'https://bfban.com/#/cheaters/${snapshot.data!["originUserId"]}',
                        chooserTitle: '联BFBAN分享',
                      );
                      Clipboard.setData(
                        ClipboardData(
                          text: 'https://bfban.com/#/cheaters/${snapshot.data!["originUserId"]}',
                        ),
                      );
                    },
                  ),
                ],
                centerTitle: true,
              ),

              /// 内容
              body: DefaultTabController(
                length: cheatersTabs.length,
                child: Column(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: TabBarView(
                        controller: _tabController,
                        children: <Widget>[
                          /// S 举报信息
                          RefreshIndicator(
                            onRefresh: _onRefreshCheatersInfo,
                            color: Theme.of(context).floatingActionButtonTheme.focusColor,
                            backgroundColor: Theme.of(context).floatingActionButtonTheme.backgroundColor,
                            child: ListView(
                              padding: EdgeInsets.zero,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () => _onEnImgInfo(context),
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 140, right: 10, left: 10, bottom: 20),
                                    child: Center(
                                      child: Card(
                                        elevation: 20,
                                        clipBehavior: Clip.antiAlias,
                                        child: Stack(
                                          children: [
                                            EluiImgComponent(
                                              src: snapshot.data["avatarLink"],
                                              width: 150,
                                              height: 150,
                                            ),
                                            Positioned(
                                              right: 0,
                                              bottom: 0,
                                              child: Container(
                                                padding: const EdgeInsets.only(top: 40, left: 40, right: 5, bottom: 5),
                                                decoration: const BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [
                                                      Colors.transparent,
                                                      Colors.transparent,
                                                      Colors.black87,
                                                    ],
                                                  ),
                                                ),
                                                child: const Icon(
                                                  Icons.search,
                                                  color: Colors.white70,
                                                  size: 30,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 1,
                                        child: Row(
                                          children: <Widget>[
                                            GestureDetector(
                                              child: const Icon(
                                                Icons.code,
                                              ),
                                              onTap: () {
                                                Clipboard.setData(
                                                  ClipboardData(
                                                    text: snapshot.data!["originId"],
                                                  ),
                                                );
                                                EluiMessageComponent.success(context)(
                                                  child: const Text("复制成功"),
                                                );
                                              },
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),

                                            /// 用户名称
                                            Expanded(
                                              flex: 1,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SelectableText(
                                                    snapshot.data!["originName"].toString(),
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      shadows: <Shadow>[
                                                        Shadow(
                                                          color: Colors.black12,
                                                          offset: Offset(1, 2),
                                                        )
                                                      ],
                                                    ),
                                                    showCursor: true,
                                                  ),
                                                  Text(
                                                    "${snapshot.data["id"]} / ${snapshot.data["originPersonaId"]}",
                                                    style: TextStyle(
                                                      color: Theme.of(context).textTheme.subtitle2!.color,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),

                                            /// 最终状态
                                            Container(
                                              padding: const EdgeInsets.only(
                                                left: 5,
                                                right: 5,
                                              ),
                                              decoration: BoxDecoration(
                                                color: startusIng[snapshot.data!["status"]]["c"],
                                                borderRadius: const BorderRadius.all(
                                                  Radius.circular(2),
                                                ),
                                              ),
                                              child: Text(
                                                startusIng[snapshot.data!["status"]]["s"].toString(),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: startusIng[snapshot.data!["status"]]["tc"],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // 属性
                                Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 10),
                                  child: SizedBox(
                                    width: double.maxFinite,
                                    height: 100,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: 10,
                                      itemBuilder: (BuildContext context, int index) {
                                        if (index % 2 == 0 && index > 0) {
                                          // 分割线
                                          return Container(
                                            margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                                            height: 30,
                                            width: 1,
                                            color: Theme.of(context).dividerColor,
                                          );
                                        }

                                        if (index == 0 || index == 10) {
                                          return const SizedBox(width: 30);
                                        }

                                        switch (index) {
                                          case 1:
                                            // 举报时间
                                            return Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                  snapshot.data!.isNotEmpty ? Date().getFriendlyDescriptionTime(snapshot.data!["createTime"]) : "",
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                                const Text(
                                                  "第一次举报时间",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                )
                                              ],
                                            );
                                          case 3:
                                            // 最后更新时间
                                            return Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                  snapshot.data != null ? Date().getFriendlyDescriptionTime(snapshot.data!["updateTime"]) : "",
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                                const Text(
                                                  "最后更新",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                )
                                              ],
                                            );
                                          case 5:
                                            return Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                  "${snapshot.data!["viewNum"]}/次",
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const Text(
                                                  "围观",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                )
                                              ],
                                            );
                                          case 7:
                                            return Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                  "${snapshot.data["commentsNum"]}/条",
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const Text(
                                                  "回复",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                )
                                              ],
                                            );
                                          case 9:
                                            return Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                  snapshot.data["games"].toString(),
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const Text(
                                                  "被举报游戏",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                )
                                              ],
                                            );
                                        }

                                        return Container();
                                      },
                                    ),
                                  ),
                                ),

                                // 战绩链接
                                Container(
                                  padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: snapshot.data["games"].map<Widget>((i) {
                                      var bf = [
                                        {"f": "bf1,bfv", "n": "battlefieldtracker", "url": "https://battlefieldtracker.com/bf1/profile/pc/${snapshot.data!["originId"]}"},
                                        {
                                          "f": "bf1",
                                          "n": "bf1stats",
                                          "url": "http://bf1stats.com/pc/${snapshot.data!["originId"]}",
                                        },
                                        {
                                          "f": "bf1,bfv",
                                          "n": "247fairplay",
                                          "url": "https://www.247fairplay.com/CheatDetector/${snapshot.data!["originId"]}",
                                        },
                                      ];

                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: bf.map<Widget>((Map? e) {
                                          return Visibility(
                                            visible: e!["f"]!.indexOf(i) >= 0,
                                            child: GestureDetector(
                                              onTap: () => UrlUtil().onPeUrl(e["url"]),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 10,
                                                ),
                                                child: Wrap(
                                                  spacing: 5,
                                                  children: [
                                                    const Icon(
                                                      Icons.insert_link,
                                                      size: 16,
                                                    ),
                                                    Text(
                                                      e["n"],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      );
                                    }).toList(),
                                  ),
                                ),

                                Consumer<UserInfoProvider>(
                                  builder: (context, data, child) {
                                    return Container(
                                      padding: const EdgeInsets.only(
                                        left: 10,
                                        right: 10,
                                        top: 20,
                                      ),
                                      child: Align(
                                        child: TextButton.icon(
                                          icon: const Icon(
                                            Icons.refresh,
                                            size: 25,
                                          ),
                                          label: Text(
                                            userNameList['buttonLoad'] ? "刷新中" : "刷新",
                                          ),
                                          onPressed: () => _seUpdateUserNameList(data.isLogin),
                                        ),
                                        alignment: Alignment.centerRight,
                                      ),
                                    );
                                  },
                                ),

                                Container(
                                  padding: const EdgeInsets.only(
                                    left: 10,
                                    right: 10,
                                    bottom: 10,
                                  ),
                                  child: userNameList['listLoad']
                                      ? EluiVacancyComponent(
                                          title: "-",
                                        )
                                      : _getUsedname(snapshot.data),
                                  margin: const EdgeInsets.only(
                                    top: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// E 举报信息

                          /// S 审核记录
                          RefreshIndicator(
                            onRefresh: _onRefreshTimeline,
                            color: Theme.of(context).floatingActionButtonTheme.focusColor,
                            backgroundColor: Theme.of(context).floatingActionButtonTheme.backgroundColor,
                            child: ListView.builder(
                              controller: _scrollController,
                              itemCount: playerTimelineStatus.list!.length,
                              itemBuilder: (BuildContext context, int index) {
                                var timeLineItem = playerTimelineStatus.list![index];
                                List<Widget> _cheatMethods = <Widget>[];

                                switch (timeLineItem["type"]) {
                                  // 评论
                                  case "reply":
                                    return CheatUserCheatersCard(
                                      onReplySucceed: _onReplySucceed,
                                    )
                                      ..data = timeLineItem
                                      ..index = index;
                                  case "report":
                                    // 举报卡片
                                    return CheatReportsCard(
                                      onReplySucceed: _onReplySucceed,
                                    )
                                      ..data = timeLineItem
                                      ..index = index;
                                  case "judgement":
                                    return JudgementCard()
                                      ..data = timeLineItem
                                      ..index = index;
                                  // case "3":
                                  //   return CheatConfirms(
                                  //     i: timeLineItem,
                                  //     index: i += 1,
                                  //     cheatMethods: _cheatMethods,
                                  //     cheatersInfo: cheatersInfo,
                                  //     cheatersInfoUser: playerStatus.data,
                                  //     onReplySucceed: _onReplySucceed,
                                  //   );
                                }

                                return Container();
                              },
                            ),
                          ),

                          /// E 审核记录
                        ],
                      ),
                    ),

                    /// E 主体框架
                  ],
                ),
              ),

              /// 底栏
              bottomNavigationBar: Consumer<UserInfoProvider>(
                builder: (context, data, child) {
                  return Container(
                    height: 70,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      border: Border(
                        top: BorderSide(
                          width: 1.0,
                          color: Colors.black12,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: IndexedStack(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: TextButton(
                                child: const Text(
                                  "补充证据",
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                onPressed: _onReport(),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: TextButton(
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 10,
                                  children: const <Widget>[
                                    Icon(
                                      Icons.message,
                                      color: Colors.orangeAccent,
                                    ),
                                    Text(
                                      "回复",
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                                onPressed: _setReply(0),
                              ),
                            ),

                            // 管理员 判决
                            data.isAdmin ? const SizedBox(
                              width: 10,
                            ) : SizedBox(),
                            data.isAdmin ? Expanded(
                              child: TextButton(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const <Widget>[
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
                              flex: 1,
                            ) : SizedBox(),
                          ],
                        ),
                      ],
                      index: _tabControllerIndex,
                    ),
                  );
                },
              ),
            );
          default:
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
              ),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
        }
      },
    );
  }
}

/// WG九宫格
class detailCellCard extends StatelessWidget {
  final text;
  final value;

  const detailCellCard({
    Key? key,
    this.text = "",
    this.value = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    throw Column(
      children: <Widget>[
        Text(
          text ?? "",
          style: const TextStyle(
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

  const detailCheatersCard({
    Key? key,
    this.value,
    this.cont,
    this.type = '0',
    this.fontSize,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        color: type == '0' ? const Color.fromRGBO(0, 0, 0, .3) : const Color.fromRGBO(255, 255, 255, .07),
        padding: const EdgeInsets.all(20),
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
                  style: const TextStyle(
                    color: Color.fromRGBO(255, 255, 255, .6),
                    fontSize: 13,
                  ),
                )
              ],
            )
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}