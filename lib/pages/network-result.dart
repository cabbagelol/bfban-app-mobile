import 'package:flutter/material.dart';

import 'package:bfban/utils/index.dart';
import 'package:bfban/constants/theme.dart';

class NetworkResultPage extends StatefulWidget {
  final String data;

  NetworkResultPage({this.data});

  @override
  _networkResultPageState createState() => _networkResultPageState();
}

class _networkResultPageState extends State<NetworkResultPage> {
  Map theme = THEMELIST['none'];

  @override
  void initState() {
    this.onReadyTheme();
    super.initState();
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
        centerTitle: true,
        flexibleSpace: theme['appBar']['flexibleSpace'],
      ),
      body: ListView(
        children: [

          Text("233")
        ],
      ),
    );
  }
}
