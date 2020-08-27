/// 新闻
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bfban/widgets/news/index.dart';
import 'package:bfban/constants/theme.dart';
import 'package:bfban/utils/index.dart';

class newsPage extends StatefulWidget {
  @override
  _newsPageState createState() => _newsPageState();
}

class _newsPageState extends State<newsPage> {
  Map theme = THEMELIST['none'];

  final Completer<WebViewController> _controller = Completer<WebViewController>();

  String webviewSrc = "https://app.bfban.com/public/www/news-app.html";

  @override
  void initState() {
    super.initState();
    this.onReadyTheme();
  }

  void onReadyTheme() async {
    /// 初始主题
    Map _theme = await ThemeUtil().ready(context);
    setState(() => theme = _theme);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text("\u5e94\u7528\u65b0\u95fb"),
        actions: <Widget>[
          NavigationControls(_controller.future),
        ],
        flexibleSpace: theme['appBar']['flexibleSpace'],
      ),
      body: SafeArea(
        top: true,
        child: newscomponent(
          src: webviewSrc,
          controller: _controller,
        ),
      ),
    );
  }
}
