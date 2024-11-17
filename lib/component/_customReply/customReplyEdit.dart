import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/elui.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../../utils/index.dart';
import 'customReply.dart';

class CustomReplyEditPage extends StatefulWidget {
  final bool isEdit;

  final dynamic data;

  const CustomReplyEditPage({
    super.key,
    this.isEdit = false,
    this.data,
  });

  @override
  State<CustomReplyEditPage> createState() => _CustomReplyEditPageState();
}

class _CustomReplyEditPageState extends State<CustomReplyEditPage> {
  final UrlUtil _urlUtil = UrlUtil();

  final Storage storage = Storage();

  Map templateData = {};

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
    }
    super.initState();
  }

  /// [Event]
  /// 编辑模式: 初始内容
  void _initialEditTemplate() async {
    StorageData customReplyData = await storage.get("customReply");
    List array = customReplyData.value ?? [];
    CustomReplyItem item = CustomReplyItem();

    if (widget.data == null) return;
    templateData = jsonDecode(widget.data);
    item.mapAsObject = array.where((i) => i["title"] == templateData["id"]).last;

    setState(() {
      data = item;
    });
  }

  /// [Event]
  /// 添加模板
  void _onAddTemplate() async {
    StorageData customReplyData = await storage.get("customReply");
    List customReplyList = customReplyData.value ?? [];
    List list = customReplyList.where((i) => i["template"] == false).toList();

    // 校验是否空
    if (data.title!.isEmpty || data.content!.isEmpty) {
      EluiMessageComponent.error(context)(child: const Text("Not empty"));
      return;
    }

    // 校验是否已有
    if (list.where((i) => i["title"] == data.title).isNotEmpty) {
      EluiMessageComponent.error(context)(child: const Text("Available templates"));
      return;
    }

    /// 当前模板创建时间戳
    data.creationTime = DateTime.now().millisecondsSinceEpoch;

    /// 当前创建模板使用语言
    data.language = ProviderUtil().ofLang(context).currentLang;

    /// 转义JSON格式，对齐bfban导出导入格式统一
    list.add(data.objectAsMap);
    storage.set("customReply", value: list);

    EluiMessageComponent.success(context)(child: const Icon(Icons.done));
    Navigator.pop(context);
  }

  /// [Event]
  /// 编辑模板
  void _onEditTemplate() async {
    StorageData customReplyData = await storage.get("customReply");
    List customReplyList = customReplyData.value ?? [];

    data.mapAsObject = customReplyList.where((i) => i["title"] == templateData["id"]).last; // 继承模板内容
    data.updateTime = DateTime.now().millisecondsSinceEpoch; // 更新时间

    int index = customReplyList.indexWhere((i) => i["title"] == templateData["id"]); // 编辑模板下标
    customReplyList.insert(index, data.objectAsMap); // 新增
    customReplyList.removeAt(index + 1); // 删除原有

    storage.set("customReply", value: customReplyList);

    EluiMessageComponent.success(context)(child: const Icon(Icons.done));
    Navigator.pop(context);
  }

  /// [Event]
  /// 确认模板
  void _done() async {
    widget.isEdit ? _onEditTemplate() : _onAddTemplate();
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
            padding: const EdgeInsets.all(16),
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
              placeholder: "Template Title",
              value: data.title,
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
            cont: const Icon(
              Icons.warning,
              color: Colors.yellow,
              size: 15,
            ),
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
                    Positioned.fill(
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
