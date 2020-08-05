/// 图片查看

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_plugin_elui/_load/index.dart';
import 'package:flutter_plugin_elui/_message/index.dart';

import 'package:photo_view/photo_view.dart';

import 'package:bfban/utils/index.dart';

class PhotoViewSimpleScreen extends StatefulWidget {
  final String imageUrl;

  final ImageProvider imageProvider;

  final Widget loadingChild;

  final Decoration backgroundDecoration;

  final dynamic minScale;

  final dynamic maxScale;

  final String heroTag;

  const PhotoViewSimpleScreen({
    this.imageUrl,
    this.imageProvider,
    this.loadingChild,
    this.backgroundDecoration,
    this.minScale,
    this.maxScale,
    this.heroTag,
  });

  @override
  _PhotoViewSimpleScreenState createState() => _PhotoViewSimpleScreenState();
}

class _PhotoViewSimpleScreenState extends State<PhotoViewSimpleScreen> {
  bool saveImgLoad = false;

  /// 储存图片
  void onSave(BuildContext context, String src) async {
    if (saveImgLoad) {
      return;
    }

    setState(() {
      saveImgLoad = true;
    });

    dynamic result = await Storage.saveimg(src);

    result["code"] == 0
        ? EluiMessageComponent.success(context)(
            child: Text("保存成功"),
          )
        : EluiMessageComponent.error(context)(
            child: Text("错误保存"),
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
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: <Widget>[
          PhotoView(
            imageProvider: widget.imageProvider,
            loadingChild: widget.loadingChild,
            backgroundDecoration: widget.backgroundDecoration,
            minScale: widget.minScale,
            maxScale: widget.maxScale,
            heroAttributes: PhotoViewHeroAttributes(tag: widget.heroTag),
            enableRotation: true,
          ),
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              padding: EdgeInsets.only(
                bottom: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Opacity(
                    opacity: saveImgLoad ? .2 : 1,
                    child: Column(
                      children: <Widget>[
                        saveImgLoad
                            ? Padding(
                                padding: EdgeInsets.all(10),
                                child: ELuiLoadComponent(
                                  type: "line",
                                  lineWidth: 3,
                                  size: 25,
                                  color: Colors.white,
                                ),
                              )
                            : IconButton(
                                icon: Icon(
                                  Icons.file_download,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                onPressed: () {
                                  this.onSave(context, widget.imageUrl);
                                },
                              ),
                        Text(
                          saveImgLoad ? "写入中" : "保存",
                          style: TextStyle(
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
                          icon: Icon(
                            Icons.insert_drive_file,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        Text(
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
          ),
        ],
      ),
    );
  }
}
