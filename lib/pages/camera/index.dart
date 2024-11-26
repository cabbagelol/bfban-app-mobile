import 'dart:io';

import 'package:bfban/component/_loading/index.dart';
import 'package:bfban/utils/index.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';

import 'package:bfban/constants/api.dart';
import 'package:provider/provider.dart';

import '../../provider/dir_provider.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  CameraPageState createState() => CameraPageState();
}

class CameraPageState extends State<CameraPage> {
  final UrlUtil _urlUtil = UrlUtil();

  dynamic firstCamera;

  DirProvider? dirProvider;

  @override
  void initState() {
    super.initState();
    dirProvider = Provider.of<DirProvider>(context, listen: false);
  }

  /// [Event]
  /// 启动内容
  void openLink(data) {
    switch (data["type"]) {
      case "web_site_link":
        // 外部链接
        _urlUtil.onPeUrl("${Config.apiHost["app_web_site"]!.url}/player/${data["content"]}");
        break;
      case "app_palyer_link":
        // 内部玩家链接
        _urlUtil.opEnPage(context, "/player/personaId/${data["content"]}");
        break;
    }
  }

  /// [Event]
  /// 打开媒体
  void openMedia() {
    _urlUtil.opEnPage(context, "/account/media/");
  }

  Future<CaptureRequest> path(List<Sensor> sensors, CaptureMode captureMode) async {
    final fileDir = await Directory('${dirProvider!.currentDefaultSavePath}/media').create(recursive: true);
    final String fileExtension = captureMode == CaptureMode.photo ? 'jpg' : 'mp4';

    if (sensors.length == 1) {
      final String filePath = '${fileDir.path}/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

      return SingleCaptureRequest(filePath, sensors.first);
    } else {
      // 用于区分前后摄像头
      return MultipleCaptureRequest(
        {for (final sensor in sensors) sensor: '${fileDir.path}/${sensor.position == SensorPosition.front ? 'front_' : "back_"}${DateTime.now().millisecondsSinceEpoch}.$fileExtension'},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CameraAwesomeBuilder.custom(
      saveConfig: SaveConfig.photoAndVideo(
        photoPathBuilder: (List<Sensor> sensors) => path(sensors, CaptureMode.photo),
        videoPathBuilder: (List<Sensor> sensors) => path(sensors, CaptureMode.video),
        initialCaptureMode: CaptureMode.photo,
      ),
      progressIndicator: Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: LoadingWidget(),
        ),
      ),
      builder: (state, previewSize) {
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
            middleContent: const Column(
              children: [
                Spacer(),
                // AwesomeCameraModeSelector(state: state),
              ],
            ),
            bottomActions: AwesomeBottomActions(
              state: state,
              right: Column(
                children: [
                  // 相机已准备好拍照 或 相机已准备好拍摄视频
                  if (state is PhotoCameraState || state is VideoCameraState)
                    StreamBuilder<MediaCapture?>(
                      stream: state.captureState$,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return SizedBox(
                            width: 55,
                            height: 55,
                            child: OpenMediaButton(
                              state: state,
                              onTap: (state) {
                                openMedia();
                              },
                            ),
                          );
                        }
                        return SizedBox(
                          width: 55,
                          child: AwesomeMediaPreview(
                            mediaCapture: snapshot.requireData,
                            onMediaTap: (mediaCapture) {
                              openMedia();
                            },
                          ),
                        );
                      },
                    )
                  else
                    OpenMediaButton(
                      state: state,
                      onTap: (statu) {
                        openMedia();
                      },
                    )
                ],
              ),
            ),
          ),
        );
      },
      imageAnalysisConfig: AnalysisConfig(
        androidOptions: const AndroidAnalysisOptions.nv21(width: 250),
        autoStart: false,
        cupertinoOptions: const CupertinoAnalysisOptions.bgra8888(),
        maxFramesPerSecond: 20,
      ),
      theme: AwesomeTheme(
        bottomActionsBackgroundColor: Theme.of(context).bottomAppBarTheme.color!.withOpacity(0.1),
        buttonTheme: AwesomeButtonTheme(
          foregroundColor: Theme.of(context).appBarTheme.iconTheme!.color!,
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor!,
          iconSize: 20,
          rotateWithCamera: false,
          padding: const EdgeInsets.all(10),
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
    );
  }
}

class OpenMediaButton extends StatelessWidget {
  final CameraState state;
  final AwesomeTheme? theme;
  final Widget Function() iconBuilder;
  final void Function(CameraState) onTap;

  OpenMediaButton({
    super.key,
    required this.state,
    this.theme,
    Widget Function()? iconBuilder,
    void Function(CameraState)? onTap,
    double scale = 1.3,
  })  : iconBuilder = iconBuilder ??
            (() {
              return AwesomeCircleWidget.icon(
                theme: theme,
                icon: Icons.perm_media_outlined,
                scale: scale,
              );
            }),
        onTap = onTap ?? ((state) => {});

  @override
  Widget build(BuildContext context) {
    final theme = this.theme ?? AwesomeThemeProvider.of(context).theme;

    return AwesomeOrientedWidget(
      rotateWithDevice: theme.buttonTheme.rotateWithCamera,
      child: theme.buttonTheme.buttonBuilder(
        iconBuilder(),
        () => onTap(state),
      ),
    );
  }
}
