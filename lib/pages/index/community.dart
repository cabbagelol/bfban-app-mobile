/// 社区

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:fluro/fluro.dart';
import 'package:flutter_plugin_elui/elui.dart';
import 'package:provider/provider.dart';

import 'package:bfban/router/router.dart';
import 'package:bfban/constants/api.dart';
import 'package:bfban/constants/theme.dart';
import 'package:bfban/utils/index.dart';

class communityPage extends StatefulWidget {
  @override
  _communityPageState createState() => _communityPageState();
}

class _communityPageState extends State<communityPage> {
  Map theme = THEMELIST['none'];

  /// 近期消息
  Map indexActivity = {
    "registers": [],
  };

  Map<String, dynamic> cheatersPost = {
    "game": "bf1",
    "status": 100,
    "sort": "updateDatetime",
    "page": 1,
    "tz": "Asia%2FShanghai",
    "limit": 40,
  };

  @override
  void initState() {
    super.initState();

    this._getActivity();
    this.onReadyTheme();
  }

  void onReadyTheme() async {
    /// 初始主题
    Map _theme = await ThemeUtil().ready(context);
    setState(() => theme = _theme);
  }

  /// 获取近期活动
  void _getActivity() async {
    Response result = await Http.request(
      'api/activity',
      parame: cheatersPost,
      method: Http.GET,
    );

    if (result.data["error"] == 0) {
      setState(() {
        indexActivity = result.data["data"];
      });

      this._onMerge();
    }
  }

  /// 整理活动
  List _onMerge() {
    Function _getTurnTheTimestamp = new Date().getTurnTheTimestamp;
    List list = new List();

    list.addAll(indexActivity["registers"] ?? []);
    list.addAll(indexActivity["reports"] ?? []);
    list.addAll(indexActivity["verifies"] ?? []);

    list.sort((time, timeing) =>
        _getTurnTheTimestamp(timeing["createDatetime"])["millisecondsSinceEpoch"] -
        _getTurnTheTimestamp(time["createDatetime"])["millisecondsSinceEpoch"]);

    return list;
  }

  /// 打开社区动态详情内容i
  /// 区分类型
  void _opEnDynamicDetail(i) {
    if (i["originUserId"] != null) {
      Routes.router.navigateTo(
        context,
        '/detail/cheaters/${i["originUserId"]}',
        transition: TransitionType.cupertino,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,

        /// 最近动态
        title: Text("\u6700\u8fd1\u52a8\u6001"),
        flexibleSpace: theme['appBar']['flexibleSpace'],
      ),
      body: ListView(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(
              left: 10,
              right: 10,
            ),
            padding: EdgeInsets.only(
              top: 10,
              bottom: 10,
              left: 10,
              right: 10,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor ?? theme['index_community']['statisticsBackground'] ?? Colors.black12,
              border: Border.all(
                width: 1,
                color: Theme.of(context).cardColor ?? theme['index_community']['statisticsBackground'] ?? Colors.black12,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      Text(
                        "${indexActivity["number"] == null ? "" : indexActivity["number"]["cheater"]}",
                        style: TextStyle(
                          color: Theme.of(context).primaryTextTheme.headline1.color ??
                              theme['index_community']['statisticsText'] ??
                              Colors.white,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        "\u5df2\u6838\u5b9e\u4f5c\u5f0a\u73a9\u5bb6\u4eba\u6570",
                        style: TextStyle(
                          color: Theme.of(context).primaryTextTheme.headline3.color ??
                              theme['index_community']['statisticsTextSubtitle'] ??
                              Colors.white54,
                          fontSize: 12,
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    left: 7,
                    right: 7,
                  ),
                  height: 30,
                  width: 1,
                  color: Theme.of(context).dividerColor ?? theme['hr']['secondary'] ?? Colors.white12,
                ),
                Container(
                  child: Column(
                    children: <Widget>[
                      Text(
                        "${indexActivity["number"] == null ? "" : indexActivity["number"]["report"]}",
                        style: TextStyle(
                          color: Theme.of(context).primaryTextTheme.headline1.color ??
                              theme['index_community']['statisticsText'] ??
                              Colors.white,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        "\u793e\u533a\u5df2\u6536\u5230\u4e3e\u62a5\u6b21\u6570",
                        style: TextStyle(
                          color: Theme.of(context).primaryTextTheme.headline3.color ??
                              theme['index_community']['statisticsTextSubtitle'] ??
                              Colors.white54,
                          fontSize: 12,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            height: 20,
          ),

          /// 动态
          _onMerge().length > 0
              ? Column(
                  children: _onMerge().map<Widget>((i) {
                    return GestureDetector(
                      child: Container(
                        color: Theme.of(context).cardColor ?? theme['index_community']['card']['backgroundColor'] ?? Color(0xff111b2b),
                        padding: EdgeInsets.only(
                          top: 20,
                          bottom: 20,
                          left: 20,
                          right: 20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.deepOrange,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(100),
                                    ),
                                  ),
                                  width: 20,
                                  height: 20,
                                  child: Center(
                                    child: Icon(
                                      Icons.speaker_notes,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  "动态:",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).primaryTextTheme.headline1.color ??
                                        theme['index_community']['card']['subtitle1'] ??
                                        Colors.white,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    new Date().getTimestampTransferCharacter(i["createDatetime"])["Y_D_M"],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).primaryTextTheme.headline1.color ??
                                          theme['index_community']['card']['subtitle1'] ??
                                          Colors.white,
                                    ),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "${i["username"].toString()}",
                                    style: TextStyle(
                                      color: Theme.of(context).primaryTextTheme.headline1.color ??
                                          theme['index_community']['card']['subtitle1'] ??
                                          Colors.white,
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                WidgetStateText(
                                  i: i,
                                  theme: theme,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      onTap: () => _opEnDynamicDetail(i),
                    );
                  }).toList(),
                )
              : Center(
                  child: EluiVacancyComponent(
                    title: "\u6700\u8fd1\u6ca1\u6709\u7f51\u7ad9\u52a8\u6001",
                  ),
                ),
        ],
      ),
    );
  }
}

/// 动态类型
class WidgetStateText extends StatelessWidget {
  final Map i;
  final Map theme;

  WidgetStateText({
    this.theme,
    this.i,
  });

  @override
  Widget build(BuildContext context) {
    if (i["cheaterOriginId"] == null) {
      return Text(
        "注册了BFBAN，欢迎",
        style: TextStyle(
          color: Theme.of(context).primaryTextTheme.headline3.color ?? theme['index_community']['card']['rightsubtitle'] ?? Colors.white54,
          fontSize: 12,
        ),
      );
    } else if (i["status"] != null) {
      return Wrap(
        children: <Widget>[
          Text(
            /// 将xx处理为
            "\u5c06${i["cheaterOriginId"]}\u5904\u7406\u4e3a",
            style: TextStyle(
              color: Theme.of(context).primaryTextTheme.headline3.color ?? theme['index_community']['card']['rightsubtitle'] ?? Colors.white54,
              fontSize: 12,
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              left: 5,
              right: 5,
            ),
            decoration: BoxDecoration(
              color: Config.startusIng[int.parse(i["status"])]["c"],
              borderRadius: BorderRadius.all(
                Radius.circular(2),
              ),
            ),
            child: Text(
              Config.startusIng[int.parse(i["status"])]["s"].toString(),
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    } else {
      return Text(
        /// 举报了
        " \u4e3e\u62a5\u4e86 ${i["cheaterOriginId"]} ${i["game"]}",
        style: TextStyle(
          color: Theme.of(context).primaryTextTheme.headline3.color ?? theme['index_community']['card']['rightsubtitle'] ?? Colors.white54,
          fontSize: 12,
        ),
      );
    }
  }
}
