import 'package:bfban/component/_Time/index.dart';
import 'package:bfban/component/_achievement/index.dart';
import 'package:bfban/component/_empty/index.dart';
import 'package:bfban/component/_html/html.dart';
import 'package:bfban/component/_html/htmlWidget.dart';
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

class UserSpacePageState extends State<UserSpacePage> {
  final UrlUtil _urlUtil = UrlUtil();

  /// 列表
  final GlobalKey<RefreshState> _refreshKey = GlobalKey<RefreshState>();

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

  @override
  void initState() {
    super.initState();
    ready();
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
          _refreshKey.currentState!.controller.finishLoad(IndicatorResult.noMore);
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
                body: Refresh(
                  key: _refreshKey,
                  onRefresh: _onRefresh,
                  onLoad: _getMore,
                  edgeOffset: 100 + MediaQuery.of(context).viewInsets.top,
                  child: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        stretch: true,
                        pinned: false,
                        backgroundColor: Colors.transparent,
                        leading: Container(),
                        toolbarHeight: 0,
                        expandedHeight: 200,
                        flexibleSpace: FlexibleSpaceBar(
                          key: appBarKey,
                          expandedTitleScale: 1.2,
                          centerTitle: true,
                          stretchModes: const [StretchMode.blurBackground, StretchMode.zoomBackground],
                          titlePadding: const EdgeInsets.only(top: 120),
                          title: OverflowBox(
                            maxHeight: 200,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: CircleAvatar(
                                    radius: 40,
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
                                            style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.displayMedium!.color),
                                          ),
                                        ],
                                      )
                                    : I18nText("account.title", child: const Text(""))
                              ],
                            ),
                          ),
                          background: snapshot.data["userAvatar"] != null ? Back(src: snapshot.data["userAvatar"].toString()) : null,
                        ),
                      ),
                      if (reportListStatus.list.isNotEmpty)
                        SliverList.list(
                          children: [
                            if ((snapshot.data["attr"]["introduction"] as String).isNotEmpty)
                              SelectionArea(
                                child: HtmlCore(
                                  data: snapshot.data["attr"]["introduction"],
                                ),
                              ),
                            Container(height: 10),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              margin: const EdgeInsets.symmetric(horizontal: 5),
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
                            Column(
                              children: reportListStatus.list.map((ReportListPlayerData item) {
                                return CheatListCard(
                                  item: item.toMap,
                                  isIconHotView: false,
                                  isIconCommendView: false,
                                  isIconView: false,
                                );
                              }).toList(),
                            ),
                          ],
                        )
                      else
                        SliverList.list(children: const [
                          EmptyWidget(),
                        ]),
                    ],
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
                child: CircularProgressIndicator(),
              ),
            );
        }
      },
    );
  }
}

class Back extends StatelessWidget {
  const Back({
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
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black, Colors.transparent],
                  ).createShader(Rect.fromLTRB(0, 0, bounds.width, bounds.height));
                },
                child: (src != null && src.isNotEmpty)
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
          ],
        ),
      ),
    );
  }
}
