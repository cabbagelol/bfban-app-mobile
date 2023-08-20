/// 首页活动面板

import 'dart:convert';

import 'package:bfban/data/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/_load/index.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
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
  void _openReply() {
    String data = jsonEncode({"originName": ""});

    _urlUtil.opEnPage(context, '/report/$data');
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
      "${Config.apiHost["web_site"]!.url}/apps",
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
              margin: const EdgeInsets.only(bottom: 10, left: 15, right: 15),
              child: Container(
                height: 70,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 50,
                          maxWidth: 100,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            statistics.load
                                ? Column(
                                    children: [
                                      ELuiLoadComponent(
                                        type: "line",
                                        lineWidth: 1,
                                        color: Theme.of(context).textTheme.displayMedium!.color!,
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
                                    maxLines: 1,
                                  ),
                            I18nText(
                              "home.cover.dataReceived",
                              child: Text(
                                "0",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).textTheme.displayMedium!.color,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                        left: 7,
                        right: 7,
                      ),
                      height: 25,
                      width: 1,
                      color: Theme.of(context).dividerTheme.color!,
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 50,
                          maxWidth: 100,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            statistics.load
                                ? Column(
                                    children: [
                                      ELuiLoadComponent(
                                        type: "line",
                                        lineWidth: 1,
                                        color: Theme.of(context).textTheme.displayMedium!.color!,
                                        size: 18,
                                      ),
                                      const SizedBox(height: 5),
                                    ],
                                  )
                                : Text(
                                    statistics.data!.confirmed.toString(),
                                    style: const TextStyle(
                                      fontSize: 20,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                            I18nText(
                              "home.cover.confirmData",
                              child: Text(
                                "",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).textTheme.displayMedium!.color,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                        left: 7,
                        right: 7,
                      ),
                      height: 25,
                      width: 1,
                      color: Theme.of(context).dividerTheme.color!,
                    ),
                    Opacity(
                      opacity: data.isLogin ? 1 : .3,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: TextButton(
                          child: Row(
                            children: [
                              const Icon(Icons.add),
                              Text(
                                FlutterI18n.translate(context, "report.title"),
                              ),
                            ],
                          ),
                          onPressed: () => data.isLogin ? _openReply() : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Card(
              margin: const EdgeInsets.only(bottom: 11, left: 15, right: 15),
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    I18nText(
                      "sitestats.registers",
                      child: Text(
                        "0",
                        style: TextStyle(
                          color: Theme.of(context).textTheme.displayMedium!.color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (statistics.load)
                      Column(
                        children: [
                          ELuiLoadComponent(
                            type: "line",
                            lineWidth: 1,
                            color: Theme.of(context).textTheme.displayMedium!.color!,
                            size: 18,
                          ),
                        ],
                      )
                    else
                      Text(
                        statistics.data!.registers.toString(),
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                        overflow: TextOverflow.ellipsis,
                      )
                  ],
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.only(bottom: 11, left: 15, right: 15),
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    I18nText(
                      "sitestats.banAppeals",
                      child: Text(
                        "0",
                        style: TextStyle(
                          color: Theme.of(context).textTheme.displayMedium!.color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (statistics.load)
                      Column(
                        children: [
                          ELuiLoadComponent(
                            type: "line",
                            lineWidth: 1,
                            color: Theme.of(context).textTheme.titleMedium!.color!,
                            size: 18,
                          ),
                        ],
                      )
                    else
                      Text(
                        statistics.data!.banAppeals.toString(),
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                        overflow: TextOverflow.ellipsis,
                      )
                  ],
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.only(bottom: 11, left: 15, right: 15),
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    I18nText(
                      "sitestats.players",
                      child: Text(
                        "0",
                        style: TextStyle(
                          color: Theme.of(context).textTheme.displayMedium!.color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (statistics.load)
                      Column(
                        children: [
                          ELuiLoadComponent(
                            type: "line",
                            lineWidth: 1,
                            color: Theme.of(context).textTheme.titleMedium!.color!,
                            size: 18,
                          ),
                        ],
                      )
                    else
                      Text(
                        statistics.data!.players.toString(),
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                        overflow: TextOverflow.ellipsis,
                      )
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
