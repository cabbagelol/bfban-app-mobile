/// 新闻


import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class newsPage extends StatefulWidget {
  @override
  _newsPageState createState() => _newsPageState();
}

class _newsPageState extends State<newsPage> {
  @override
  Widget build(BuildContext context) {
//    return Container();
    return WebView(
        initialUrl: "https://cabbagelol.github.io/bfbanApp/www/index.html",
    );
  }
}
