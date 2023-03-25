/// 举报信息详情

import 'dart:convert';
import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fluro/fluro.dart';
import 'package:flutter_elui_plugin/elui.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import 'package:bfban/data/index.dart';
import 'package:bfban/constants/api.dart';
import 'package:bfban/utils/index.dart';
import 'package:bfban/widgets/index.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../provider/userinfo_provider.dart';
import '../../widgets/detail/appeal_card.dart';
import '../../widgets/detail/cheat_reports_card.dart';
import '../../widgets/detail/judgement_card.dart';

class PlayerDetailPage extends StatefulWidget {
  /// User Db id
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

  final Storage storage = Storage();

  /// 作弊者参数
  PlayerStatus playerStatus = PlayerStatus(
    data: {},
    load: true,
    parame: PlayerParame(
      history: true,
      personaId: "",
    ),
  );

  /// 时间轴
  PlayerTimelineStatus playerTimelineStatus = PlayerTimelineStatus(
    index: 0,
    list: [],
    total: 0,
    load: false,
    parame: PlayerTimelineParame(
      skip: 0,
      limit: 100,
      personaId: "",
    ),
  );

  ViewedStatus viewedStatus = ViewedStatus(
    load: false,
    parame: ViewedStatusParame(),
  );

  /// 异步
  Future? futureBuilder;

  /// TAB导航控制器
  TabController? _tabController;

  /// 导航下标
  int _tabControllerIndex = 0;

  /// 导航个体
  List<Tab> cheatersTabs = <Tab>[const Tab(text: "content"), const Tab(text: "list")];

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
  /// 获取时间轴
  Future _getTimeline() async {
    setState(() {
      playerTimelineStatus.load = true;
    });

    Response result = await Http.request(
      Config.httpHost["player_timeline"],
      parame: playerTimelineStatus.parame!.toMap,
      method: Http.GET,
    );

    if (result.data["success"] == 1) {
      final d = result.data["data"];

      setState(() {
        playerTimelineStatus.list = d["result"];
        playerTimelineStatus.total = d["total"];
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
      Config.httpHost["cheaters"],
      parame: playerStatus.parame?.toMap,
      method: Http.GET,
    );

    if (result.data["success"] == 1) {
      final d = result.data["data"];

      setState(() {
        playerStatus.data = d;
        viewedStatus.parame!.id = d["id"];
      });

      _onViewd();
    } else {
      EluiMessageComponent.error(context)(
        child: Text(result.data.code),
      );
    }

    setState(() {
      playerStatus.load = false;
    });

    return playerStatus.data;
  }

  /// [Event]
  /// 更新游览值
  Future _onViewd() async {
    Map? viewed = jsonDecode(await storage.get("viewed")) ?? {};
    String? id = viewedStatus.parame!.id.toString();

    if (id.isEmpty) return;

    // TODO 校验，包含ID且1天累，则不更新游览值
    // if (viewed != null) {
    //   return;
    // }

    Response result = await Http.request(
      Config.httpHost["player_viewed"],
      parame: viewedStatus.parame?.toMap,
      method: Http.POST,
    );

    setState(() {
      viewed![id] = DateTime.now().millisecondsSinceEpoch.toString();
      storage.set("viewed", value: jsonEncode(viewed));
      playerStatus.data["viewNum"] += 1;
    });
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
  dynamic _setReply(num type) {
    return () {
      // 检查登录状态
      if (!ProviderUtil().ofUser(context).checkLogin()) return;

      String parameter = "";

      switch (type) {
        case 0:
          // 回复
          parameter = jsonEncode({
            "type": type,
            "toCommentId": null,
            "toPlayerId": playerStatus.data["id"],
          });
          break;
        case 1:
          // 回复楼层
          parameter = jsonEncode({
            "type": type,
            "toCommentId": playerStatus.data["id"],
            "toPlayerId": playerStatus.data["toPlayerId"],
          });
          break;
      }

      _urlUtil.opEnPage(context, "/reply/$parameter", transition: TransitionType.cupertinoFullScreenDialog).then((value) {
        if (value != null) {
          _getCheatersInfo();
          _getTimeline();
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
          _getTimeline();
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    };
  }

  /// [Event]
  /// 审核人员判决
  dynamic onJudgement() {
    return () {
      // 检查登录状态
      if (!ProviderUtil().ofUser(context).checkLogin()) return;

      _urlUtil.opEnPage(context, "/report/manage/${playerStatus.data["id"]}").then((value) {
        if (value != null) {
          _getCheatersInfo();
          _getTimeline();
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
  static Widget _updateUserName(BuildContext context, playerInfo) {
    List<DataRow> list = [];

    playerInfo["history"].asMap().keys.forEach((index) {
      var i = playerInfo["history"][index];

      list.add(
        DataRow(
          cells: [
            DataCell(
              SelectableText(i["originName"]),
            ),
            DataCell(
              SelectableText(
                Date().getFriendlyDescriptionTime(i["fromTime"]),
              ),
            ),
          ],
        ),
      );
    });

    return Card(
      margin: EdgeInsets.zero,
      child: DataTable(
        sortAscending: true,
        sortColumnIndex: 0,
        columns: [
          DataColumn(
            label: Text(
              FlutterI18n.translate(context, "list.colums.playerId"),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              FlutterI18n.translate(context, "list.colums.updateTime"),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        rows: list,
      ),
    );
  }

  void _onShare(Map i) {
    _urlUtil.onPeUrl(
      "${Config.apiHost["web_site"]}/player/${i["originUserId"]}/share",
      mode: LaunchMode.externalNonBrowserApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    cheatersTabs = <Tab>[
      Tab(text: FlutterI18n.translate(context, "detail.info.cheatersInfo")),
      Tab(
        child: Wrap(
          spacing: 5,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(FlutterI18n.translate(context, "detail.info.timeLine")),
            playerTimelineStatus.load!
                ? const SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(strokeWidth: 1),
                  )
                : EluiTagComponent(
                    value: "${playerTimelineStatus.total ?? 0}",
                    size: EluiTagSize.no2,
                    theme: EluiTagTheme(
                      textColor: _tabControllerIndex == 1 ? Colors.black : Theme.of(context).primaryColor,
                      backgroundColor: _tabControllerIndex == 1 ? Theme.of(context).primaryColor : Colors.transparent,
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
                    icon: const Icon(Icons.open_in_new),
                    onPressed: () {
                      _onShare(snapshot.data);
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
                          /// S 玩家详情
                          RefreshIndicator(
                            onRefresh: _onRefreshCheatersInfo,
                            child: ListView(
                              padding: EdgeInsets.zero,
                              children: <Widget>[
                                Stack(
                                  alignment: AlignmentDirectional.topCenter,
                                  children: [
                                    Positioned(
                                      child: Opacity(
                                        opacity: .2,
                                        child: SizedBox(
                                          width: 800,
                                          height: 350,
                                          child: EluiImgComponent(
                                            src: snapshot.data.toString(),
                                            width: 800,
                                            height: 350,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: BackdropFilter(
                                        filter: ui.ImageFilter.blur(
                                          sigmaX: 0,
                                          sigmaY: 0,
                                        ),
                                        child: GestureDetector(
                                          onTap: () => _onEnImgInfo(context),
                                          child: Container(
                                            margin: const EdgeInsets.only(top: 100, right: 10, left: 10),
                                            child: Center(
                                              child: Card(
                                                elevation: 0,
                                                clipBehavior: Clip.antiAlias,
                                                child: Stack(
                                                  children: [
                                                    Positioned(
                                                      top: 0,
                                                      child: Image.network(snapshot.data!["avatarLink"].toString()),
                                                    ),
                                                    EluiImgComponent(
                                                      src: snapshot.data!["avatarLink"],
                                                      fit: BoxFit.contain,
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
                                      ),
                                    ),
                                  ],
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
                                            /// 用户名称
                                            Expanded(
                                              flex: 1,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  SelectableText(
                                                    snapshot.data?["originName"] ?? "User Name",
                                                    onTap: () {
                                                      Clipboard.setData(
                                                        ClipboardData(
                                                          text: snapshot.data!["originName"],
                                                        ),
                                                      );
                                                    },
                                                    style: const TextStyle(fontSize: 33),
                                                    showCursor: true,
                                                  ),
                                                  const SizedBox(height: 2),
                                                  EluiTagComponent(
                                                    size: EluiTagSize.no2,
                                                    color: EluiTagType.primary,
                                                    value: FlutterI18n.translate(context, "basic.status.${snapshot.data?["status"]}"),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Player Attr
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                  child: Wrap(
                                    spacing: 40,
                                    runSpacing: 25,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Opacity(
                                            opacity: .5,
                                            child: Text(
                                              FlutterI18n.translate(context, "detail.info.firstReportTime"),
                                              style: const TextStyle(fontSize: 20),
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            Date().getFriendlyDescriptionTime(snapshot.data!["createTime"]),
                                            style: const TextStyle(fontSize: 18),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Opacity(
                                            opacity: .5,
                                            child: Text(
                                              FlutterI18n.translate(context, "detail.info.recentUpdateTime"),
                                              style: const TextStyle(fontSize: 20),
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            snapshot.data != null ? Date().getFriendlyDescriptionTime(snapshot.data!["updateTime"]) : "",
                                            style: const TextStyle(fontSize: 18),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Opacity(
                                            opacity: .5,
                                            child: Text(
                                              FlutterI18n.translate(context, "detail.info.viewTimes"),
                                              style: const TextStyle(fontSize: 20),
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            "${snapshot.data!["viewNum"]}",
                                            style: const TextStyle(fontSize: 18),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Opacity(
                                            opacity: .5,
                                            child: Text(
                                              FlutterI18n.translate(context, "basic.button.reply"),
                                              style: const TextStyle(fontSize: 20),
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            "${snapshot.data["commentsNum"]}",
                                            style: const TextStyle(fontSize: 18),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Opacity(
                                            opacity: .5,
                                            child: Text(
                                              FlutterI18n.translate(context, "report.labels.game"),
                                              style: const TextStyle(fontSize: 20),
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Wrap(
                                            children: snapshot.data["games"].map<Widget>((i) {
                                              return I18nText("basic.games.$i", child: const Text("", style: TextStyle(fontSize: 16)));
                                            }).toList(),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Opacity(
                                            opacity: .5,
                                            child: Text(
                                              FlutterI18n.translate(context, "signup.form.originId"),
                                              style: const TextStyle(fontSize: 20),
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text("${snapshot.data?["originPersonaId"]}", style: const TextStyle(fontSize: 18))
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          const Opacity(
                                            opacity: .5,
                                            child: Text(
                                              "ID",
                                              style: TextStyle(fontSize: 20),
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text("${snapshot.data?["id"]}", style: const TextStyle(fontSize: 18))
                                        ],
                                      ),
                                    ],
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
                                        alignment: Alignment.centerRight,
                                        child: TextButton.icon(
                                          icon: const Icon(
                                            Icons.refresh,
                                            size: 25,
                                          ),
                                          label: const Text(""),
                                          onPressed: () => _seUpdateUserNameList(data.isLogin),
                                        ),
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
                                  margin: const EdgeInsets.only(
                                    top: 10,
                                  ),
                                  child: userNameList['listLoad']
                                      ? EluiVacancyComponent(
                                          title: "-",
                                        )
                                      : _updateUserName(context, snapshot.data),
                                ),
                              ],
                            ),
                          ),

                          /// E 玩家详情

                          /// S 审核记录
                          RefreshIndicator(
                            onRefresh: _onRefreshTimeline,
                            child: ListView.builder(
                              controller: _scrollController,
                              itemCount: playerTimelineStatus.list!.length,
                              itemBuilder: (BuildContext context, int index) {
                                var timeLineItem = playerTimelineStatus.list![index];

                                switch (timeLineItem["type"]) {
                                  case "reply":
                                    // 评论
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
                                    // 举报
                                    return JudgementCard()
                                      ..data = timeLineItem
                                      ..index = index;
                                  case "banAppeal":
                                    // 申诉
                                    return AppealCard(
                                      onReplySucceed: _onReplySucceed,
                                    )
                                      ..data = timeLineItem
                                      ..index = index;
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
                    decoration: BoxDecoration(
                      color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
                      border: const Border(
                        top: BorderSide(
                          width: 1.0,
                          color: Colors.black12,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: IndexedStack(
                      index: _tabControllerIndex,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: TextButton(
                                onPressed: _onReport(),
                                child: Text(
                                  FlutterI18n.translate(context, "report.title"),
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
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
                                onPressed: _setReply(0),
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 10,
                                  children: <Widget>[
                                    const Icon(
                                      Icons.message,
                                      color: Colors.orangeAccent,
                                    ),
                                    I18nText(
                                      "basic.button.reply",
                                      child: const Text(
                                        "",
                                        style: TextStyle(fontSize: 14),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // 管理员 判决
                            data.isAdmin
                                ? const SizedBox(
                                    width: 10,
                                  )
                                : const SizedBox(),
                            data.isAdmin
                                ? Expanded(
                                    flex: 1,
                                    child: TextButton(
                                      onPressed: onJudgement(),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(FlutterI18n.translate(context, "detail.info.judgement")),
                                        ],
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      ],
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
