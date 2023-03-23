/// 图片查看

import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/_load/index.dart';
import 'package:flutter_elui_plugin/_message/index.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import 'package:photo_view/photo_view.dart';

import 'package:bfban/utils/index.dart';

class PhotoViewSimpleScreen extends StatefulWidget {
  final String? imageUrl;

  final ImageProvider? imageProvider;

  final Widget? loadingChild;

  final BoxDecoration? backgroundDecoration;

  final double? minScale;

  final double? maxScale;

  final Object? heroTag;

  const PhotoViewSimpleScreen({
    Key? key,
    this.imageUrl,
    this.imageProvider,
    this.loadingChild,
    this.backgroundDecoration,
    this.minScale,
    this.maxScale,
    this.heroTag,
  }) : super(key: key);

  @override
  _PhotoViewSimpleScreenState createState() => _PhotoViewSimpleScreenState();
}

class _PhotoViewSimpleScreenState extends State<PhotoViewSimpleScreen> {
  // 加载状态
  bool saveImgLoad = false;

  // 图片状态
  bool imgStatus = false;

  // 控制器
  PhotoViewController? controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    if (controller != null) controller!.dispose();
    super.dispose();
  }

  /// [Event]
  /// 储存图片
  void onSave(BuildContext context, String? src) async {
    if (saveImgLoad) {
      return;
    }

    setState(() {
      saveImgLoad = true;
    });

    dynamic result = await Storage().saveimg(src);

    result["code"] == 0
        ? EluiMessageComponent.success(context)(
            child: Text(FlutterI18n.translate(context, "app.basic.message.saveSuccess")),
          )
        : EluiMessageComponent.error(context)(
            child: Text(FlutterI18n.translate(context, "app.basic.message.saveError")),
          );

    setState(() {
      saveImgLoad = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        title: Text(widget.imageUrl!.toString()),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          ClipRect(
            child: PhotoView(
              controller: controller,
              enablePanAlways: true,
              loadingBuilder: (BuildContext context, ImageChunkEvent? event) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
              imageProvider: widget.imageProvider,
              backgroundDecoration: widget.backgroundDecoration,
              minScale: widget.minScale,
              maxScale: widget.maxScale,
              heroAttributes: PhotoViewHeroAttributes(tag: widget.heroTag!),
              enableRotation: true,
            ),
          ),
          Positioned(
            child: Card(
              child: SizedBox(
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        saveImgLoad
                            ? const ELuiLoadComponent(
                                type: "line",
                                lineWidth: 2,
                                size: 25,
                                color: Colors.white,
                              )
                            : IconButton(
                                icon: const Icon(
                                  Icons.file_download,
                                  color: Colors.white,
                                  size: 25,
                                ),
                                onPressed: () {
                                  onSave(context, widget.imageUrl);
                                },
                              ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            bottom: 0,
            left: 0,
            right: 0,
          ),
        ],
      ),
    );
  }
}
