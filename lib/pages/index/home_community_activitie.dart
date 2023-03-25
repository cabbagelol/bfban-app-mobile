/// 网站近期活动

import 'dart:core';

import 'package:flutter/material.dart';

import 'package:bfban/data/index.dart';
import 'package:bfban/constants/api.dart';
import 'package:bfban/utils/index.dart';
import 'package:flutter_elui_plugin/_img/index.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_i18n/widgets/I18nText.dart';

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

  // 统计数据
  Statistics statistics = Statistics(
    data: {
      "reports": 0,
      "confirmed": 0,
    },
    params: {"reports": true, "players": true, "confirmed": true, "registers": true, "banappeals": true, "details": true, "from": 1514764800000},
  );

  // 请求参
  Map<String, dynamic> playerParame = {};

  // 筛选标签的值
  late List<RestorableBool> restorablebool = [];

  // 筛选标签配置
  Map chipCont = {
    "list": [
      {"name": "report", "value": "report", "index": 0},
      {"name":"appealBan", "value" :"appealBan", "index": 1},
      {"name": "register", "value": "register", "index": 2},
      {"name": "verify", "value": "verify", "index": 3},
      {"name": "judgement", "value": "judgement", "index": 4}
    ],
    "tonal": 0
  };

  // 动态图标
  Map iconTypes = {
    "report": Icons.message,
    "appealBan": Icons.message,
    "register": Icons.notifications,
    "verify": Icons.message,
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
      restorablebool.add(RestorableBool(true));
    });

    _getActivity();
    _getStatisticsInfo();

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
    restorablebool.forEach((element) {
      element.dispose();
    });
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

  /// [Response]
  /// 获取统计数据
  Future _getStatisticsInfo() async {
    setState(() {
      statistics.load = true;
    });

    Response result = await Http.request(
      Config.httpHost["statistics"],
      parame: statistics.params,
      method: Http.GET,
    );

    if (result.data["success"] == 1 && result.data["data"] != null) {
      setState(() {
        statistics.data = result.data["data"];
      });
    }

    setState(() {
      statistics.load = false;
    });

    return true;
  }

  /// [Event]
  /// 打开社区动态详情内容i
  /// 区分类型
  void _opEnDynamicDetail(i) {
    if (i["type"] == "verify" || i["type"] == "judgement" && i["playerOriginPersonaId"] != null) {
      _urlUtil.opEnPage(context, '/detail/player/${i["playerOriginPersonaId"]}');
    }
  }

  /// [Event]
  /// 下拉刷新方法,为list重新赋值
  Future<void> _onRefresh() async {
    await _getActivity();
    await _getStatisticsInfo();
  }

  /// [Event]
  /// 下拉 追加数据
  Future _getMore() async {
    await _getActivity();
    activity!.page += 1;
  }

  @override
  Widget build(BuildContext context) {
    // 消息筛选
    List<Widget> chips() {
      // 筛选标签
      List chips = [];

      chipCont["list"].asMap().keys.forEach((index) {
        chips.add(
          FilterChip(
            padding: EdgeInsets.zero,
            labelStyle: TextStyle(
              fontSize: 13,
              color: Theme.of(context).primaryColor,
            ),
            label: Text(chipCont["list"][index]["name"].toString()),
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
            child: GestureDetector(
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 3),
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
                                EluiImgComponent(
                                  width: 30,
                                  height: 30,
                                  src: i["playerAvatarLink"],
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
                                child: Text(
                                  Date().getFriendlyDescriptionTime(i["createTime"]),
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
              ),
              onTap: () => _opEnDynamicDetail(i),
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
      color: Theme.of(context).primaryTextTheme.headline3!.color,
      fontSize: 14,
    );

    switch (itemData!["type"]) {
      case "report":
        // 举报
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [I18nText("home.activity.activities.report", child: Text("", style: textile)), I18nText("basic.games.${itemData!["game"]}", child: Text("", style: textile)), SizedBox(width: 5), Text(itemData!["toPlayerName"], style: textile)],
        );
      case "register":
        // 注册
        return I18nText("home.activity.activities.join", child: Text("", style: textile));
      case "verify":
      case "judgement":
        // 处理
        // 回复
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            I18nText("detail.info.judge", child: Text("", style: textile)),
            Text("${itemData!["toPlayerName"]}", style: textile),
            I18nText("basic.action.${itemData!["action"]}.text", child: Text("", style: textile)),
          ],
        );
    }

    return Container();
  }
}
