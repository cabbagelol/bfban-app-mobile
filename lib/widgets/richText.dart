/// 富文本
/// 组件类型，需要容器承载
/// 实体页面[/eichEdit/index.dart]

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:bfban/component/rich_edit.dart';

import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

/// 富文本视图
class richText extends StatefulWidget {
  final Function onChange;

  final SimpleRichEditController controller;

  richText({
    this.onChange,
    @required this.controller,
  });

  @override
  _richTextState createState() => _richTextState();
}

class _richTextState extends State<richText> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: RichEdit(widget.controller),
    );
  }
}

/// 富文本构建类
class SimpleRichEditController extends RichEditController {
  Map<String, ChewieController> controllers = Map();

  final context;

  final isImageIcon;

  final isVideoIcon;

  SimpleRichEditController({
    this.context,
    this.isImageIcon,
    this.isVideoIcon,
  });

  @override
  Future<String> addVideo() async {
    return null;
  }

  /// 生成视频view方法
  @override
  Widget generateVideoView(RichEditData data) {
    if (!controllers.containsKey(data.data)) {
      var controller = ChewieController(
        videoPlayerController: VideoPlayerController.network(data.data),
        fullScreenByDefault: true,
        autoPlay: false,
        autoInitialize: true,
        aspectRatio: 16 / 9,
        looping: false,
        showControls: true,
        // 占位图
        placeholder: new Container(
          color: Colors.grey,
        ),
      );
      controllers[data.data] = controller;
    }
    return Chewie(
      controller: controllers[data.data],
    );
  }

  /// 生成图片view方法
  @override
  Widget generateImageView(RichEditData data) => Image.network(
        data.data,
      );
}
