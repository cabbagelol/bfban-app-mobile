/// 网站近期活动

import 'dart:core';

import 'package:bfban/component/_Time/index.dart';
import 'package:bfban/component/_gamesTag/index.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

import 'package:bfban/data/index.dart';
import 'package:bfban/constants/api.dart';
import 'package:bfban/utils/index.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../../component/_refresh/index.dart';

class HomeCommunityPage extends StatefulWidget {
  const HomeCommunityPage({Key? key}) : super(key: key);

  @override
  HomeCommunityPageState createState() => HomeCommunityPageState();
}

class HomeCommunityPageState extends State<HomeCommunityPage> with RestorationMixin, AutomaticKeepAliveClientMixin {
  final UrlUtil _urlUtil = UrlUtil();

  // 列表
  final GlobalKey<RefreshState> _refreshKey = GlobalKey<RefreshState>();

  // 列表视图控制器
  final ScrollController _scrollController = ScrollController();

  // 动态数据
  ActivityStatus activityStatus = ActivityStatus(load: false, list: [], parame: ActivityParame());

  // 筛选标签的值
  late List<RestorableBool> restorablebool = [];

  // 筛选标签配置
  Map chipCont = {
    "list": [
      {"name": "app.home.screen.report", "value": "report", "index": 0},
      {"name": "app.home.screen.banAppeal", "value": "banAppeal", "index": 1},
      {"name": "app.home.screen.signup", "value": "register", "index": 2},
      {"name": "app.home.screen.judgement", "value": "judgement", "index": 3}
    ],
    "tonal": 0
  };

  // 动态图标
  Map iconTypes = {
    "report": Icons.message,
    "banAppeal": Icons.contact_mail,
    "register": Icons.notifications,
    "judgement": Icons.terminal,
  };

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    // 初始筛选
    chipCont["list"].forEach((element) {
      restorablebool.add(RestorableBool(false));
    });

    _getActivity();

    super.initState();
  }

  @override
  String get restorationId => 'filter_chip';

  @override
  void restoreState(RestorationBucket? oldBucket, bool? initialRestore) {
    restorablebool.asMap().keys.forEach((index) {
      registerForRestoration(restorablebool[index], index.toString());
    });
  }

  @override
  void dispose() {
    for (var element in restorablebool) {
      element.dispose();
    }
    super.dispose();
  }

  /// [Response]
  /// 获取近期活动
  Future _getActivity() async {
    if (activityStatus.load) return;

    setState(() {
      activityStatus.load = true;
      activityStatus.list = [];
    });

    Response result = await Http.request(
      Config.httpHost["activity"],
      method: Http.GET,
    );

    if (result.data["success"] == 1) {
      final List d = result.data["data"];

      setState(() {
        if (activityStatus.parame.skip! <= 0) {
          activityStatus.list = d;
        } else {
          // 追加数据
          if (d.isNotEmpty) {
            activityStatus.list?.addAll(d);
          }
        }
      });
    }

    setState(() {
      activityStatus.load = false;
    });

    return true;
  }

  /// [Event]
  /// 打开社区动态详情内容i
  /// 区分类型
  void _opEnDynamicDetail(i) {
    switch (i["type"]) {
      case "verify":
      case "judgement":
      case "report":
        if (i["playerOriginPersonaId"] != null) {
          _urlUtil.opEnPage(context, '/player/personaId/${i["playerOriginPersonaId"]}');
        }
        break;
      case "register":
        _urlUtil.opEnPage(context, '/account/${i["id"]}');
        break;
    }
  }

  /// [Event]
  /// 下拉刷新方法,为list重新赋值
  Future _onRefresh() async {
    await _getActivity();

    _refreshKey.currentState!.controller.finishRefresh();
    _refreshKey.currentState!.controller.resetFooter();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // 消息筛选
    List<Widget> chipWidgets() {
      // 动态筛选标签
      List chips = [];

      chipCont["list"].asMap().keys.forEach((index) {
        chips.add(
          FilterChip(
            backgroundColor: Theme.of(context).chipTheme.backgroundColor,
            selectedColor: Theme.of(context).chipTheme.selectedColor,
            selected: restorablebool[index].value,
            visualDensity: const VisualDensity(horizontal: 3, vertical: -4),
            label: Text(FlutterI18n.translate(context, chipCont["list"][index]["name"])),
            onSelected: (value) {
              setState(() {
                restorablebool[index].value = !restorablebool[index].value;
              });
            },
          ),
        );
      });
      return chips.map<Widget>((chip) => chip).toList();
    }

    // 消息筛选是否可见
    bool _isShow(i) {
      var item = chipCont["list"].where((element) => element["value"] == i["type"]).toList();
      var is_ = item.length > 0 ? restorablebool[item[0]["index"]].value : false;

      if (restorablebool.where((element) => element.value).isEmpty) is_ = true;

      return is_;
    }

    return Refresh(
      key: _refreshKey,
      onRefresh: _onRefresh,
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: activityStatus.list!.isNotEmpty && !activityStatus.load
            ? ListView.builder(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).systemGestureInsets.bottom + kBottomNavigationBarHeight),
                controller: _scrollController,
                itemCount: activityStatus.list!.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  // 筛选
                  if (index == 0) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      height: 40,
                      color: Theme.of(context).primaryColorDark.withOpacity(.1),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          const Icon(Icons.filter_list_outlined),
                          const SizedBox(width: 5),
                          Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children: chipWidgets(),
                          )
                        ],
                      ),
                    );
                  }

                  Map i = activityStatus.list![index - 1];

                  return Visibility(
                    visible: _isShow(i),
                    child: InkWell(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        if (i["playerAvatarLink"] != null)
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(20),
                                            child: ExtendedImage.network(
                                              i["playerAvatarLink"],
                                              width: 30,
                                              height: 30,
                                              fit: BoxFit.fill,
                                              cacheWidth: 30,
                                              cacheHeight: 30,
                                              cache: true,
                                              printError: false,
                                              loadStateChanged: (ExtendedImageState state) {
                                                switch (state.extendedImageLoadState) {
                                                  case LoadState.completed:
                                                    return state.completedWidget;
                                                  case LoadState.failed:
                                                  default:
                                                    return Image.asset(
                                                      "assets/images/default-player-avatar.jpg",
                                                      cacheWidth: 30,
                                                      cacheHeight: 30,
                                                    );
                                                }
                                              },
                                            ),
                                          )
                                        else
                                          CircleAvatar(
                                            radius: 15,
                                            child: Text((i["username"] ?? i["byUserName"] ?? i["toPlayerName"])[0].toString().toUpperCase()),
                                          ),
                                        const SizedBox(width: 10),
                                        Text(
                                          (i["username"] ?? i["toPlayerName"]).toString(),
                                          style: const TextStyle(fontSize: 20, fontFamily: "UbuntuMono"),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: TimeWidget(
                                            data: i["createTime"],
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    WidgetStateText(itemData: i),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 5,
                                right: 0,
                                child: Icon(
                                  iconTypes[i["type"]] ?? Icons.message_outlined,
                                  size: 70,
                                  color: Theme.of(context).textTheme.titleSmall!.color!.withOpacity(.02),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 1),
                        ],
                      ),
                      onTap: () => _opEnDynamicDetail(i),
                    ),
                  );
                },
              )
            : ListView.builder(
                controller: _scrollController,
                itemCount: 8,
                itemBuilder: (BuildContext context, int index) {
                  return Opacity(
                    opacity: 1 - (.1 * index),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Placeholder(
                                      color: Theme.of(context).cardTheme.color!.withOpacity(.8),
                                      strokeWidth: 20,
                                      child: const SizedBox(
                                        width: 30,
                                        height: 30,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Placeholder(
                                    color: Theme.of(context).cardTheme.color!.withOpacity(.8),
                                    strokeWidth: 10,
                                    child: const SizedBox(
                                      width: 30,
                                      height: 8,
                                    ),
                                  ),
                                  const Expanded(flex: 1, child: SizedBox()),
                                  Placeholder(
                                    color: Theme.of(context).cardTheme.color!.withOpacity(.8),
                                    strokeWidth: 10,
                                    child: const SizedBox(
                                      width: 50,
                                      height: 6,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Placeholder(
                                    color: Theme.of(context).cardTheme.color!.withOpacity(.8),
                                    strokeWidth: 10,
                                    child: const SizedBox(
                                      width: 120,
                                      height: 5,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Placeholder(
                                    color: Theme.of(context).cardTheme.color!.withOpacity(.8),
                                    strokeWidth: 10,
                                    child: const SizedBox(
                                      width: 120,
                                      height: 5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 35,
                          right: 0,
                          child: Opacity(
                            opacity: .5,
                            child: Placeholder(
                              color: Theme.of(context).cardTheme.color!.withOpacity(.8),
                              strokeWidth: 50,
                              child: const SizedBox(
                                width: 70,
                                height: 70,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

/// 动态类型
class WidgetStateText extends StatelessWidget {
  final Map? itemData;

  final Util _util = Util();

  WidgetStateText({
    Key? key,
    this.itemData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextStyle? textile = Theme.of(context).listTileTheme.subtitleTextStyle;

    switch (itemData!["type"]) {
      case "report":
        // 举报
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text((itemData!["username"] ?? itemData!["byUserName"] ?? itemData!["toPlayerName"]).toString(), style: textile),
            Text("\t${FlutterI18n.translate(context, "home.activity.activities.report")}\t", style: textile),
            GamesTagWidget(data: itemData!["game"]),
            const SizedBox(width: 5),
            Text(itemData!["toPlayerName"], style: textile),
          ],
        );
      case "register":
        // 注册
        return Text("${FlutterI18n.translate(context, "home.activity.activities.join")}\t", style: textile);
      case "verify":
      case "judgement":
        // 处理或回复, 判决
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Text((itemData!["username"] ?? itemData!["byUserName"] ?? itemData!["toPlayerName"]).toString(), style: textile),
            Text("\t${FlutterI18n.translate(context, "detail.info.judge")}\t", style: textile),
            Text("${itemData!["toPlayerName"]}", style: textile),
            Text(FlutterI18n.translate(context, "basic.action.${_util.queryAction(itemData!["action"])}.text"), style: textile),
          ],
        );
      case "banAppeal":
        return Wrap(
          children: [
            Text("${FlutterI18n.translate(context, "detail.appeal.info.content")}\t", style: textile),
            GamesTagWidget(
              data: itemData!["playerGames"],
            ),
          ],
        );
      default:
        return Text(itemData!["type"], style: textile);
    }
  }
}
