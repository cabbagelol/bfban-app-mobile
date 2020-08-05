/// 新闻
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:bfban/widgets/news/index.dart';

class newsPage extends StatefulWidget {
  @override
  _newsPageState createState() => _newsPageState();
}

class _newsPageState extends State<newsPage> {
  final Completer<WebViewController> _controller = Completer<WebViewController>();

  String webviewSrc = "https://app.bfban.com/public/www/news-app.html";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text("应用新闻"),
        actions: <Widget>[
          NavigationControls(_controller.future),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomRight,
              colors: [Colors.transparent, Colors.black38],
            ),
          ),
        ),
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
