/// 搜索

import 'dart:convert';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:bfban/utils/index.dart';
import 'package:bfban/router/router.dart';

import 'package:flutter_plugin_elui/_cell/cell.dart';
import 'package:flutter_plugin_elui/_vacancy/index.dart';

class SearchPage extends StatefulWidget {
  final data;

  SearchPage({
    this.data,
  });

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  /// 搜索值
  String value = "";

  /// 搜索列表
  List searchList = new List();

  @override
  void initState() {
    super.initState();

    setState(() {
      /// 序列化
      value = jsonDecode(widget.data)["id"];
    });

    this._onSearch();
  }

  /// 账户搜索
  void _onSearch() async {
    if (value == "") {
      return;
    }

    Response result = await Http.request(
      "api/search",
      method: Http.GET,
      parame: {
        "id": value,
      },
    );

    if (result.data["error"] == 0) {
      setState(() {
        searchList = result.data["data"]["cheaters"];

        print(searchList);
      });
    }
  }

  /// 打开详情
  void _onPenDetail (Map item) {
    Routes.router.navigateTo(
      context,
      '/detail/cheaters/${item["originUserId"]}',
      transition: TransitionType.cupertino,
    );
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Color(0xff111b2b),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Color(0xff364e80),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "搜索",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              left: 20,
              top: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: 50,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "已列出符合检索关键词的ID",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              top: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: searchList.length > 0 ? searchList.map((i) {
                return EluiCellComponent(
                  theme: EluiCellTheme(
                    backgroundColor: Colors.black12,
                  ),
                  title: i["originId"].toString(),
                  islink: true,
                  onTap: () {
                    this._onPenDetail(i);
                  },
                );
              }).toList() : [
                EluiVacancyComponent(
                  height: 300,
                  title: "没有检索到结果",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
