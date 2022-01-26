/// 主页面板

import 'dart:convert';

import 'package:bfban/data/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/api.dart';
import '../../provider/userinfo_provider.dart';
import '../../utils/index.dart';

class SearchPanel extends StatefulWidget {
  const SearchPanel({Key? key}) : super(key: key);

  @override
  _searchPanelState createState() => _searchPanelState();
}

class _searchPanelState extends State<SearchPanel> {
  final UrlUtil _urlUtil = UrlUtil();

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

  @override
  void initState() {
    _getStatisticsInfo();

    super.initState();
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
  /// 举报
  dynamic _openReply() {
    return () {
      // 新举报 传空
      String data = jsonEncode({"originName": ""});

      _urlUtil.opEnPage(context, '/report/$data').then((value) {});
    };
  }

  /// [Event]
  /// 登录
  dynamic _openLogin() {
    return () {
      _urlUtil.opEnPage(context, '/login/panel').then((value) {});
    };
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserInfoProvider>(
      builder: (context, data, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // 统计
            Card(
              margin: const EdgeInsets.only(bottom: 10, left: 15, right: 15),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    width: 1,
                    color: Theme.of(context).dividerTheme.color!,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Text(
                          statistics.data!["reports"].toString(),
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          "\u5df2\u6838\u5b9e\u4f5c\u5f0a\u73a9\u5bb6\u4eba\u6570",
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.subtitle2!.color,
                          ),
                        )
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                        left: 7,
                        right: 7,
                      ),
                      height: 30,
                      width: 1,
                      color: Theme.of(context).dividerColor,
                    ),
                    Column(
                      children: <Widget>[
                        Text(
                          statistics.data!["confirmed"].toString(),
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          "\u793e\u533a\u5df2\u6536\u5230\u4e3e\u62a5\u6b21\u6570",
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.subtitle2!.color,
                          ),
                        )
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                        left: 7,
                        right: 7,
                      ),
                      height: 30,
                      width: 1,
                      color: Theme.of(context).dividerColor,
                    ),
                    Opacity(
                      opacity: data.isLogin ? 1 : .3,
                      child: TextButton(
                        onPressed: data.isLogin ? _openReply() : null,
                        child: const Icon(Icons.add),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 登录提示
            Consumer<UserInfoProvider>(
              builder: (context, appInfo, child) {
                return Visibility(
                  visible: !appInfo.isLogin,
                  child: MaterialBanner(
                    content: const Text("登录联ban账户，对作弊玩家提交证据或自我证明功能"),
                    actions: [
                      TextButton(
                        onPressed: _openLogin(),
                        child: const Text("登录"),
                      )
                    ],
                  ),
                );
              },
            ),

            // 功能块
            Expanded(
              child: CustomScrollView(
                primary: false,
                slivers: <Widget>[
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    sliver: SliverGrid.count(
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      crossAxisCount: 4,
                      children: <Widget>[
                        Opacity(
                          opacity: data.isLogin ? 1 : .3,
                          child: TextButton(
                            child: Column(
                              children: const [
                                Icon(
                                  Icons.list,
                                  size: 35,
                                ),
                                Text("举报玩家")
                              ],
                            ),
                            onPressed: data.isLogin ? _openReply() : null,
                          ),
                        ),
                        TextButton(
                          child: Column(
                            children: const [
                              Icon(
                                Icons.list,
                                size: 35,
                              ),
                              Text("应用中心")
                            ],
                          ),
                          onPressed: () {
                            _urlUtil.onPeUrl("${Config.apiHost["web_site"]}/apps");
                          },
                        ),
                        TextButton(
                          child: Column(
                            children: const [
                              Icon(
                                Icons.list,
                                size: 35,
                              ),
                              Text("论坛")
                            ],
                          ),
                          onPressed: () {
                            _urlUtil.onPeUrl("https://support.qq.com/products/64038");
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              flex: 1,
            ),
          ],
        );
      },
    );
  }
}
