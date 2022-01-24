/// 社区

import 'dart:core';

import 'package:flutter/material.dart';

import 'package:flutter_elui_plugin/elui.dart';

import 'package:bfban/data/index.dart';
import 'package:bfban/constants/api.dart';
import 'package:bfban/utils/index.dart';
import 'package:provider/provider.dart';

import '../../provider/userinfo_provider.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({Key? key}) : super(key: key);

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final UrlUtil _urlUtil = UrlUtil();

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
    params: {
      "reports": "show", // show reports number
      "players": true, // show players that is reported number
      "confirmed": true, // show confirmed number
      "registers": true, // show register number
      "banappeals": true, // show ban appeals number
      "details": true, // show number of each game, each status
      "from": Date().getTurnTheTimestamp("2018-01-01")["millisecondsSinceEpoch"],
    },
  );

  // 请求参
  Map<String, dynamic> playerParame = {};

  @override
  void initState() {
    _getActivity();
    _getStatisticsInfo();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _getMore();
      }
    });
    super.initState();
  }

  /// [Response]
  /// 获取近期活动
  Future _getActivity() async {
    setState(() {
      activity?.load = true;
    });

    Response result = await Http.request(
      Config.httpHost["activities"],
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

    if (result.data["success"] == 1) {
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
    if (i["type"] == "verify" && i["type"] == "judgement" && i["originPersonaId"] != null) {
      _urlUtil.opEnPage(context, '/detail/cheaters/${i["originPersonaId"]}').then((value) {});
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
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            color: Theme.of(context).floatingActionButtonTheme.focusColor,
            backgroundColor: Theme.of(context).floatingActionButtonTheme.backgroundColor,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: activity!.list?.length,
              itemBuilder: (BuildContext context, int index) {
                var i = activity!.list![index];

                return GestureDetector(
                  child: Card(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    child: Stack(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
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
                              Wrap(
                                children: <Widget>[
                                  WidgetStateText(itemdata: i),
                                ],
                              ),
                            ],
                          ),
                        ),

                        Positioned(
                          top: 5,
                          left: 0,
                          child: Icon(
                            Icons.message,
                            size: 100,
                            color: Theme.of(context).textTheme.subtitle2!.color!.withOpacity(.02),
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () => _opEnDynamicDetail(i),
                );
              },
            ),
          ),
          flex: 1,
        ),

        // 加载
        activity!.load
            ? const Padding(
                padding: EdgeInsets.all(10),
                child: ELuiLoadComponent(
                  type: "line",
                  size: 20,
                  lineWidth: 2,
                  color: Colors.white,
                ),
              )
            : Container(),
      ],
    );
  }
}

/// 动态类型
class WidgetStateText extends StatelessWidget {
  final Map? itemdata;

  const WidgetStateText({
    Key? key,
    this.itemdata,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (itemdata!["type"]) {
      case "report":
        // 举报
        return Text(
          " \u4e3e\u62a5\u4e86 ${itemdata!["byUserName"]} ${itemdata!["game"]}",
          style: TextStyle(
            color: Theme.of(context).primaryTextTheme.headline3!.color,
            fontSize: 12,
          ),
        );
      case "register":
        // 注册
        return Text(
          "注册了BFBAN，欢迎",
          style: TextStyle(
            color: Theme.of(context).primaryTextTheme.headline3!.color,
            fontSize: 12,
          ),
        );
      case "verify":
      case "judgement":
        // 处理
        // 回复
        return Wrap(
          children: <Widget>[
            Text(
              "\u5c06${itemdata!["byUserName"]}\u5904\u7406\u4e3a",
              style: TextStyle(
                color: Theme.of(context).primaryTextTheme.headline3!.color,
                fontSize: 12,
              ),
            ),
            Container(
              padding: const EdgeInsets.only(
                left: 5,
                right: 5,
              ),
              decoration: BoxDecoration(
                color: Config.startusIng[(itemdata!["status"] ?? 0)]["c"],
                borderRadius: const BorderRadius.all(
                  Radius.circular(2),
                ),
              ),
              child: Text(
                Config.startusIng[(itemdata!["status"] ?? 0)]["s"].toString(),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
    }

    return Container();
  }
}
