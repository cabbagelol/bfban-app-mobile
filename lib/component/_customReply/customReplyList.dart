import 'dart:convert';

import 'package:bfban/component/_Time/index.dart';
import 'package:bfban/component/_empty/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../../utils/index.dart';
import '../_html/htmlWidget.dart';
import 'customReply.dart';

class CustomReplyListPage extends StatefulWidget {
  const CustomReplyListPage({Key? key}) : super(key: key);

  @override
  State<CustomReplyListPage> createState() => _customReplyPageState();
}

class _customReplyPageState extends State<CustomReplyListPage> {
  final UrlUtil _urlUtil = UrlUtil();

  final Storage storage = Storage();

  List<CustomReplyItem> list = [];
  int countMax = 10;

  @override
  void initState() {
    getCustomReplyList();
    super.initState();
  }

  /// [Event]
  /// 获取自定义模板列表
  void getCustomReplyList() async {
    StorageData customReplyData = await storage.get("customReply");
    List localReplyList = customReplyData.value;
    list.clear();
    list.addAll([
      CustomReplyItem(
        title: "stats",
        template: true,
        content: FlutterI18n.translate(context, "detail.info.fastReplies.stats"),
      ),
      CustomReplyItem(
        title: "evidencePic",
        template: true,
        content: FlutterI18n.translate(context, "detail.info.fastReplies.evidencePic"),
      ),
      CustomReplyItem(
        title: "evidenceVid",
        template: true,
        content: FlutterI18n.translate(context, "detail.info.fastReplies.evidenceVid"),
      ),
    ]);

    for (var i in localReplyList) {
      list.add(CustomReplyItem(
        title: i["title"],
        content: i["content"],
        template: i["template"],
        updateTime: i["updateTime"],
        creationTime: i["creationTime"],
        language: i["language"],
      ));
    }
    setState(() {});
  }

  /// [Event]
  /// 编辑
  void _openEditTemplate(CustomReplyItem i) {
    String data = jsonEncode({
      "id": i.title,
    });
    _urlUtil.opEnPage(context, "/report/customReply/edit/$data");
  }

  /// [Event]
  /// 添加
  void _addTemplate() {
    if (list.length >= countMax) return;
    _urlUtil.opEnPage(context, "/report/customReply/add/").then((value) {
      getCustomReplyList();
    });
  }

  /// [Event]
  /// 删除模板
  void _fastReplyDel(i) {
    setState(() {
      list.remove(i);
    });

    /// 转义JSON格式，对齐bfban导出导入格式统一
    List _l = [];
    for (var i in list) {
      _l.add(i.objectAsMap);
    }
    storage.set("customReply", value: _l);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${list.length}/$countMax"),
        actions: [
          IconButton(
            onPressed: () => _addTemplate(),
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        children: list.isNotEmpty
            ? list.map((i) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text.rich(
                              TextSpan(children: [
                                if (i.template!) const WidgetSpan(child: Icon(Icons.text_snippet, size: 18)),
                                TextSpan(
                                  text: i.template! ? "" : "${i.title}\t",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                TextSpan(text: "${i.template! ? "\t${i.content}" : "[${i.language}]"} ${i.template! ? "" : i.creationTime}")
                              ]),
                            ),
                          ),
                          PopupMenuButton(
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 1,
                                enabled: !i.template!,
                                child: const Text("Edit"),
                              ),
                              PopupMenuItem(
                                value: 2,
                                enabled: !i.template!,
                                child: const Text("Dele"),
                              ),
                            ],
                            onSelected: (index) {
                              switch (index) {
                                case 1:
                                  _openEditTemplate(i);
                                  break;
                                case 2:
                                  _fastReplyDel(i);
                                  break;
                              }
                            },
                          ),
                        ],
                      ),
                      HtmlWidget(content: i.content),
                    ],
                  ),
                );
              }).toList()
            : [const EmptyWidget()],
      ),
    );
  }
}
