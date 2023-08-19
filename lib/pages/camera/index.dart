import 'dart:io';

import 'package:bfban/utils/index.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:bfban/constants/api.dart';

import '../../utils/url.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final UrlUtil _urlUtil = UrlUtil();

  dynamic firstCamera;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// [Event]
  /// 启动内容
  void openLink(data) {
    switch (data["type"]) {
      case "web_site_link":
        // 外部链接
        _urlUtil.onPeUrl(Config.apiHost["app_web_site"]!.url + "/player/" + data["content"]);
        break;
      case "app_palyer_link":
        // 内部玩家链接
        _urlUtil.opEnPage(context, "/player/personaId/${data["content"]}");
        break;
    }
  }

  Future<CaptureRequest> path2(sensors, CaptureMode captureMode) async {
    final Directory extDir = await getApplicationSupportDirectory();
    final fileDir = await Directory('${extDir.path}/media').create(recursive: true);
    final String fileExtension = captureMode == CaptureMode.photo ? 'jpg' : 'mp4';

    if (sensors.length == 1) {
      final String filePath = '${fileDir.path}/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

      return SingleCaptureRequest(filePath, sensors.first);
    } else {
      // 用于区分前后摄像头
      return MultipleCaptureRequest(
        {
          for (final sensor in sensors) sensor: '${fileDir.path}/${sensor.position == SensorPosition.front ? 'front_' : "back_"}${DateTime.now().millisecondsSinceEpoch}.$fileExtension',
        },
      );
    }
  }

  Future<String> path(CaptureMode captureMode) async {
    final Directory extDir = await getApplicationSupportDirectory();
    final fileDir = await Directory('${extDir.path}/media').create(recursive: true);
    final String fileExtension = captureMode == CaptureMode.photo ? 'jpg' : 'mp4';
    final String filePath = '${fileDir.path}/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
    return filePath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CameraAwesomeBuilder.custom(
        saveConfig: SaveConfig.photoAndVideo(
          photoPathBuilder: (sensors) => path2(sensors, CaptureMode.photo),
          videoPathBuilder: (sensors) => path2(sensors, CaptureMode.video),
          initialCaptureMode: CaptureMode.photo,
        ),
        onImageForAnalysis: (AnalysisImage img) async {
          // Handle image analysis
          print(img);
        },
        builder: (state, size, rect) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: AwesomeTopActions(
                state: state,
                padding: EdgeInsets.zero,
                children: [
                  const Spacer(),
                  AwesomeFlashButton(state: state),
                  const SizedBox(width: 5),
                  if (state is PhotoCameraState) AwesomeAspectRatioButton(state: state),
                ],
              ),
            ),
            body: AwesomeCameraLayout(
              state: state,
              topActions: Container(),
              middleContent: Column(
                children: [
                  const Spacer(),
                  AwesomeCameraModeSelector(state: state),
                ],
              ),
              bottomActions: AwesomeBottomActions(
                state: state,
                onMediaTap: (mediaCapture) {},
              ),
            ),
          );
        },
        imageAnalysisConfig: AnalysisConfig(
          androidOptions: const AndroidAnalysisOptions.nv21(
            width: 250,
          ),
          autoStart: true,
          cupertinoOptions: const CupertinoAnalysisOptions.bgra8888(),
          maxFramesPerSecond: 20,
        ),
        theme: AwesomeTheme(
          bottomActionsBackgroundColor: Theme.of(context).bottomAppBarTheme.color!.withOpacity(0.5),
          buttonTheme: AwesomeButtonTheme(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor!.withOpacity(0.5),
            iconSize: 20,
            rotateWithCamera: false,
            padding: const EdgeInsets.all(10),
            foregroundColor: Theme.of(context).appBarTheme.iconTheme!.color!,
            buttonBuilder: (child, onTap) {
              return ClipOval(
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    splashColor: Theme.of(context).bottomAppBarTheme.color!.withOpacity(0.5),
                    highlightColor: Theme.of(context).bottomAppBarTheme.color!.withOpacity(0.5),
                    onTap: onTap,
                    child: child,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
