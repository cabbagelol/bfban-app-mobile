/// 摄像

import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'package:bfban/constants/api.dart';

import '../../utils/camera.dart';
import '../../utils/url.dart';
import '../../widgets/drawer.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final UrlUtil _urlUtil = UrlUtil();

  dynamic firstCamera;

  late CameraController _controller;

  /// 扫码结果
  List _scanResult = [
    // {"type_index": 0, "type": "web_site_link", "content": "1004766466591"},
    // {"type_index": 1, "type": "app_palyer_link", "content": "1004766466591"},
    // {"type_index": 2, "type": "text", "content": "1004766466591"}
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// [Event]
  /// 启动内容
  void openLink(data) {
    switch (data["type"]) {
      case "web_site_link":
        // 外部链接
        _urlUtil.onPeUrl(Config.apiHost["app_web_site"] + "/player/" + data["content"]);
        break;
      case "app_palyer_link":
        // 内部玩家链接
        _urlUtil.opEnPage(context, "/detail/player/${data["content"]}");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}