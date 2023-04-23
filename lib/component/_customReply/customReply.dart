import 'dart:convert';

import 'package:bfban/component/_html/htmlWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../../router/router.dart';
import '../../utils/index.dart';
import '../_empty/index.dart';
import 'customReplyList.dart';

class CustomReplyWidget extends StatefulWidget {
  Function? onChange;

  CustomReplyWidget({
    Key? key,
    this.onChange,
  }) : super(key: key);

  @override
  State<CustomReplyWidget> createState() => _customReplyWidgetState();
}

class _customReplyWidgetState extends State<CustomReplyWidget> {
  final UrlUtil _urlUtil = UrlUtil();

  final Storage storage = Storage();

  List<CustomReplyItem> list = [];

  List<CustomReplyItem> useTemplates = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _upTemplateData();
    super.didChangeDependencies();
  }

  /// [Event]
  /// 使用模板转字符串
  String useTemplatesAsString() {
    String tmpContent = "";
    for (var element in useTemplates) {
      tmpContent = "$tmpContent${element.content!},";
    }
    return tmpContent;
  }

  /// [Event]
  /// 获取模板
  void _upTemplateData() async {
    StorageData customReplyData = await storage.get("customReply");
    List localReplyList = customReplyData.value ?? [];
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
    localReplyList.forEach((i) {
      CustomReplyItem item = CustomReplyItem();
      item.mapAsObject = i;
      list.add(item);
    });
    setState(() {});
  }

  /// [Event]
  /// 复选
  void onCheckboxTemp(CustomReplyItem i) {
    setState(() {
      bool t = useTemplates.where((element) => element.title == i.title).isNotEmpty;
      t ? useTemplates.remove(i) : useTemplates.add(i);
      if (widget.onChange != null) widget.onChange!(useTemplatesAsString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 2),
        if (list.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 10),
            child: Wrap(
              runSpacing: 5,
              spacing: 5,
              children: list.map((i) {
                return InkWell(
                  child: Container(
                    constraints: const BoxConstraints(
                      maxWidth: 165,
                      minWidth: 80,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                          value: useTemplates.where((element) => element.title == i.title).isNotEmpty,
                          onChanged: (checkbox) => onCheckboxTemp(i),
                        ),
                        HtmlWidget(content: i.content),
                      ],
                    ),
                  ),
                  onTap: () {
                    onCheckboxTemp(i);
                  },
                );
              }).toList(),
            ),
          )
        else
          const EmptyWidget(),
        const Divider(height: 1),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              const Expanded(flex: 1, child: SizedBox()),
              IconButton(
                onPressed: () {
                  _urlUtil.opEnPage(context, "/report/customReply/page").then((value) {
                    _upTemplateData();
                  });
                },
                icon: const Icon(
                  Icons.settings,
                  size: 16,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class CustomReplyItem {
  String? title;
  String? content;
  bool? template;
  int? updateTime;
  int? creationTime;
  String? language;

  CustomReplyItem({
    this.title = "",
    this.content = "",
    this.template = false,
    this.updateTime = 0,
    this.creationTime = 0,
    this.language = "",
  });

  Map get objectAsMap => {
        "title": title,
        "content": content,
        "template": template,
        "updateTime": updateTime,
        "creationTime": creationTime,
        "language": language,
      };

  set mapAsObject(Map data) {
    if (data["title"] != null) title = data["title"];
    if (data["content"] != null) content = data["content"];
    if (data["template"] != null) template = data["template"];
    if (data["updateTime"] != null) updateTime = data["updateTime"];
    if (data["creationTime"] != null) creationTime = data["creationTime"];
    if (data["language"] != null) language = data["language"];
  }
}
