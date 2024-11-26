/// 首页活动面板
library homeFooterBarPanel;

import 'dart:convert';

import 'package:bfban/component/_loading/index.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/_img/index.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

import '../../component/_refresh/index.dart';
import '/widgets/drawer.dart';
import '/data/index.dart';
import '/constants/api.dart';
import '/provider/userinfo_provider.dart';
import '/utils/index.dart';

class HomeFooterBarPanel extends StatefulWidget {
  GlobalKey<DragContainerState>? dragContainerKey;

  HomeFooterBarPanel({
    Key? key,
    this.dragContainerKey,
  }) : super(key: key);

  @override
  _HomeFooterBarPanelState createState() => _HomeFooterBarPanelState();
}

class _HomeFooterBarPanelState extends State<HomeFooterBarPanel> {
  final UrlUtil _urlUtil = UrlUtil();

  final Storage storage = Storage();

  final GlobalKey<RefreshState> _refreshKey = GlobalKey<RefreshState>();

  bool modalStatus = false;

  bool modalOpenOne = false;

  // 统计数据
  Statistics statistics = Statistics(
    data: StatisticsData(reports: 0, confirmed: 0),
    params: StatisticsParame(from: 1514764800000),
  );

  // 游览记录
  TourRecordStatus tourRecordStatus = TourRecordStatus(
    load: false,
    list: [],
  );

  // 订阅
  TraceStatus traceStatus = TraceStatus(
    load: false,
    list: [],
    parame: TraceParame(
      limit: 5,
      skip: 0,
    ),
  );

  @override
  void initState() {
    widget.dragContainerKey!.currentState!.offstage.addListener(() {
      modalStatus = widget.dragContainerKey!.currentState!.offstage.value;

      if (modalStatus && !modalOpenOne) {
        _getStatisticsInfo();
        _getTourRecordList();
        _getSubscribesList();

        modalOpenOne = true;
      }
    });

    super.initState();
  }

  Future _onRefresh() async {
    _getStatisticsInfo();
    _getTourRecordList();
    _getSubscribesList();

    _refreshKey.currentState!.controller.finishRefresh();
  }

  /// [Result]
  /// 获取游览历史
  Future _getTourRecordList() async {
    try {
      if (tourRecordStatus.load!) return;

      StorageData viewedData = await storage.get("viewed");
      int skip = 1;
      int limit = 3;

      Map viewed = viewedData.value ?? {};
      List<TourRecordPlayerBaseData>? viewedWidgets = [];

      setState(() {
        tourRecordStatus.list!.clear();
        tourRecordStatus.load = true;
      });

      List dbIds = [];
      int start = (skip - 1) * limit;
      int end = (skip * limit) <= viewed.length ? skip * limit : viewed.length;
      viewed.entries.toList().sort((a, b) => a.value > b.value ? 1 : -1);
      dbIds = viewed.entries.toList().sublist(start, end).map((e) => e.key).toList();

      Response result = await Http.request(
        Config.httpHost["player_batch"],
        parame: {"dbIds": dbIds},
        method: Http.GET,
      );

      dynamic d = result.data;

      if (result.data["success"] == 1) {
        for (var playerItem in d["data"] as List) {
          TourRecordPlayerBaseData tourRecordPlayerBaseData = TourRecordPlayerBaseData();
          tourRecordPlayerBaseData.setData(playerItem);
          viewedWidgets.add(tourRecordPlayerBaseData);
        }
      }

      setState(() {
        tourRecordStatus.list = viewedWidgets;
        tourRecordStatus.load = false;
      });
    } catch (err) {
      setState(() {
        tourRecordStatus.load = false;
      });
    }
  }

  /// [Response]
  /// 获取订阅列表
  Future _getSubscribesList() async {
    if (traceStatus.load == true) return;

    if (mounted)
      setState(() {
        traceStatus.load = true;
      });

    Response result = await HttpToken.request(
      Config.httpHost["user_subscribes"],
      data: traceStatus.parame.toMap,
      method: Http.POST,
    );

    dynamic d = result.data;

    if (result.data["success"] == 1) {
      setState(() {
        traceStatus.list = d["data"] ?? [];
        traceStatus.load = false;
      });

      return;
    }

    if (mounted)
      setState(() {
        traceStatus.load = false;
      });
  }

  /// [Response]
  /// 获取统计数据
  Future _getStatisticsInfo() async {
    if (statistics.load) return;

    if (mounted)
      setState(() {
        statistics.load = true;
      });

    Response result = await Http.request(
      Config.httpHost["statistics"],
      parame: statistics.params!.toMap,
      method: Http.GET,
    );

    if (result.data["success"] == 1) {
      if (mounted)
        setState(() {
          statistics.data?.setData(result.data["data"]);
        });
    }

    if (mounted)
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

  @override
  Widget build(BuildContext context) {
    return Consumer<UserInfoProvider>(
      builder: (context, userData, child) {
        return MediaQuery.removeViewPadding(
          context: context,
          removeTop: true,
          removeBottom: true,
          child: Refresh(
            key: _refreshKey,
            onRefresh: _onRefresh,
            child: ListView(
              children: [
                // 订阅用户
                if (userData.isLogin)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20, left: 15, right: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          FlutterI18n.translate(context, "app.setting.cell.subscribes.title"),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: traceStatus.list!.map((e) {
                                  return GestureDetector(
                                    child: EluiImgComponent(
                                      width: 40,
                                      height: 40,
                                      src: e["avatarLink"],
                                    ),
                                    onTap: () => _urlUtil.opEnPage(context, "/player/personaId/${e["originPersonaId"]}"),
                                  );
                                }).toList(),
                              ),
                            ),
                            IconButton.outlined(
                              onPressed: () => _urlUtil.opEnPage(context, "/account/subscribes/"),
                              icon: Icon(
                                Icons.more_horiz,
                                size: FontSize.xxLarge.value,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                // 游览记录
                Container(
                  margin: const EdgeInsets.only(bottom: 20, left: 15, right: 15),
                  child: Text(
                    FlutterI18n.translate(context, "app.setting.cell.history.title"),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                GestureDetector(
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 20, left: 15, right: 15),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  FlutterI18n.translate(context, "app.setting.cell.history.describe"),
                                  style: Theme.of(context).listTileTheme.subtitleTextStyle,
                                )
                              ],
                            ),
                          ),
                        ),
                        Row(
                          children: tourRecordStatus.list!.isNotEmpty
                              ? tourRecordStatus.list!
                                  .asMap()
                                  .entries
                                  .map<Widget>((e) => Opacity(
                                        opacity: 1 - (.4 * e.key),
                                        child: ExtendedImage.network(
                                          e.value.avatarLink.toString(),
                                          width: 70,
                                          height: 70,
                                          fit: BoxFit.contain,
                                          cache: true,
                                          clearMemoryCacheWhenDispose: true,
                                          printError: false,
                                          cacheHeight: 50,
                                          cacheWidth: 50,
                                        ),
                                      ))
                                  .toList()
                              : [
                                  Opacity(
                                    opacity: .2,
                                    child: ExtendedImage.asset(
                                      "assets/images/default-player-avatar.jpg",
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.contain,
                                      clearMemoryCacheWhenDispose: true,
                                      cacheHeight: 70,
                                      cacheWidth: 70,
                                    ),
                                  )
                                ],
                        ),
                      ],
                    ),
                  ),
                  onTap: () => _urlUtil.opEnPage(context, "/account/history/"),
                ),

                // 统计
                Container(
                  margin: const EdgeInsets.only(bottom: 20, left: 15, right: 15),
                  child: Text(
                    FlutterI18n.translate(context, "header.site_stats"),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
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
                                          LoadingWidget(
                                            color: Theme.of(context).progressIndicatorTheme.color!,
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
                                          LoadingWidget(
                                            color: Theme.of(context).progressIndicatorTheme.color!,
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
                          opacity: userData.isLogin ? 1 : .3,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.front_hand),
                              label: Text(FlutterI18n.translate(context, "report.title")),
                              onPressed: () => userData.isLogin ? _openReply() : null,
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
                              LoadingWidget(
                                color: Theme.of(context).progressIndicatorTheme.color!,
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
                              LoadingWidget(
                                color: Theme.of(context).progressIndicatorTheme.color!,
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
                              LoadingWidget(
                                color: Theme.of(context).progressIndicatorTheme.color!,
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
            ),
          ),
        );
      },
    );
  }
}
