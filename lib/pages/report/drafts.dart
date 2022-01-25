/// 草稿箱

import 'dart:convert';

import 'package:bfban/utils/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/elui.dart';

class draftsPage extends StatefulWidget {
  final data;

  const draftsPage({Key? key,
    this.data,
  }) : super(key: key);

  @override
  _draftsPageState createState() => _draftsPageState();
}

class _draftsPageState extends State<draftsPage> {
  List draftsList = [];

  @override
  void initState() {
    super.initState();
    ready();
  }

  ready() async {
    var _value = await Storage().get("drafts");
    setState(() {
      draftsList = jsonDecode(_value);
    });
  }

  /// 删除
  void _deleDrafts(index) async {
    List _drafts = jsonDecode(await Storage().get("drafts"));

    /// 移除重复
    _drafts.removeAt(index);

    await Storage().set("drafts", value: jsonEncode(_drafts));

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
      decoration: const BoxDecoration(
        color: Color(0xff111b2b),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "草稿箱",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          actions: const <Widget>[],
        ),
        body: ListView(
          children: draftsList.isNotEmpty
              ? (draftsList).asMap().keys.map((index) {
                  return GestureDetector(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(
                            width: 10,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.only(
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
                                  draftsList[index]["originId"] ?? "-",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 25,
                                  ),
                                ),
                                Text(
                                  "创建时间: ${draftsList[index]["date"]}",
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.black12,
                              size: 30,
                            ),
                            onPressed: () {
                              _deleDrafts(index);
                            },
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      _onSelect(index);
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
