/// 草稿箱

import 'dart:convert';

import 'package:bfban/utils/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_plugin_elui/elui.dart';

class draftsPage extends StatefulWidget {
  final data;

  draftsPage({
    this.data,
  });

  @override
  _draftsPageState createState() => _draftsPageState();
}

class _draftsPageState extends State<draftsPage> {
  List draftsList = new List();

  @override
  void initState() {
    super.initState();
    this.ready();
  }

  ready() async {
    var _value = await Storage.get("drafts");
    setState(() {
      draftsList = jsonDecode(_value);
    });
  }

  /// 删除
  void _deleDrafts(index) async {
    List _drafts = jsonDecode(await Storage.get("drafts"));

    /// 移除重复
    _drafts.removeAt(index);

    await Storage.set("drafts", value: jsonEncode(_drafts ?? []));

    setState(() {
      draftsList = _drafts;
    });
  }

  /// 选中
  void _onSelect(index) {
    Navigator.pop(context, draftsList[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xff111b2b),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: Text(
            "草稿箱",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          actions: <Widget>[],
        ),
        body: ListView(
          children: draftsList.length > 0
              ? (draftsList ?? []).asMap().keys.map((index) {
                  return GestureDetector(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(
                            width: 10,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      padding: EdgeInsets.only(
                        top: 10,
                        right: 20,
                        left: 20,
                        bottom: 10,
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  draftsList[index]["originId"]??"-",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 25,
                                  ),
                                ),
                                Text(
                                  "创建时间: ${draftsList[index]["date"]}",
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.black12,
                              size: 30,
                            ),
                            onPressed: () {
                              this._deleDrafts(index);
                            },
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      this._onSelect(index);
                    },
                  );
                }).toList()
              : [
                  EluiVacancyComponent(
                    height: 300,
                    title: "草稿箱没有保存任何东西",
                  ),
                ],
        ),
      ),
    );
  }
}
