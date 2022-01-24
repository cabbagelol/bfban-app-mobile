/// 摄像
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_sdk/dynamsoft_barcode.dart';
import 'package:flutter_barcode_sdk/flutter_barcode_sdk.dart';

import '../../utils/camera.dart';
import '../../widgets/drawer.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  dynamic firstCamera;

  late CameraController _controller;

  late Future<void> _initializeControllerFuture;

  late FlutterBarcodeSdk _barcodeReader;

  bool _isScanAvailable = true;

  bool _isScanRunning = false;

  /// 扫码结果
  List _scanResult = ["299388", "23399"];

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      Camera.camera.first,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
    _initializeControllerFuture.then((_) {
      setState(() {});
    });

    // Initialize Dynamsoft Barcode Reader
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
    // Refer to: https://www.dynamsoft.com/barcode-reader/parameters/reference/image-parameter/?ver=latest
    String params = await _barcodeReader.getParameters();

    // Convert parameters to a JSON object.
    dynamic obj = json.decode(params);

    // Modify parameters.
    obj['ImageParameter']['DeblurLevel'] = 5;

    // Update the parameters.
    int ret = await _barcodeReader.setParameters(json.encode(obj));
  }

  /// [Event]
  /// 处理扫描结果
  onScanResult(barcodeResults) {
    _scanResult.removeWhere((element) => element.toString().isEmpty);
    _scanResult.add(barcodeResults);
  }

  /// [Event]
  /// 视频流
  void videoScan() async {
    if (!_isScanRunning) {
      _isScanRunning = true;
      await _controller.startImageStream((CameraImage availableImage) async {
        assert(defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);
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

        _barcodeReader.decodeImageBuffer(availableImage.planes[0].bytes, availableImage.width, availableImage.height, availableImage.planes[0].bytesPerRow, format).then((results) {
          if (_isScanRunning) {
            setState(() {
              /// 处理结果
              onScanResult(getBarcodeResults(results));
            });
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
      return Center(child: CircularProgressIndicator());
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
                    height: _screenHeight * 0.7 - _screenBarHeight,
                    child: MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: _scanResult.map((e) {
                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                                        child: Text("1"),
                                      ),
                                    ),
                                    Icon(Icons.chevron_right)
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
                  color: Theme.of(context).appBarTheme.backgroundColor!.withOpacity(.2),
                  offset: const Offset(0, -2),
                  spreadRadius: .2,
                  blurRadius: 10,
                )
              ],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            height: _screenBarHeight,
          ),
          defaultShowHeight: _screenBarHeight + 80,
          height: _screenHeight * .7,
        ),
      ),

      // 按钮
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        elevation: 10,
        backgroundColor: !_isScanRunning ? Theme.of(context).backgroundColor : Theme.of(context).floatingActionButtonTheme.backgroundColor,
        onPressed: () async {
          await _initializeControllerFuture;

          videoScan();
        },
        child: _isScanRunning ? CircularProgressIndicator() : Icon(Icons.qr_code_outlined, size: 30),
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String? imagePath;
  final String? barcodeResults;

  const DisplayPictureScreen({Key? key, this.imagePath, this.barcodeResults}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dynamsoft Barcode Reader')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Stack(
        alignment: const Alignment(0.0, 0.0),
        children: [
          // Show full screen image: https://stackoverflow.com/questions/48716067/show-fullscreen-image-at-flutter
          Image.file(
            File(imagePath!),
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
            alignment: Alignment.center,
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.black45,
            ),
            child: Text(
              // 'Dynamsoft Barcode Reader',
              barcodeResults!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String getBarcodeResults(List<BarcodeResult> results) {
  StringBuffer sb = new StringBuffer();
  for (BarcodeResult result in results) {
    sb.write(result.format);
    sb.write("\n");
    sb.write(result.text);
    sb.write("\n\n");
  }
  if (results.length == 0) sb.write("No Barcode Detected");
  return sb.toString();
}
