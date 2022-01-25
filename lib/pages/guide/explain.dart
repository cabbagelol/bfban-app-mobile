/// 说明
import 'dart:async';

import 'package:bfban/constants/api.dart';
import 'package:flutter/material.dart';

import 'package:bfban/widgets/news/index.dart';

class explainPage extends StatefulWidget {
  @override
  _explainPageState createState() => _explainPageState();
}

class _explainPageState extends State<explainPage> {
  final Completer<WebViewController> _controller = Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    return newscomponent(
      src: Config.apiHost["web_site"] + "/news-app.html",
      controller: _controller,
    );
  }
}
