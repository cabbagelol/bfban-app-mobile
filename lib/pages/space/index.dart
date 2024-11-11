import 'package:bfban/component/_Time/index.dart';
import 'package:bfban/component/_achievement/index.dart';
import 'package:bfban/component/_empty/index.dart';
import 'package:bfban/component/_html/html.dart';
import 'package:bfban/component/_html/htmlWidget.dart';
import 'package:bfban/component/_loading/index.dart';
import 'package:bfban/provider/userinfo_provider.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';

import 'package:bfban/constants/api.dart';
import 'package:flutter_elui_plugin/elui.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

import '../../component/_privilegesTag/index.dart';
import '../../component/_refresh/index.dart';
import '../../component/_userAvatar/index.dart';
import '../../data/index.dart';
import '../../utils/index.dart';
import '../../widgets/index.dart';
import '../not_found/index.dart';

class UserSpacePage extends StatefulWidget {
  // users Db id
  late String? id;

  UserSpacePage({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  UserSpacePageState createState() => UserSpacePageState();
}

class UserSpacePageState extends State<UserSpacePage> with TickerProviderStateMixin {
  final UrlUtil _urlUtil = UrlUtil();

  /// 列表
  final GlobalKey<RefreshState> _refreshKey = GlobalKey<RefreshState>();

  late TabController tabController;

  ScrollController scrollController = ScrollController();

  /// 异步
  Future? futureBuilder;

  /// 用户信息
  StationUserSpaceStatus userSpaceInfo = StationUserSpaceStatus(
    data: StationUserSpaceData(),
    parame: StationUserSpaceParame(
      id: null,
      limit: 20,
      skip: 0,
    ),
    load: false,
  );

  /// 用户举报列表
  ReportListStatus reportListStatus = ReportListStatus(
    load: false,
    list: [],
    parame: ReportListStatusParame(
      id: null,
      limit: 20,
      skip: 0,
    ),
  );

  GlobalKey appBarKey = GlobalKey();

  late ScrollController _scrollController;

  bool get _isSliverAppBarExpanded {
    return _scrollController.hasClients && _scrollController.offset > (220 - kToolbarHeight);
  }

  @override
  void initState() {
    tabController = TabController(
      vsync: this,
      length: 2,
      initialIndex: 0,
    );

    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          // print(_isSliverAppBarExpanded);
          // _isShowUserInfo = _isSliverAppBarExpanded;
        });
      });

    ready();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant UserSpacePage oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    userSpaceInfo.data = StationUserSpaceData();
    super.dispose();
  }

  void ready() async {
    // Update query id
    userSpaceInfo.parame.id = widget.id!;
    reportListStatus.parame.id = int.parse(widget.id!);

    futureBuilder = _getUserSpaceInfo();
  }

  /// [Response]
  /// 获取站内用户数据
  Future _getUserSpaceInfo() async {
    setState(() {
      userSpaceInfo.load = true;
    });

    Response result = await Http.request(
      Config.httpHost["user_info"],
      parame: userSpaceInfo.parame.toMap,
      method: Http.GET,
    );

    if (result.data["success"] == 1) {
      final d = result.data["data"];
      _getSiteUserReports();

      setState(() {
        userSpaceInfo.data.setData(d);
      });
    }

    setState(() {
      userSpaceInfo.load = false;
    });

    return userSpaceInfo.data.toMap;
  }

  /// [Response]
  /// 获取用户举报列表
  Future _getSiteUserReports() async {
    setState(() {
      reportListStatus.load = true;
    });

    Response result = await Http.request(
      Config.httpHost["user_reports"],
      parame: reportListStatus.parame.toMap,
      method: Http.GET,
    );

    if (result.data["success"] == 1) {
      dynamic d = result.data;

      if (!mounted) return;
      setState(() {
        // 追加数据预期状态
        if (d["data"].isEmpty || d["data"].length < reportListStatus.parame.limit) {
          _refreshKey.currentState?.controller.finishLoad(IndicatorResult.noMore);
        }

        // 首页数据
        if (reportListStatus.parame.skip! <= 0) {
          reportListStatus.list.clear();
          reportListStatus.list = d["data"];
          return;
        }

        // 追加数据
        if (d["data"].isNotEmpty) {
          reportListStatus.list = d["data"];
          _refreshKey.currentState!.controller.finishLoad(IndicatorResult.success);
        }
      });
    }

    setState(() {
      reportListStatus.load = false;
    });
  }

  /// [Event]
  /// 作弊玩家信息 刷新
  Future<void> _onRefresh() async {
    setState(() {
      reportListStatus.list.clear();
      reportListStatus.parame.resetPage();
    });

    await _getSiteUserReports();

    _refreshKey.currentState!.controller.finishRefresh();
    _refreshKey.currentState!.controller.resetFooter();
  }

  /// [Event]
  /// 下拉 追加数据
  Future _getMore() async {
    reportListStatus.parame.nextPage();

    await _getSiteUserReports();
  }

  /// [Event]
  /// 聊天
  _openMessage(String id) async {
    Map localLoginUserInfo = ProviderUtil().ofUser(context).userinfo;
    if (localLoginUserInfo["userId"].toString() == id) {
      EluiMessageComponent.warning(context)(child: Text(FlutterI18n.translate(context, "account.message.hint.selfTalk")));
      return;
    }

    if (userSpaceInfo.data.attr!.allowDM! == false) {
      EluiMessageComponent.warning(context)(child: Text(FlutterI18n.translate(context, "account.message.hint.taOffChat")));
      return;
    }

    return () {
      _urlUtil.opEnPage(context, "/chat/$id");
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureBuilder,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        /// 数据未加载完成时
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            if (snapshot.data == null) {
              return const NotFoundPage();
            }

            return Consumer<UserInfoProvider>(builder: (BuildContext context, userData, child) {
              return Scaffold(
                extendBodyBehindAppBar: true,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  title: _isSliverAppBarExpanded
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: CircleAvatar(
                                radius: 15,
                                child: (snapshot.data["userAvatar"] != null && snapshot.data["userAvatar"].isNotEmpty)
                                    ? UserAvatar(src: snapshot.data["userAvatar"])
                                    : Text(
                                        snapshot.data["username"][0].toString().toUpperCase(),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(snapshot.data["username"]),
                          ],
                        )
                      : SizedBox(),
                  actions: [
                    PopupMenuButton(
                      onSelected: (value) {
                        switch (value) {
                          case 1:
                            _openMessage(userSpaceInfo.data.id.toString());
                            break;
                          case 2:
                            break;
                        }
                      },
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(
                            value: 1,
                            child: Wrap(
                              children: [
                                const Icon(Icons.message),
                                const SizedBox(width: 10),
                                Text(FlutterI18n.translate(context, "account.message.chat")),
                              ],
                            ),
                          ),
                        ];
                      },
                    ),
                  ],
                ),
                body: DefaultTabController(
                  length: 2,
                  child: Scrollbar(
                    controller: _scrollController,
                    child: NestedScrollView(
                      controller: _scrollController,
                      headerSliverBuilder: (context, innerBoxIsScrolled) {
                        return <Widget>[
                          SliverAppBar(
                            pinned: true,
                            primary: true,
                            automaticallyImplyLeading: false,
                            backgroundColor: _isSliverAppBarExpanded ? Theme.of(context).appBarTheme.backgroundColor : Theme.of(context).colorScheme.surface,
                            toolbarHeight: 0,
                            expandedHeight: 220,
                            flexibleSpace: FlexibleSpaceBar(
                              key: appBarKey,
                              expandedTitleScale: 1,
                              centerTitle: true,
                              background: snapshot.data["userAvatar"] != null ? Background(src: snapshot.data["userAvatar"].toString()) : null,
                              stretchModes: const [StretchMode.blurBackground, StretchMode.zoomBackground],
                              titlePadding: EdgeInsets.only(top: _isSliverAppBarExpanded ? 0 : 40),
                              title: AnimatedOpacity(
                                duration: Duration(milliseconds: 150),
                                opacity: _isSliverAppBarExpanded ? 0 : 1,
                                child: OverflowBox(
                                  maxHeight: 220,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: CircleAvatar(
                                          radius: 35,
                                          child: (snapshot.data["userAvatar"] != null && snapshot.data["userAvatar"].isNotEmpty)
                                              ? UserAvatar(src: snapshot.data["userAvatar"])
                                              : Text(
                                                  snapshot.data["username"][0].toString().toUpperCase(),
                                                  style: const TextStyle(fontSize: 25),
                                                ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      snapshot.data["username"] != null
                                          ? Column(
                                              children: [
                                                Text(snapshot.data["username"]),
                                                Text(
                                                  snapshot.data["id"],
                                                  style: TextStyle(fontSize: FontSize.medium.value, color: Theme.of(context).textTheme.displayMedium!.color),
                                                ),
                                              ],
                                            )
                                          : I18nText("account.title", child: const Text("")),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            bottom: TabBar(
                              controller: tabController,
                              indicatorWeight: 6,
                              labelColor: _isSliverAppBarExpanded ? Color.lerp(Theme.of(context).colorScheme.primaryContainer, Theme.of(context).colorScheme.primary, .5) : Color.lerp(Theme.of(context).tabBarTheme.labelColor, Theme.of(context).colorScheme.primary, .9),
                              indicator: UnderlineTabIndicator(
                                borderSide: BorderSide(
                                  color: _isSliverAppBarExpanded ? Color.lerp(Theme.of(context).colorScheme.primaryContainer, Theme.of(context).colorScheme.primary, .5)! : Color.lerp(Theme.of(context).tabBarTheme.labelColor, Theme.of(context).colorScheme.primary, .9)!,
                                  width: 3,
                                ),
                              ),
                              tabs: [
                                Tab(
                                  child: Wrap(
                                    spacing: 5,
                                    children: [
                                      Icon(Icons.info_outline_rounded),
                                      Text(FlutterI18n.translate(context, "account.title")),
                                    ],
                                  ),
                                ),
                                Tab(
                                  child: Wrap(
                                    spacing: 5,
                                    children: [
                                      Icon(Icons.front_hand),
                                      Text(FlutterI18n.translate(context, "report.title")),
                                    ],
                                  ),
                                ),
                              ],
                              dividerColor: Theme.of(context).dividerColor,
                            ),
                          )
                        ];
                      },
                      body: Column(
                        children: [
                          Flexible(
                            flex: 1,
                            child: MediaQuery.removePadding(
                              context: context,
                              child: TabBarView(
                                controller: tabController,
                                children: [
                                  /// 1
                                  SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 20),

                                        /// user info
                                        Container(
                                          width: MediaQuery.of(context).size.width,
                                          margin: const EdgeInsets.symmetric(horizontal: 15),
                                          child: Card(
                                            margin: EdgeInsets.zero,
                                            child: Padding(
                                              padding: const EdgeInsets.all(20),
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
                                                          FlutterI18n.translate(context, "account.role"),
                                                          style: const TextStyle(fontSize: 20),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      PrivilegesTagWidget(data: snapshot.data["privilege"]),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: <Widget>[
                                                      Opacity(
                                                        opacity: .5,
                                                        child: Text(
                                                          FlutterI18n.translate(context, "account.joinedAt"),
                                                          style: const TextStyle(fontSize: 20),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      TimeWidget(
                                                        data: snapshot.data["joinTime"],
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
                                                          FlutterI18n.translate(context, "account.lastOnlineTime"),
                                                          style: const TextStyle(fontSize: 20),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      TimeWidget(
                                                        data: snapshot.data["lastOnlineTime"],
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
                                                          FlutterI18n.translate(context, "account.reportNum"),
                                                          style: const TextStyle(fontSize: 20),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Text(
                                                        snapshot.data["reportNum"].toString(),
                                                        style: const TextStyle(fontSize: 18),
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 1,
                                                      )
                                                    ],
                                                  ),
                                                  if (snapshot.data["statusNum"] != null)
                                                    Wrap(
                                                      spacing: 40,
                                                      runSpacing: 25,
                                                      children: Map.from(snapshot.data["statusNum"]).entries.map((statusNumItem) {
                                                        return Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: <Widget>[
                                                            Opacity(
                                                              opacity: .5,
                                                              child: Text(
                                                                FlutterI18n.translate(context, "basic.status.${statusNumItem.key}.text"),
                                                                style: const TextStyle(fontSize: 20),
                                                              ),
                                                            ),
                                                            const SizedBox(height: 5),
                                                            Text(
                                                              snapshot.data["statusNum"][statusNumItem.key].toString(),
                                                              style: const TextStyle(fontSize: 18),
                                                              overflow: TextOverflow.ellipsis,
                                                              maxLines: 1,
                                                            ),
                                                          ],
                                                        );
                                                      }).toList(),
                                                    ),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: <Widget>[
                                                      Opacity(
                                                        opacity: .5,
                                                        child: Text(
                                                          FlutterI18n.translate(context, "profile.achievement.title"),
                                                          style: const TextStyle(fontSize: 20),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      achievementWidget(
                                                        data: snapshot.data["attr"]["achievements"],
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(height: 20),

                                        /// introduction
                                        if ((snapshot.data["attr"]["introduction"] as String).isNotEmpty)
                                          Container(
                                            width: MediaQuery.of(context).size.width,
                                            margin: const EdgeInsets.symmetric(horizontal: 15),
                                            child: Text(
                                              FlutterI18n.translate(context, "profile.space.form.introduction"),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        if ((snapshot.data["attr"]["introduction"] as String).isNotEmpty)
                                          Container(
                                            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                                            child: Card(
                                              child: Padding(
                                                padding: const EdgeInsets.all(10),
                                                child: SelectionArea(
                                                  child: HtmlCore(
                                                    data: snapshot.data["attr"]["introduction"],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),

                                  /// 2
                                  Refresh(
                                    key: _refreshKey,
                                    onRefresh: _onRefresh,
                                    onLoad: _getMore,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: reportListStatus.list.map((ReportListPlayerData item) {
                                          return CheatListCard(
                                            item: item.toMap,
                                            isIconHotView: false,
                                            isIconCommendView: false,
                                            isIconView: false,
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            });
          default:
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
              ),
              body: const Center(
                child: LoadingWidget(),
              ),
            );
        }
      },
    );
  }
}

class Background extends StatelessWidget {
  const Background({
    required this.src,
    this.textColor = const Color(0xFF757575),
    this.duration = const Duration(milliseconds: 750),
    this.curve = Curves.fastOutSlowIn,
  });

  final String src;
  final Color textColor;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: duration,
      curve: curve,
      child: Opacity(
        opacity: .3,
        child: ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (Rect bounds) {
            return const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black, Colors.transparent],
            ).createShader(Rect.fromLTRB(0, 0, bounds.width, bounds.height));
          },
          child: (src.isNotEmpty)
              ? EluiImgComponent(
                  src: src.toString(),
                  fit: BoxFit.fitWidth,
                  width: MediaQuery.of(context).size.width,
                  height: 250,
                )
              : Image.asset(
                  "assets/images/default-player-avatar.jpg",
                  fit: BoxFit.fitWidth,
                ),
        ),
      ),
    );
  }
}
