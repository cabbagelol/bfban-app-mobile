/// 用户展示页
/// 站内用户

import 'package:flutter/material.dart';

import 'package:bfban/constants/api.dart';
import 'package:flutter_elui_plugin/elui.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../../component/_privilegesTag/index.dart';
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

  /// 异步
  Future? futureBuilder;

  final ScrollController _scrollController = ScrollController();

  /// 用户信息
  StationUserSpaceStatus userSpaceInfo = StationUserSpaceStatus(
    data: StationUserSpaceData(),
    parame: StationUserSpaceParame(id: null),
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

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _getMore();
      }
    });

    ready();
  }

  void ready() async {
    // Update query id
    userSpaceInfo.parame.id = widget.id!;
    reportListStatus.parame.id = int.parse(widget.id!);

    futureBuilder = _getUserSpaceInfo();
  }

  // get getReports => _getReports;

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
      final d = result.data["data"];

      setState(() {
        reportListStatus.list = d;
      });
    }

    setState(() {
      userSpaceInfo.load = false;
    });
  }

  /// [Event]
  /// 作弊玩家信息 刷新
  Future<void> _onRefresh() async {
    setState(() {
      reportListStatus.list = [];
      reportListStatus.parame.resetPage();
    });

    await _getSiteUserReports();
  }

  /// [Event]
  /// 下拉 追加数据
  Future _getMore() async {
    await _getSiteUserReports();
    reportListStatus.parame.nextPage();
  }

  /// [Event]
  /// 聊天
  _openMessage(String id) {
    return () async {
      if (await ProviderUtil().ofUser(context).userinfo["id"] == id) {
        EluiMessageComponent.warning(context)(child: Text(FlutterI18n.translate(context, "account.message.hint.selfTalk")));
        return;
      }

      if (userSpaceInfo.data!.attr!.allowDM! == false) {
        EluiMessageComponent.warning(context)(child: Text(FlutterI18n.translate(context, "account.message.hint.taOffChat")));
        return;
      }

      _urlUtil.opEnPage(context, "/message/$id");
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

            return Scaffold(
              appBar: AppBar(
                title: snapshot.data["username"] != null ? Text(snapshot.data["username"]) : I18nText("account.title", child: const Text("")),
                centerTitle: true,
                actions: [
                  PopupMenuButton(
                    onSelected: (value) {
                      switch (value) {
                        case 1:
                          _openMessage(userSpaceInfo.data!.id.toString());
                          break;
                        case 2:
                          break;
                      }
                    },
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          value: 2,
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
              body: RefreshIndicator(
                onRefresh: _onRefresh,
                child: ListView(
                  controller: _scrollController,
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    // 空间用户信息
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          CircleAvatar(
                            radius: 35,
                            child: Text(
                              snapshot.data["username"][0].toString().toUpperCase(),
                              style: const TextStyle(fontSize: 25),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),

                    // 统计信息
                    Container(
                      height: 100,
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          width: 1,
                          color: Theme.of(context).dividerTheme.color!.withOpacity(.1),
                        ),
                      ),
                      child: Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  PrivilegesTagWidget(data: snapshot.data["privilege"]),
                                  Text(
                                    FlutterI18n.translate(context, "account.role"),
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  )
                                ],
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 20),
                                height: 30,
                                width: 1,
                                color: Theme.of(context).dividerTheme.color,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    Date().getFriendlyDescriptionTime(snapshot.data["joinTime"]).toString(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    FlutterI18n.translate(context, "account.joinedAt"),
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  )
                                ],
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 20),
                                height: 30,
                                width: 1,
                                color: Theme.of(context).dividerTheme.color,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    Date().getFriendlyDescriptionTime(snapshot.data["lastOnlineTime"]).toString(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    FlutterI18n.translate(context, "account.lastOnlineTime"),
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  )
                                ],
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 20),
                                height: 30,
                                width: 1,
                                color: Theme.of(context).dividerTheme.color,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    reportListStatus.list.length.toString(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    FlutterI18n.translate(context, "account.reportNum"),
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 举报列表
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
                ),
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
