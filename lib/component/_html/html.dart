import 'package:bfban/utils/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../../widgets/index.dart';

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
    super.initState();
  }

  @override
  void didChangeDependencies() {
    packagingRender(context);
    super.didChangeDependencies();
  }

  /// [Event]
  /// 包装器
  void packagingRender(context) {
    String view = widget.data.toString();
    if (widget.data!.isEmpty) return;

    // links
    Iterable<RegExpMatch> links = _regular.getCheckText(RegularType.Link, widget.data);
    for (var i in links) {
      view = view.replaceRange(i.start, i.end, "<a href='${i.group(0)}'>${i.group(0)}</a>");
    }

    // p
    Iterable<RegExpMatch> p = _regular.getCheckText(RegularType.P, widget.data);

    for (var i in p) {
      Iterable<RegExpMatch> abbreviations = RegExp(r'{(\S*)}').allMatches(i.group(0)!);

      if (i.group(0).toString().contains("----")) {
        view = view.replaceFirst("<p>----</p>", "<app-hr></app-hr>");
      }

      for (var abbreviationItem in abbreviations) {
        List split = abbreviationItem.input.substring(abbreviationItem.start + 1, abbreviationItem.end - 1).split(":");
        String commend = split[0];
        String value = split[1];

        switch (commend) {
          case "icon":
            view = view.replaceAll(RegExp(abbreviationItem.group(0).toString()), "<app-icon icon='$value'></app-icon>");
            break;
          case "player":
            print(FlutterI18n.currentLocale(context)!.languageCode);
            view = view.replaceAll(RegExp(abbreviationItem.group(0).toString()), "<app-player id='$value' lang='zh-CN'></app-player>");
            break;
          case "user":
            view = view.replaceAll(RegExp(abbreviationItem.group(0).toString()), "<app-user id='$value'></app-user>");
            break;
          case "floor":
            view = view.replaceAll(RegExp(abbreviationItem.group(0).toString()), "<app-floor id='$value'></app-floor>");
            break;
        }
      }
    }

    setState(() {
      renderView = view.trim();
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
