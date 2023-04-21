import 'dart:convert';

import 'package:bfban/component/_Time/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/_input/index.dart';
import 'package:flutter_elui_plugin/elui.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../../utils/index.dart';
import '../_html/htmlWidget.dart';
import 'customReply.dart';

class CustomReplyEditPage extends StatefulWidget {
  bool isEdit;
  dynamic data;

  CustomReplyEditPage({
    Key? key,
    this.isEdit = false,
    this.data,
  }) : super(key: key);

  @override
  State<CustomReplyEditPage> createState() => _CustomReplyEditPageState();
}

class _CustomReplyEditPageState extends State<CustomReplyEditPage> {
  final UrlUtil _urlUtil = UrlUtil();

  final Storage storage = Storage();

  CustomReplyItem data = CustomReplyItem(
    title: "",
    content: "",
    template: false,
    updateTime: 0,
    creationTime: 0,
    language: "",
  );

  @override
  void initState() {
    if (widget.data != null) {
      _initialEditTemplate();
      // data.mapAsObject = jsonDecode(widget.data!);
    }
    super.initState();
  }

  /// [Event]
  /// 编辑模式: 初始内容
  void _initialEditTemplate() async {
    StorageData customReplyData = await storage.get("customReply");
    List array = customReplyData.value;
    CustomReplyItem item = CustomReplyItem();

    if (widget.data == null) return;
    item.mapAsObject = array.where(( i) => i.title == widget.data["id"]).last;

    setState(() {
      data = item;
    });
  }

  /// [Event]
  /// 添加模板
  void _addTemplate() async {
    dynamic p = ProviderUtil().ofLang(context);
    List languageFrom = await p.getLangFrom();

    // 从bfban-app网站配置清单中换取与bfban网站一致的lang语言
    data.language = languageFrom.where((i) => i["fileName"] == p.currentLang).last["name"];

    if (data.title!.isEmpty || data.content!.isEmpty) {
      EluiMessageComponent.error(context)(child: Text("error"));
      return;
    }

    // 编辑
    if (widget.isEdit) {}

    // 添加
    if (!widget.isEdit) {
      StorageData customReplyData = await storage.get("customReply");
      List customReplyList = customReplyData.value;
      List list = customReplyList.where((i) => i.template == true).toList();

      /// 转义JSON格式，对齐bfban导出导入格式统一
      list.add(data.objectAsMap);
      storage.set("customReply", value: list);

      EluiMessageComponent.success(context)(child: const Text("Success"));
      Navigator.pop(context);
    }
  }

  /// [Event]
  /// 编辑模板
  void _editTemplate() {}

  /// [Event]
  /// 确认模板
  void _done() async {
    widget.isEdit ? _addTemplate() : _editTemplate();
  }

  /// [Event]
  /// 打开编辑Widget(富文本)
  _opEnRichEdit() async {
    await Storage().set("richedit", value: data.content);

    _urlUtil.opEnPage(context, "/richedit").then((data) {
      /// 按下确认储存富文本编写的内容
      if (data["code"] == 1) {
        setState(() {
          this.data.content = data["html"];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => _done(),
            icon: const Icon(Icons.done),
          ),
        ],
      ),
      body: ListView(
        children: [
          /// 标题
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
            child: EluiInputComponent(
              internalstyle: true,
              theme: EluiInputTheme(textStyle: Theme.of(context).textTheme.bodyMedium),
              title: "Title",
              placeholder: "Template Title",
              onChange: (data) {
                setState(() {
                  this.data.title = data["value"];
                });
              },
            ),
          ),

          /// 内容
          EluiCellComponent(
            title: FlutterI18n.translate(context, "report.labels.description"),
            cont: true
                ? const Icon(
                    Icons.warning,
                    color: Colors.yellow,
                    size: 15,
                  )
                : null,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            child: Card(
              clipBehavior: Clip.hardEdge,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
                side: BorderSide(
                  color: Theme.of(context).dividerTheme.color!,
                  width: 1,
                ),
              ),
              child: Container(
                color: Colors.white38,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minHeight: 100,
                  maxHeight: 180,
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Html(data: data.content),
                    Positioned(
                      top: 0,
                      left: 0,
                      bottom: 0,
                      right: 0,
                      child: Container(
                        color: const Color.fromRGBO(0, 0, 0, 0.2),
                        child: Center(
                          child: TextButton.icon(
                            icon: const Icon(Icons.edit),
                            label: const Text(
                              "Edit",
                              style: TextStyle(fontSize: 18),
                            ),
                            onPressed: () => _opEnRichEdit(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
