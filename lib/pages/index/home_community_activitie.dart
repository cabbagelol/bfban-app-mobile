/// 网站近期活动

import 'dart:core';

import 'package:bfban/component/_Time/index.dart';
import 'package:bfban/component/_gamesTag/index.dart';
import 'package:flutter/material.dart';

import 'package:bfban/data/index.dart';
import 'package:bfban/constants/api.dart';
import 'package:bfban/utils/index.dart';
import 'package:flutter_elui_plugin/_img/index.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class HomeCommunityPage extends StatefulWidget {
  const HomeCommunityPage({Key? key}) : super(key: key);

  @override
  HomeCommunityPageState createState() => HomeCommunityPageState();
}

class HomeCommunityPageState extends State<HomeCommunityPage> with RestorationMixin, AutomaticKeepAliveClientMixin {
  final UrlUtil _urlUtil = UrlUtil();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  // 列表视图控制器
  final ScrollController _scrollController = ScrollController();

  // 动态数据
  Activity? activity = Activity(
    page: 0,
    load: false,
    list: [],
  );

  // 请求参
  Map<String, dynamic> playerParame = {};

  // 筛选标签的值
  late List<RestorableBool> restorablebool = [];

  // 筛选标签配置
  Map chipCont = {
    "list": [
      {"name": "app.home.screen.report", "value": "report", "index": 0},
      {"name": "app.home.screen.banAppeal", "value": "appealBan", "index": 1},
      {"name": "app.home.screen.signup", "value": "register", "index": 2},
      {"name": "app.home.screen.judgement", "value": "judgement", "index": 3}
    ],
    "tonal": 0
  };

  // 动态图标
  Map iconTypes = {
    "report": Icons.message,
    "appealBan": Icons.message,
    "register": Icons.notifications,
    "judgement": Icons.terminal,
  };

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    // 滚动视图初始
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _getMore();
      }
    });

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
    if (activity?.load == true) return;

    setState(() {
      Future.delayed(const Duration(seconds: 0), () {
        _refreshIndicatorKey.currentState!.show();
      });
      activity?.load = true;
      activity?.list = [];
    });

    Response result = await Http.request(
      Config.httpHost["activity"],
      parame: playerParame,
      method: Http.GET,
    );

    if (result.data["success"] == 1) {
      final List d = result.data["data"];

      setState(() {
        if (activity!.page <= 0) {
          activity?.list = d;
        } else {
          // 追加数据
          if (d.isNotEmpty) {
            activity?.list?.addAll(d);
          }
        }
      });
    }

    setState(() {
      activity?.load = false;
    });

    return true;
  }

  /// [Event]
  /// 打开社区动态详情内容i
  /// 区分类型
  void _opEnDynamicDetail(i) {
    switch(i["type"]) {
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
  Future<void> _onRefresh() async {
    await _getActivity();
  }

  /// [Event]
  /// 下拉 追加数据
  Future _getMore() async {
    await _getActivity();
    activity!.page += 1;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // 消息筛选
    List<Widget> chips() {
      // 筛选标签
      List chips = [];

      chipCont["list"].asMap().keys.forEach((index) {
        chips.add(
          FilterChip(
            padding: EdgeInsets.zero,
            backgroundColor: Theme.of(context).tabBarTheme.labelColor!.withOpacity(.8),
            selectedColor: Theme.of(context).tabBarTheme.labelColor,
            labelStyle: TextStyle(
              fontSize: 13,
              color: Theme.of(context).bottomAppBarTheme.color,
            ),
            label: Text(FlutterI18n.translate(context, chipCont["list"][index]["name"])),
            selected: restorablebool[index].value,
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

    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: activity!.list!.length + 1,
        itemBuilder: (BuildContext context, int index) {
          // 筛选
          if (index == 0) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              height: 53.0,
              color: Theme.of(context).primaryColorDark.withOpacity(.1),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: chips(),
                  )
                ],
              ),
            );
          }

          Map i = activity!.list![index - 1];

          return Visibility(
            visible: _isShow(i),
            child: Column(
              children: [
                GestureDetector(
                  child: Stack(
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
                                    child: EluiImgComponent(
                                      width: 30,
                                      height: 30,
                                      src: i["playerAvatarLink"],
                                    ),
                                  )
                                else
                                  CircleAvatar(
                                    radius: 15,
                                    child: Text((i["username"] ?? i["byUserName"] ?? i["toPlayerName"])[0].toString()),
                                  ),
                                const SizedBox(width: 10),
                                Text(
                                  (i["username"] ?? i["byUserName"] ?? i["toPlayerName"]).toString(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                  ),
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
                          color: Theme.of(context).textTheme.subtitle2!.color!.withOpacity(.02),
                        ),
                      ),
                    ],
                  ),
                  onTap: () => _opEnDynamicDetail(i),
                ),
                const Divider(height: 1),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// 动态类型
class WidgetStateText extends StatelessWidget {
  final Map? itemData;

  const WidgetStateText({
    Key? key,
    this.itemData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextStyle textile = TextStyle(
      color: Theme.of(context).textTheme.displayMedium!.color,
      fontSize: 14,
    );

    switch (itemData!["type"]) {
      case "report":
        // 举报
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text("${FlutterI18n.translate(context, "home.activity.activities.report")}\t", style: textile),
            GamesTagWidget(
              data: itemData!["game"],
            ),
            const SizedBox(width: 5),
            Text(itemData!["toPlayerName"], style: textile),
          ],
        );
      case "register":
        // 注册
        return Text("${FlutterI18n.translate(context, "home.activity.activities.join")}\t", style: textile);
      case "verify":
      case "judgement":
        // 处理
        // 回复
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Text("${FlutterI18n.translate(context, "detail.info.judge")}\t", style: textile),
            Text("${itemData!["toPlayerName"]}", style: textile),
            Text(FlutterI18n.translate(context, "basic.action.${itemData!["action"]}.text"), style: textile),
          ],
        );
    }

    return Container();
  }
}
