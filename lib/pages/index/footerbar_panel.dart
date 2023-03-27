/// 首页活动面板

import 'dart:convert';

import 'package:bfban/data/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/_load/index.dart';
import 'package:flutter_i18n/widgets/I18nText.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/api.dart';
import '../../provider/userinfo_provider.dart';
import '../../utils/index.dart';

class HomeButtomPanel extends StatefulWidget {
  const HomeButtomPanel({Key? key}) : super(key: key);

  @override
  _HomeButtomPanelState createState() => _HomeButtomPanelState();
}

class _HomeButtomPanelState extends State<HomeButtomPanel> {
  final UrlUtil _urlUtil = UrlUtil();

  // 统计数据
  Statistics statistics = Statistics(
    data: StatisticsData(reports: 0, confirmed: 0),
    params: StatisticsParame(from: 1514764800000),
  );

  @override
  void initState() {
    _getStatisticsInfo();

    super.initState();
  }

  /// [Response]
  /// 获取统计数据
  Future _getStatisticsInfo() async {
    if (statistics.load) return;

    setState(() {
      statistics.load = true;
    });

    Response result = await Http.request(
      Config.httpHost["statistics"],
      parame: statistics.params!.toMap,
      method: Http.GET,
    );

    if (result.data["success"] == 1) {
      setState(() {
        statistics.data?.setData(result.data["data"]);
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

  /// [Event]
  /// 打开支援连接
  void _openSupport() {
    _urlUtil.onPeUrl(
      "https://support.qq.com/products/64038",
      mode: LaunchMode.externalApplication,
    );
  }

  /// [Event]
  /// 打开Apps连接
  void _openApps() {
    _urlUtil.onPeUrl(
      "${Config.apiHost["web_site"]}/apps",
      mode: LaunchMode.externalApplication,
    );
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
              margin: const EdgeInsets.only(bottom: 11, left: 15, right: 15),
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
                    SizedBox(
                      width: 100,
                      child: Column(
                        children: <Widget>[
                          statistics.load
                              ? Column(
                                  children: [
                                    ELuiLoadComponent(
                                      type: "line",
                                      lineWidth: 1,
                                      color: Theme.of(context).textTheme.subtitle1!.color!,
                                      size: 18,
                                    ),
                                    const SizedBox(height: 5),
                                  ],
                                )
                              : Text(
                                  statistics.data!.reports.toString(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                          I18nText(
                            "home.cover.dataReceived",
                            child: Text(
                              "0",
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).textTheme.subtitle2!.color,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        ],
                      ),
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
                    SizedBox(
                      width: 100,
                      child: Column(
                        children: <Widget>[
                          statistics.load
                              ? ELuiLoadComponent(
                                  type: "line",
                                  lineWidth: 1,
                                  color: Theme.of(context).textTheme.subtitle1!.color!,
                                  size: 18,
                                )
                              : Text(
                                  statistics.data!.confirmed.toString(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                          I18nText(
                            "home.cover.confirmData",
                            child: Text(
                              "",
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).textTheme.subtitle2!.color,
                              ),
                            ),
                          )
                        ],
                      ),
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
                    Flexible(
                      flex: 1,
                      child: Opacity(
                        opacity: data.isLogin ? 1 : .3,
                        child: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: data.isLogin ? _openReply() : null,
                        ),
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
              flex: 1,
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
                            onPressed: data.isLogin ? _openReply() : null,
                            child: Column(
                              children: const [
                                Icon(
                                  Icons.list,
                                  size: 35,
                                ),
                                Text("举报玩家")
                              ],
                            ),
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
                          onPressed: () => _openApps(),
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
                          onPressed: () => _openSupport(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
