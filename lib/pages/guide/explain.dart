/// 说明
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:bfban/widgets/news/index.dart';

import '../../constants/api.dart';

class GuideExplainPage extends StatefulWidget {
  const GuideExplainPage({Key? key}) : super(key: key);

  @override
  _explainPageState createState() => _explainPageState();
}

class _explainPageState extends State<GuideExplainPage> {
  final Completer<WebViewController> _controller = Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: NewsComponentPanel(
        src: Config.apiHost["web_site"] + "/news-app.html",
        controller: _controller,
      ),
    );
  }
}
