/// 富文本
/// 组件类型，需要容器承载
/// 实体页面[/eichEdit/index.dart]

import 'dart:io';
import 'dart:async';

import 'package:bfban/utils/upload.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:bfban/utils/index.dart';
import 'package:bfban/component/rich_edit.dart';

import 'package:chewie/chewie.dart';
import 'package:image_picker/image_picker.dart';
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

  /// 添加视频方法
  @override
  Future<String> addVideo() async {
    var pickedFile = await ImagePicker().getVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      return "http://static.fanghnet.com/uploads/szx/uploads/2020/06/353f2c48ce164e368cc040c4fb425331.mp4";
    }
    return null;
  }

  /// 添加图片方法
  @override
  Future<String> addImage() async {
//    await Files().on(context, camera: true, gallery: true, onSucceed: (Map pickedImgs) {
//      print("+++" + pickedImgs.toString());
//
//      if (pickedImgs != null) {
//        //模拟上传后返回的路径
//        return pickedImgs["img"];
//      }
//
//      return null;
//    });

//    var pickedImage = await ImagePicker().getImage(
//      source: ImageSource.gallery,
//    );
//
//    var _upload = await upload.on(
//      File(
//        pickedImage.path,
//      ),
//    );
//
//    print(_upload);
//
//    if (pickedImage != null) {
//      return "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1592205365009&di=fcc201c596fc6681fe7812aa7fea4b23&imgtype=0&src=http%3A%2F%2Fa3.att.hudong.com%2F14%2F75%2F01300000164186121366756803686.jpg";
//      return pickedImage.path;
//    }

    return "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1592205365009&di=fcc201c596fc6681fe7812aa7fea4b23&imgtype=0&src=http%3A%2F%2Fa3.att.hudong.com%2F14%2F75%2F01300000164186121366756803686.jpg";
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
