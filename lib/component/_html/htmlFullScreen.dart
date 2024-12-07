import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:bfban/constants/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_elui_plugin/_message/index.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:path_provider/path_provider.dart';

import '../../utils/index.dart';
import 'html.dart';

class HtmlFullScreen extends StatefulWidget {
  final String content;

  final Map<String, Style> style;

  HtmlFullScreen({
    required this.content,
    required this.style,
  });

  @override
  State<HtmlFullScreen> createState() => _HtmlFullScreenState();
}

class _HtmlFullScreenState extends State<HtmlFullScreen> with SingleTickerProviderStateMixin {
  GlobalKey repaintBoundaryWidgetKey = GlobalKey();

  Uint8List bytes = Uint8List.fromList([]);

  String appName = "";

  late Animation<double> animation;

  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(duration: const Duration(seconds: 2), vsync: this);
    animation = Tween<double>(begin: 0, end: 300).animate(controller)
      ..addListener(() {
        setState(() {
          // The state that has changed here is the animation object’s value.
        });
      });
    setState(() {
      appName = ProviderUtil().ofPackage(context).info!.appName;
    });

    super.initState();
  }

  /// [Event]
  /// 保存生成的图片本地
  _onGenerateFile(pngBytes) async {
    final Directory extDir = await getApplicationSupportDirectory();
    final fileDir = await Directory('${extDir.path}/media').create(recursive: true);
    const String fileExtension = 'jpg';
    final String filePath = '${fileDir.path}/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

    File file = File(filePath);
    file.writeAsBytesSync(pngBytes);

    return file.path;
  }

  /// [Event]
  /// 生成照片
  _onGeneratePhoto() async {
    RenderRepaintBoundary boundary = repaintBoundaryWidgetKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 1.2);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    setState(() {
      bytes = pngBytes;
    });

    // ignore: use_build_context_synchronously
    showAdaptiveDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Image.memory(pngBytes),
          scrollable: true,
          actions: <Widget>[
            TextButton(
              child: Text(FlutterI18n.translate(context, "basic.button.cancel")),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(FlutterI18n.translate(context, "basic.button.commit")),
              onPressed: () async {
                String path = await _onGenerateFile(pngBytes);
                EluiMessageComponent.show(context)(
                  theme: EluiMessageTheme(
                    messageColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: SelectionArea(
                    child: Text(path.toString()),
                  ),
                  time: 8000,
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton(
            icon: Icon(
              Icons.adaptive.more,
              color: Theme.of(context).iconTheme.color,
            ),
            offset: const Offset(0, 45),
            onSelected: (value) {
              switch (value) {
                case 1:
                  _onGeneratePhoto();
                  break;
              }
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: 1,
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Icon(
                        Icons.image_aspect_ratio,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      const SizedBox(width: 10),
                      const Text("Generate a comment picture"),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          RepaintBoundary(
            key: repaintBoundaryWidgetKey,
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                children: [
                  HtmlCore(
                    data: widget.content,
                    style: widget.style,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    color: Theme.of(context).bottomSheetTheme.backgroundColor,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(appName),
                              Opacity(
                                opacity: .7,
                                child: Text(Config.apis["web_site"]!.url),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 6, bottom: 6),
                          child: Opacity(
                            opacity: .5,
                            child: Image.asset(
                              "assets/images/logo.png",
                              width: 70,
                              height: 70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
