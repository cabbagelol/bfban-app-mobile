/// 搜索

import 'dart:convert';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:bfban/utils/index.dart';
import 'package:bfban/router/router.dart';
import 'package:bfban/widgets/index.dart';
import 'package:bfban/constants/theme.dart';

import 'package:provider/provider.dart';
import 'package:flutter_plugin_elui/_cell/cell.dart';
import 'package:flutter_plugin_elui/_tag/tag.dart';
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
  Map theme = THEMELIST['none'];

  TextEditingController _searchController = TextEditingController();

  /// 搜索值
  String value = "";

  /// 搜索列表
  List searchList = new List();

  /// 历史列表
  List serachLogList = new List();

  @override
  void initState() {
    super.initState();

    this._onReady();
    this.onReadyTheme();
  }

  void onReadyTheme() async {
    /// 初始主题
    Map _theme = await ThemeUtil().ready(context);
    setState(() => theme = _theme);
  }

  void _onReady() async {
    List log = jsonDecode(await Storage.get("com.bfban.serachlog") ?? '[]');

    log.sort();

    setState(() {
      /// 序列化
      value = jsonDecode(widget.data)["id"];

      serachLogList = log;
    });

    print(serachLogList);
  }

  /// 账户搜索
  void _onSearch(value) async {
    setState(() {
      this.value = value;
    });

    if (value == "") {
      return;
    }

    this._setSearchLog();

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
  void _onPenDetail(Map item) {
    Routes.router.navigateTo(
      context,
      '/detail/cheaters/${item["originUserId"]}',
      transition: TransitionType.cupertino,
    );
  }

  /// 储存历史
  void _setSearchLog() {
    List list = serachLogList;

    bool isList = false;

    list.forEach((value) {
      if (value == this.value) {
        isList = true;
      }
    });

    if (!isList) {
      if (list.length >= 20) {
        list.removeAt(0);
      }
      list.add(value);
      Storage.set("com.bfban.serachlog", value: jsonEncode(list));
    }
  }

  /// 删除历史
  void _deleSearchLog(String value) {
    List list = serachLogList;

    list.remove(value);

    setState(() {
      serachLogList = list;
    });

    Storage.set("com.bfban.serachlog", value: jsonEncode(list));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: titleSearch(
          controller: _searchController,
          theme: titleSearchTheme.white,
          onSubmitted: (String value) => this._onSearch(value),
        ),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Offstage(
                  offstage: serachLogList.length <= 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Wrap(
                            spacing: 5,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.history,
                                color: theme['text']['subtitle'] ?? Colors.white54,
                                size: 17,
                              ),
                              Text(
                                "搜索历史",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: theme['text']['subtitle'] ?? Colors.white54,
                                ),
                              )
                            ],
                          ),
                          EluiTagComponent(
                            color: EluiTagColor.none,
                            theme: EluiTagtheme(
                              backgroundColor: Colors.yellow,
                            ),
                            size: EluiTagSize.no2,
                            value: "${serachLogList.length}/20",
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Wrap(
                        spacing: 10,
                        runSpacing: 5,
                        children: serachLogList.map((value) {
                          return EluiTagComponent(
                            value: value,
                            isClose: true,
                            theme: EluiTagtheme(
                              backgroundColor: theme['card']['color'],
                              textColor: theme['text']['subtitle'] ?? Colors.white,
                            ),
                            onTap: () {
                              setState(() {
                                _searchController.value = TextEditingValue(
                                  text: value,
                                );

                                this._onSearch(value);
                              });
                            },
                            onClose: () => this._deleSearchLog(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Offstage(
                  offstage: searchList.length <= 0,
                  child: Text(
                    "已列出符合检索关键词的ID",
                    style: TextStyle(
                      fontSize: 15,
                      color: theme['text']['subtitle'] ?? Colors.white54,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              top: 20,
            ),
            child: searchList.length > 0
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: searchList.map((i) {
                      return EluiCellComponent(
                        theme: EluiCellTheme(
                          titleColor: theme['text']['subtitle'],
                          backgroundColor: theme['card']['color'] ?? Colors.black12,
                        ),
                        title: i["originId"].toString(),
                        islink: true,
                        onTap: () {
                          this._onPenDetail(i);
                        },
                      );
                    }).toList(),
                  )
                : EluiVacancyComponent(
                    height: 300,
                    title: "没有检索到结果",
                  ),
          ),
        ],
      ),
    );
  }
}
