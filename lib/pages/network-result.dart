import 'package:flutter/material.dart';

import 'package:bfban/utils/index.dart';
import 'package:bfban/constants/theme.dart';

class NetworkResultPage extends StatefulWidget {
  final String? data;

   const NetworkResultPage({Key? key,
    this.data
  }) : super(key: key);

  @override
  _networkResultPageState createState() => _networkResultPageState();
}

class _networkResultPageState extends State<NetworkResultPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        children: const [Text("233")],
      ),
    );
  }
}
