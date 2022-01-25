/// 摄像

import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_sdk/dynamsoft_barcode.dart';
import 'package:flutter_barcode_sdk/flutter_barcode_sdk.dart';

import 'package:bfban/constants/api.dart';

import '../../utils/camera.dart';
import '../../utils/url.dart';
import '../../widgets/drawer.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final UrlUtil _urlUtil = UrlUtil();

  dynamic firstCamera;

  late CameraController _controller;

  late Future<void> _initializeControllerFuture;

  late FlutterBarcodeSdk _barcodeReader;

  bool _isScanAvailable = true;

  bool _isScanRunning = false;

  /// 扫码结果
  List _scanResult = [
    // {"type_index": 0, "type": "web_site_link", "content": "1004766466591"},
    // {"type_index": 1, "type": "app_palyer_link", "content": "1004766466591"},
    // {"type_index": 2, "type": "text", "content": "1004766466591"}
  ];

  @override
  void initState() {
    super.initState();

    // 初始相机
    _controller = CameraController(
      Camera.camera.first,
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
    _initializeControllerFuture.then((_) {
      setState(() {});
    });

    initBarcodeSDK();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// [Event]
  /// 相机sdk初始化
  Future<void> initBarcodeSDK() async {
    _barcodeReader = FlutterBarcodeSdk();

    // Get 30-day FREEE trial license from https://www.dynamsoft.com/customer/license/trialLicense?product=dbr
    // await _barcodeReader.setLicense('LICENSE-KEY');
    await _barcodeReader.setBarcodeFormats(BarcodeFormat.ALL);

    // Get all current parameters.
    String params = await _barcodeReader.getParameters();

    // Convert parameters to a JSON object.
    dynamic obj = json.decode(params);

    // Modify parameters.
    obj['ImageParameter']['DeblurLevel'] = 5;

    // Update the parameters.
  }

  /// [Event]
  /// 处理扫描结果
  onScanResult(String barcodeResults) {
    _scanResult = [];
    _scanResult.removeWhere((element) => element.toString().isEmpty);

    // 序列化
    Map scanResult = jsonDecode(barcodeResults);

    if (barcodeResults.toString().contains("bfban")) {
      _scanResult.addAll([
        {"type_index": 0, "type": "web_site_link", "content": scanResult["id"]},
        {"type_index": 1, "type": "app_palyer", "content": scanResult["id"]}
      ]);
    } else {
      // 不符合格式
      _scanResult.addAll([
        {"type_index": 2, "type": "text", "content": scanResult["id"]},
      ]);
    }
  }

  /// [Event]
  /// 启动内容
  void openLink(data) {
    switch (data["type"]) {
      case "web_site_link":
        // 外部链接
        _urlUtil.onPeUrl(
            Config.apiHost["bfban_web_site"] + "/player/" + data["content"]);
        break;
      case "app_palyer_link":
        // 内部玩家链接
        _urlUtil.opEnPage(context, "/detail/player/${data["content"]}");
        break;
    }
  }

  /// [Event]
  /// 视频流
  void videoScan() async {
    if (!_isScanRunning) {
      _isScanRunning = true;
      await _controller.startImageStream((CameraImage availableImage) async {
        assert(defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
        int format = FlutterBarcodeSdk.IF_UNKNOWN;

        switch (availableImage.format.group) {
          case ImageFormatGroup.yuv420:
            format = FlutterBarcodeSdk.IF_YUV420;
            break;
          case ImageFormatGroup.bgra8888:
            format = FlutterBarcodeSdk.IF_BRGA8888;
            break;
          default:
            format = FlutterBarcodeSdk.IF_UNKNOWN;
        }

        if (!_isScanAvailable) {
          return;
        }

        _isScanAvailable = false;

        _barcodeReader
            .decodeImageBuffer(
                availableImage.planes[0].bytes,
                availableImage.width,
                availableImage.height,
                availableImage.planes[0].bytesPerRow,
                format)
            .then((results) {
          if (_isScanRunning) {
            /// 处理结果
            onScanResult(getBarcodeResults(results));
          }

          _isScanAvailable = true;
        }).catchError((error) {
          _isScanAvailable = false;
        });
      });
    } else {
      _isScanRunning = false;

      await _controller.stopImageStream();
    }
  }

  /// [Widget]
  /// 相机视图
  Widget getCameraWidget() {
    if (!_controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    } else {
      // https://stackoverflow.com/questions/49946153/flutter-camera-appears-stretched
      final size = MediaQuery.of(context).size;
      var scale = size.aspectRatio * _controller.value.aspectRatio;

      if (scale < 1) scale = 1 / scale;

      return Transform.scale(
        scale: scale,
        child: Center(
          child: CameraPreview(_controller),
        ),
      );
      // return CameraPreview(_controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    double _screenHeight = MediaQuery.of(context).size.height;
    double _screenBarHeight = 26.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      drawerScrimColor: Theme.of(context).drawerTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomRight,
              colors: [Colors.transparent, Colors.black54],
            ),
          ),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: FlutterPluginDrawer(
        body: Stack(
          children: [
            // 相机画布
            getCameraWidget(),
          ],
        ),
        dragContainer: DragContainer(
          drawer: Container(
            child: OverscrollNotificationWidget(
              child: Column(
                children: <Widget>[
                  Container(
                    height: 6.0,
                    width: 45.0,
                    margin: const EdgeInsets.only(top: 10.0, bottom: 10),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 214, 215, 218),
                      borderRadius: BorderRadius.all(
                        Radius.circular(5.0),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: _screenHeight * 0.5 - _screenBarHeight,
                    child: MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      child: ListView(
                        children: _scanResult.map((e) {
                          return GestureDetector(
                            onTap: () => openLink(e),
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  children: [
                                    IndexedStack(
                                      index: e["type_index"],
                                      children: const [
                                        Icon(Icons.touch_app_rounded),
                                        Icon(Icons.link),
                                        Icon(Icons.text_snippet)
                                      ],
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 20,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            e["type_index"] != 2
                                                ? Text(e["content"].toString())
                                                : TextField(
                                                    controller:
                                                        TextEditingController(
                                                            text: e["content"]
                                                                .toString()),
                                                    maxLines: 3,
                                                  ),
                                            // 描述
                                            IndexedStack(
                                              index: e["type_index"],
                                              children: const [
                                                Text("从bfban网站打开"),
                                                Text("打开应用内部的玩家信息")
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.black,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context)
                      .appBarTheme
                      .backgroundColor!
                      .withOpacity(.2),
                  offset: const Offset(0, -2),
                  spreadRadius: .2,
                  blurRadius: 10,
                )
              ],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            height: _screenBarHeight,
          ),
          defaultShowHeight: _screenBarHeight,
          height: _screenHeight * .5,
        ),
      ),

      // 按钮
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        materialTapTargetSize: MaterialTapTargetSize.padded,
        elevation: 10,
        backgroundColor: !_isScanRunning
            ? Theme.of(context).backgroundColor
            : Theme.of(context).floatingActionButtonTheme.backgroundColor,
        onPressed: () async {
          await _initializeControllerFuture;

          videoScan();
        },
        child: _isScanRunning
            ? const CircularProgressIndicator()
            : const Icon(Icons.qr_code_outlined, size: 30),
      ),
    );
  }
}

String getBarcodeResults(List<BarcodeResult> results) {
  StringBuffer sb = StringBuffer();
  for (BarcodeResult result in results) {
    sb.write(result.format);
    sb.write("\n");
    sb.write(result.text);
    sb.write("\n\n");
  }
  if (results.isEmpty) sb.write("No Barcode Detected");
  return sb.toString();
}
