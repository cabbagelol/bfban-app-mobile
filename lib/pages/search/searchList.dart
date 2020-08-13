/// 搜索

import 'dart:convert';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:bfban/utils/index.dart';
import 'package:bfban/router/router.dart';
import 'package:bfban/widgets/index.dart';

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
  void _onSearch() async {
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
      backgroundColor: Color(0xff111b2b),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Color(0xff364e80),
        elevation: 0,
        centerTitle: true,
        title: titleSearch(
          controller: _searchController,
          theme: titleSearchTheme.white,
          onSubmitted: (String value) {
            setState(() {
              this.value = value;
            });
            this._onSearch();
          },
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
                                color: Colors.white54,
                                size: 17,
                              ),
                              Text(
                                "搜索历史",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white54,
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
                        children: serachLogList.map((e) {
                          return EluiTagComponent(
                            value: e,
                            isClose: true,
                            theme: EluiTagtheme(
                              backgroundColor: Colors.black12,
                              textColor: Colors.white,
                            ),
                            onTap: () {
                              setState(() {
                                value = e;
                                _searchController.value = TextEditingValue(
                                  text: e,
                                );

                                this._onSearch();
                              });
                            },
                            onClose: () => this._deleSearchLog(e),
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
                      color: Colors.white54,
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
                          backgroundColor: Colors.black12,
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
