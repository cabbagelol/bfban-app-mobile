/// 图片查看

import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/_load/index.dart';
import 'package:flutter_elui_plugin/_message/index.dart';

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

   PhotoViewSimpleScreen({Key? key,
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

  /// [Evnet]
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
            child: const Text("保存成功"),
          )
        : EluiMessageComponent.error(context)(
            child: const Text("错误保存"),
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
      ),
      body: Stack(
        children: [
          PhotoView(
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
          Positioned(
            child: Card(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Opacity(
                    opacity: saveImgLoad ? .2 : 1,
                    child: Column(
                      children: <Widget>[
                        saveImgLoad
                            ? const Padding(
                                padding: EdgeInsets.all(10),
                                child: ELuiLoadComponent(
                                  type: "line",
                                  lineWidth: 3,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              )
                            : IconButton(
                                icon: const Icon(
                                  Icons.file_download,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                onPressed: () {
                                  onSave(context, widget.imageUrl);
                                },
                              ),
                        Text(
                          saveImgLoad ? "写入中" : "保存",
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Opacity(
                    opacity: .2,
                    child: Column(
                      children: <Widget>[
                        IconButton(
                          icon: const Icon(
                            Icons.insert_drive_file,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () {},
                        ),
                        const Text(
                          "加入素材库",
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
