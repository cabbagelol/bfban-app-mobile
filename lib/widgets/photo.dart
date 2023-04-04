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
  bool imageSaveStatus = false;

  // 图片状态
  bool imgStatus = false;

  // 控制器
  PhotoViewController? controller;

  MediaManagement mediaManagement = MediaManagement();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    if (controller != null) controller!.dispose();
    super.dispose();
  }

  /// [Event]
  /// 储存图片
  void onSave(BuildContext context, String? src) async {
    if (imageSaveStatus) {
      return;
    }

    setState(() {
      imageSaveStatus = true;
    });

    dynamic result = await mediaManagement.saveLocalImages(src);

    result["code"] == 0
        ? EluiMessageComponent.success(context)(
            child: Text(FlutterI18n.translate(context, "app.basic.message.saveSuccess")),
          )
        : EluiMessageComponent.error(context)(
            child: Text(FlutterI18n.translate(context, "app.basic.message.saveError")),
          );

    setState(() {
      imageSaveStatus = false;
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
        actions: [
          imageSaveStatus
              ? ElevatedButton(
                  onPressed: () {},
                  child: const ELuiLoadComponent(
                    type: "line",
                    lineWidth: 2,
                    size: 25,
                  ),
                )
              : IconButton(
                  icon: const Icon(
                    Icons.file_download,
                    size: 25,
                  ),
                  onPressed: () {
                    onSave(context, widget.imageUrl);
                  },
                ),
        ],
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
              backgroundDecoration: widget.backgroundDecoration ?? BoxDecoration(
                color: Theme.of(context).backgroundColor
              ),
              minScale: widget.minScale,
              maxScale: widget.maxScale,
              heroAttributes: PhotoViewHeroAttributes(tag: widget.heroTag!),
              enableRotation: true,
            ),
          ),
        ],
      ),
    );
  }
}
