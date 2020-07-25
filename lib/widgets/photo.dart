/// 图片查看器

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PhotoViewSimpleScreen extends StatelessWidget {
  const PhotoViewSimpleScreen({
    this.imageProvider, //图片
    this.loadingChild, //加载时的widget
    this.backgroundDecoration, //背景修饰
    this.minScale, //最大缩放倍数
    this.maxScale, //最小缩放倍数
    this.heroTag, //hero动画tagid
  });

  final ImageProvider imageProvider;
  final Widget loadingChild;
  final Decoration backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(
          height: MediaQuery
              .of(context)
              .size
              .height,
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
              bottom: 0,
              right: 0,
              child: PhotoView(
                imageProvider: imageProvider,
                loadingChild: loadingChild,
                backgroundDecoration: backgroundDecoration,
                minScale: minScale,
                maxScale: maxScale,
                heroAttributes: PhotoViewHeroAttributes(tag: heroTag),
                enableRotation: true,
              ),
            ),
            Positioned( //右上角关闭按钮
              right: 10,
              top: MediaQuery
                  .of(context)
                  .padding
                  .top,
              child: IconButton(
                icon: Icon(Icons.close, size: 30, color: Colors.white,),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
