/// 用户空间

import 'dart:convert';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

import 'package:bfban/router/router.dart';
import 'package:bfban/utils/index.dart';
import 'package:bfban/constants/api.dart';
import 'package:bfban/widgets/index.dart';
import 'package:bfban/constants/theme.dart';

import 'package:flutter_elui_plugin/elui.dart';

class recordPage extends StatefulWidget {
  final data;

  recordPage({Key? key,
    @required this.data,
  }) : super(key: key);

  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<recordPage> {
  Map theme = THEMELIST['none'];

  final ScrollController _scrollController = ScrollController();

  Map indexDate = {};

  Map record = {"uid": ""};

  int indexPagesIndex = 1;

  bool indexPagesState = true;

  /// 列表
  List indexDataList = [];

  @override
  void initState() {
    super.initState();

    ready();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {}
    });
  }

  @override
  void dispose() {
    super.dispose();

    _scrollController.dispose();
  }

  void ready() async {
    await _getUserInfo();
    await _getIndexList(1);
  }

  /// 下拉刷新方法,为list重新赋值
  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 1), () {
      _getIndexList(1);
    });
  }

  /// 获取用户信息
  Future _getUserInfo() async {
    dynamic result = await Storage().get('com.bfban.login');
    dynamic data;

    switch (widget.data.toString()) {
      case "-1":
        data = jsonDecode(result)["uId"];
        break;
      default:
        data = widget.data;
        break;
    }

    setState(() {
      record["uid"] = data;
    });
  }

  /// 获取列表
  Future _getIndexList(num index) async {
    if (record["uid"] == null || record["uid"] == "") {
      return;
    }

    Response result = await Http.request(
      'api/account/${record["uid"]}',
      method: Http.GET,
    );

    setState(() {
      indexPagesState = true;
    });

    if (result.data["error"] == 0) {
      setState(() {
        indexDate = result.data;
        if (index > 1) {
          result.data["data"]["reports"].forEach((i) {
            indexDataList.add(i);
          });
        } else {
          indexDataList = result.data["data"]["reports"];
        }
      });
    }

    setState(() {
      indexPagesState = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.open_in_new,
            ),
            onPressed: () {
              Share().text(
                title: '联BFBAN分享',
                text: '这是我的举报记录，来看看我举报了那些人~',
                linkUrl: 'https://bfban.com/#/account/${record["uid"]}',
                chooserTitle: '联BFBAN分享',
              );
            },
          ),
        ],
      ),
      body: !indexPagesState
          ? indexDataList.isNotEmpty
              ? RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: indexDataList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return recordItem(
                        theme: theme,
                        item: indexDataList[index],
                      );
                    },
                  ),
                )
              : EluiVacancyComponent(
                  title: "没有其他数据了:D",
                )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Opacity(
                    opacity: 0.8,
                    child: textLoad(
                      value: "BFBAN",
                      fontSize: 30,
                    ),
                  ),
                  const Text(
                    "Legion of BAN Coalition",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white38,
                    ),
                  )
                ],
              ),
            ),
    );
  }
}

/// 记录卡片
class recordItem extends StatelessWidget {
  final item;
  final Map theme;

  recordItem({Key? key,
    this.item,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Routes.router!.navigateTo(
          context,
          '/detail/cheaters/${item["originUserId"]}',
          transition: TransitionType.fadeIn,
        );
      },
      child: Container(
        color: theme['card']['color'] ?? const Color.fromRGBO(0, 0, 0, .3),
        margin: const EdgeInsets.only(bottom: 1),
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    item["originId"] ?? "",
                    style: TextStyle(
                      color: theme['text']['subtitle'] ?? Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            "游戏类型: ${item["game"].toString()}",
                            style: TextStyle(
                              color: theme['text']['subtitle'] ?? Colors.white,
                              fontSize: 12,
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            " 状态: ${Config.startusIng[int.parse(item["status"])]["s"]}",
                            style: TextStyle(
                              color: theme['text']['subtitle'] ?? Colors.white,
                              fontSize: 13,
                            ),
                          )
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  "发布日期:",
                  style: TextStyle(
                    color: theme['text']['subtext1'] ?? const Color.fromRGBO(255, 255, 255, .6),
                    fontSize: 12,
                  ),
                ),
                Text(
                  "${item["createDatetime"]}",
                  style: TextStyle(
                    color: theme['text']['subtext1'] ?? const Color.fromRGBO(255, 255, 255, .6),
                    fontSize: 13,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
