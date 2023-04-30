import 'package:bfban/component/_html/htmlWidget.dart';
import 'package:bfban/utils/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class HtmlCore extends StatefulWidget {
  String? data;
  Map<String, Style>? style = {};

  HtmlCore({
    Key? key,
    this.data,
    this.style,
  }) : super(key: key);

  @override
  State<HtmlCore> createState() => _HtmlCoreState();
}

class _HtmlCoreState extends State<HtmlCore> {
  final CardUtil _detailApi = CardUtil();

  final Regular _regular = Regular();

  String renderView = "";

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((Duration time) {
      packagingRender(context);
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  /// [Event]
  /// 包装器
  void packagingRender(context) {
    String vDom = "<div>${widget.data ?? ""}</div>";
    if (widget.data!.isEmpty) return;

    // p
    Iterable<RegExpMatch> p = _regular.getCheckText(RegularType.P, widget.data);

    for (var i in p) {
      Iterable<RegExpMatch> abbreviations = RegExp(r'{(\S*)}').allMatches(i.group(0)!);

      // p child -> links
      // 可疑链接
      // 将可疑的文本链接转换为链接widget
      for (var p_child_link_item in _regular.getCheckText(RegularType.Link, i.group(0))) {
        RegExpMatch _p_child_link_item = p_child_link_item;
        String text = p_child_link_item.group(0);
        String textL = vDom[_p_child_link_item.start - 4] != null ? vDom.substring(_p_child_link_item.start - 4, _p_child_link_item.start) : "";

        if (textL.indexOf("img") < 0 && !textL.contains("=\"") && !textL.contains("src=") && !textL.contains("href=")) {
          vDom = vDom.replaceFirst(text, "<a href=$text>$text</a>");
        }
      }

      // p child -> hrs
      if (i.group(0).toString().contains("----")) {
        vDom = vDom.replaceFirst("<p>----</p>", "<app-hr></app-hr>");
      }

      for (var abbreviationItem in abbreviations) {
        List split = abbreviationItem.input.substring(abbreviationItem.start + 1, abbreviationItem.end - 1).split(":");
        String commend = split[0];
        String value = split[1];

        switch (commend) {
          case "icon":
            vDom = vDom.replaceAll(RegExp(abbreviationItem.group(0).toString()), "<app-icon icon=$value></app-icon>");
            break;
          case "player":
            vDom = vDom.replaceAll(RegExp(abbreviationItem.group(0).toString()), "<app-player id=$value lang=zh-CN></app-player>");
            break;
          case "user":
            vDom = vDom.replaceAll(RegExp(abbreviationItem.group(0).toString()), "<app-user id=$value></app-user>");
            break;
          case "floor":
            vDom = vDom.replaceAll(RegExp(abbreviationItem.group(0).toString()), "<app-floor id=$value></app-floor>");
            break;
        }
      }
    }

    setState(() {
      renderView = vDom.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Html(
      data: renderView,
      style: widget.style ?? _detailApi.styleHtml(context),
      customRenders: _detailApi.customRenders(context),
      tagsList: Html.tags..addAll(["app-icon", "app-player", "app-user", "app-floor", "app-hr"]),
    );
  }
}
