/// 图片查看

import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/_load/index.dart';
import 'package:flutter_elui_plugin/_message/index.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import 'package:bfban/utils/index.dart';

import '../provider/dir_provider.dart';

enum PhotoViewFileType { file, network }

class PhotoViewSimpleScreen extends StatefulWidget {
  PhotoViewFileType? type;

  String? imageUrl;

  PhotoViewSimpleScreen({
    Key? key,
    this.type = PhotoViewFileType.network,
    this.imageUrl = "",
  }) : super(key: key);

  @override
  _PhotoViewSimpleScreenState createState() => _PhotoViewSimpleScreenState();
}

typedef DoubleClickAnimationListener = void Function();

class _PhotoViewSimpleScreenState extends State<PhotoViewSimpleScreen> with TickerProviderStateMixin {
  // 加载状态
  bool imageSaveStatus = false;

  // 图片状态
  bool imgStatus = false;

  MediaManagement mediaManagement = MediaManagement();

  late AnimationController _doubleClickAnimationController;
  late DoubleClickAnimationListener _doubleClickAnimationListener;
  List<double> doubleTapScales = <double>[1.0, 2.0];
  Animation<double>? _doubleClickAnimation;

  @override
  void initState() {
    _doubleClickAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    super.initState();
  }

  /// [Event]
  /// 储存图片
  void onSave(BuildContext context, String? src) async {
    if (imageSaveStatus) return;

    setState(() {
      imageSaveStatus = true;
    });

    dynamic result = await mediaManagement.saveLocalImages(context, src);

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

  GestureConfig initGestureConfigHandler(state) {
    return GestureConfig(
      minScale: 0.3,
      animationMinScale: 0.1,
      maxScale: 10.0,
      animationMaxScale: 10.2,
      speed: 1.0,
      inertialSpeed: 100.0,
      initialScale: 1.0,
      inPageView: false,
      initialAlignment: InitialAlignment.center,
      reverseMousePointerScrollDirection: true,
      gestureDetailsIsChanged: (GestureDetails? details) {
        //print(details?.totalScale);
      },
    );
  }

  Center? loadStateChanged(ExtendedImageState state) {
    if (state.extendedImageLoadState == LoadState.loading) {
      final ImageChunkEvent? loadingProgress = state.loadingProgress;
      final double? progress = loadingProgress?.expectedTotalBytes != null ? loadingProgress!.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 150.0,
              child: LinearProgressIndicator(
                value: progress,
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Text('${((progress ?? 0.0) * 100).toInt()}%'),
          ],
        ),
      );
    }
    return null;
  }

  DoubleTap? onDoubleTap(ExtendedImageGestureState state) {
    final Offset? pointerDownPosition = state.pointerDownPosition;
    final double? begin = state.gestureDetails!.totalScale;
    double end;

    _doubleClickAnimation?.removeListener(_doubleClickAnimationListener);
    _doubleClickAnimationController.stop();
    _doubleClickAnimationController.reset();

    if (begin == doubleTapScales[0]) {
      end = doubleTapScales[1];
    } else {
      end = doubleTapScales[0];
    }

    _doubleClickAnimationListener = () {
      state.handleDoubleTap(scale: _doubleClickAnimation!.value, doubleTapPosition: pointerDownPosition);
    };
    _doubleClickAnimation = _doubleClickAnimationController.drive(Tween<double>(begin: begin, end: end));

    _doubleClickAnimation!.addListener(_doubleClickAnimationListener);

    _doubleClickAnimationController.forward();
    return null;
  }

  Widget _ImageWidget(int index) {
    return [
      ExtendedImage.file(
        File(widget.imageUrl!),
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        mode: ExtendedImageMode.gesture,
        initGestureConfigHandler: initGestureConfigHandler,
        loadStateChanged: loadStateChanged,
        onDoubleTap: onDoubleTap,
      ),
      ExtendedImage.network(
        widget.imageUrl!,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        mode: ExtendedImageMode.gesture,
        cache: true,
        initGestureConfigHandler: initGestureConfigHandler,
        loadStateChanged: loadStateChanged,
        onDoubleTap: onDoubleTap,
      )
    ][index];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.imageUrl!.isNotEmpty ? Text(widget.imageUrl!.toString()) : Container(),
        centerTitle: true,
        actions: [
          if (widget.type == PhotoViewFileType.network)
            imageSaveStatus
                ? IconButton(
              padding: const EdgeInsets.all(16),
                    onPressed: () {},
                    icon: ELuiLoadComponent(
                      type: "line",
                      color: Theme.of(context).progressIndicatorTheme.color!,
                      lineWidth: 2,
                      size: 25,
                    ),
                  )
                : IconButton(
              padding: const EdgeInsets.all(16),
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
      body: ClipRect(
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 1,
              child: _ImageWidget(widget.type!.index),
            )
          ],
        ),
      ),
    );
  }
}
