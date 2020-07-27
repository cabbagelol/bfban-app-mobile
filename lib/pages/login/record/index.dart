/// 用户空间

import 'dart:convert';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

import 'package:bfban/router/router.dart';
import 'package:bfban/utils/index.dart';
import 'package:bfban/constants/api.dart';
import 'package:bfban/widgets/index.dart';

import 'package:flutter_plugin_elui/elui.dart';

class recordPage extends StatefulWidget {
  final data;

  recordPage({
    @required this.data,
  });

  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<recordPage> {
  ScrollController _scrollController = ScrollController();

  var indexDate = new Map();

  Map record = {
    "uid": ""
  };

  int indexPagesIndex = 1;

  bool indexPagesState = true;

  List indexDataList = new List();

  @override
  void initState() {
    super.initState();

    this.ready();

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
    await this._getUserInfo();
    this._getIndexList(1);
  }

  /// 下拉刷新方法,为list重新赋值
  Future<Null> _onRefresh() async {
    await Future.delayed(Duration(seconds: 1), () {
      this._getIndexList(1);
    });
  }

  /// 获取用户信息
  void _getUserInfo() async {
    dynamic result = await Storage.get('com.bfban.login');
    dynamic data;

    if (result == null) {
      return;
    }

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
  void _getIndexList(num index) async {
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
      backgroundColor: Color(0xff111b2b),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
      ),
      body: indexDataList.length > 0 ? RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: indexDataList.length,
          itemBuilder: (BuildContext context, int index) {
            return recordItem(
              item: indexDataList[index],
            );
          },
        ),
      ) : Center(
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
            Text(
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

  recordItem({
    this.item,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Routes.router.navigateTo(
          context,
          '/detail/cheaters/${item["originUserId"]}',
          transition: TransitionType.fadeIn,
        );
      },
      child: Container(
        color: Color.fromRGBO(0, 0, 0, .3),
        margin: EdgeInsets.only(bottom: 1),
        padding: EdgeInsets.all(20),
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
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            "游戏类型: ${item["game"].toString()}" ?? "",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            " 状态: ${Config.startusIng[int.parse(item["status"])]["s"]}" ?? "",
                            style: TextStyle(
                              color: Colors.white,
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
                    color: Color.fromRGBO(255, 255, 255, .6),
                    fontSize: 12,
                  ),
                ),
                Text(
                  "${item["createDatetime"]}",
                  style: TextStyle(
                    color: Color.fromRGBO(255, 255, 255, .6),
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
