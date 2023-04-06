import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart' as htmlparser;

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

  @override
  Widget build(BuildContext context) {
    return Html(
      data: widget.data,
      style: widget.style ?? _detailApi.styleHtml(context),
      customRenders: _detailApi.customRenders(context),
    );
  }
}
