import 'dart:io';

import 'package:animations/animations.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/elui.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';

import '../../utils/index.dart';

class InsertMediaPage extends StatefulWidget {
  const InsertMediaPage({Key? key}) : super(key: key);

  @override
  State<InsertMediaPage> createState() => _InsertMediaPageState();
}

class _InsertMediaPageState extends State<InsertMediaPage> {
  String imageUrl = "";

  List insertListPage = [];

  int insertListPageIndex = 0;

  bool insertCheckStatus = false;

  bool insertCheckLoad = false;

  @override
  void initState() {
    super.initState();
  }

  /// [Event]
  /// 设置值
  Future _setUrl(String value) async {
    if (value.isEmpty) return;
    setState(() {
      imageUrl = value;
    });
  }

  /// [Event]
  /// 下一步
  _onNext() async {
    // 第一步检查url
    if (insertListPageIndex == 0 && imageUrl.isEmpty) {
      return null;
    }

    // 完成离开
    if (insertListPageIndex == (insertListPage.length - 1)) {
      setState(() {
        insertCheckLoad = true;
      });

      // 检查图片是否可访问
      if (await Regular().authImage(imageUrl) && imageUrl.isNotEmpty) {
        setState(() {
          insertCheckStatus = true;
        });
      } else {
        setState(() {
          insertCheckLoad = false;
        });
      }

      if (insertCheckStatus) Navigator.pop(context, imageUrl);
      return;
    }

    setState(() {
      if (insertListPageIndex <= insertListPage.length - 1) insertListPageIndex += 1;
    });

    return null;
  }

  /// [Event]
  /// 上一步
  _onBacktrack() async {
    if (insertListPageIndex <= 0) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      insertListPageIndex -= 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    insertListPage = [
      InsertSelect(
        onNext: (imageUrl) async {
          await _setUrl(imageUrl);
          _onNext();
        },
        onValue: (imageUrl) async {
          await _setUrl(imageUrl);
        },
      ),
      // InsertCrop(url: imageUrl, insertTypes: insertListPageIndex),
      InsertPreview(url: imageUrl),
    ];

    return Scaffold(
      appBar: AppBar(),
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 150),
        transitionBuilder: (Widget child, Animation<double> primaryAnimation, Animation<double> secondaryAnimation) {
          return SharedAxisTransition(
            fillColor: Theme.of(context).scaffoldBackgroundColor,
            animation: primaryAnimation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.horizontal,
            child: child,
          );
        },
        child: insertListPage[insertListPageIndex],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AnimatedOpacity(
                opacity: insertListPage == 0 ? 0 : 1,
                duration: const Duration(milliseconds: 300),
                child: TextButton(
                  onPressed: _onBacktrack,
                  child: Text(FlutterI18n.translate(context, "basic.button.prev")),
                ),
              ),
              ElevatedButton(
                onPressed: _onNext,
                child: insertListPageIndex + 1 < insertListPage.length
                    ? Text(FlutterI18n.translate(context, "basic.button.next"))
                    : Text(
                  FlutterI18n.translate(context, "app.guide.endNext"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 选择方式
class InsertSelect extends StatefulWidget {
  Function? onNext;
  Function? onValue;

  InsertSelect({
    Key? key,
    this.onNext,
    this.onValue,
  }) : super(key: key);

  @override
  State<InsertSelect> createState() => _InsertSelectState();
}

class _InsertSelectState extends State<InsertSelect> {
  final UrlUtil _urlUtil = UrlUtil();

  String insertValue = "0";

  List insertTypes = [
    {"name": "textarea.type.url", "value": "0"},
    // {"name": "textarea.type.upload", "value": "1"},
    {"name": "textarea.type.media", "value": "2"},
  ];

  /// [Event]
  /// 选择文件上传文件
  _onUploadFile() async {
    ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.gallery);

    var value = await Upload().on(File(image!.path));

    if (widget.onNext != null) widget.onNext!(value);
  }

  /// [Event]
  /// 媒体库选择
  /// 仅支持媒体库取
  _onMediaPage() {
    _urlUtil.opEnPage(context, "/account/media/selectFile").then((value) {
      // 返回选择的url
      if (value.isNotEmpty) widget.onNext!(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3),
              side: BorderSide(
                color: Theme.of(context).dividerTheme.color!,
                width: 1,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: DropdownButton(
                isDense: true,
                isExpanded: true,
                underline: const SizedBox(),
                dropdownColor: Theme.of(context).bottomAppBarTheme.color,
                style: Theme.of(context).dropdownMenuTheme.textStyle,
                onChanged: (value) {
                  setState(() {
                    insertValue = value.toString();
                  });
                },
                value: insertValue,
                items: insertTypes.map<DropdownMenuItem<String>>((i) {
                  return DropdownMenuItem(
                    value: i["value"].toString(),
                    child: Text(FlutterI18n.translate(context, i["name"])),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (insertValue == "0")
            Card(
              child: EluiInputComponent(
                value: "",
                type: TextInputType.text,
                placeholder: "http(s)://",
                internalstyle: true,
                theme: EluiInputTheme(textStyle: Theme.of(context).textTheme.bodyMedium),
                onChange: (data) {
                  if (widget.onValue != null) widget.onValue!(data["value"]);
                },
              ),
            )
          else if (insertValue == "1")
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton(
                  style: ButtonStyle(padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 30))),
                  onPressed: () => _onUploadFile(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.upload_file_rounded,
                        size: 90,
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                EluiTipComponent(
                  type: EluiTip.warning,
                  child: Text.rich(TextSpan(children: [TextSpan(text: FlutterI18n.translate(context, "report.info.uploadPic2")), const TextSpan(text: "https://sm.ms"), TextSpan(text: FlutterI18n.translate(context, "report.info.uploadPic3"))])),
                ),
                const SizedBox(height: 5),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text("*\t", style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    Text(FlutterI18n.translate(context, "report.info.uploadPic1")),
                  ],
                ),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text("*\t", style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    Text(FlutterI18n.translate(context, "report.info.uploadPic4")),
                  ],
                )
              ],
            )
          else if (insertValue == "2")
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton(
                  style: ButtonStyle(padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 30))),
                  onPressed: () => _onMediaPage(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.perm_media,
                        size: 90,
                      )
                    ],
                  ),
                ),
              ],
            )
          else
            const Text("不支持"),
        ],
      ),
    );
  }
}

enum MediaInsertIndexType {
  None,
  Start,
  Crop,
  Preview,
}

abstract class MediaBaseInsertPage extends StatefulWidget {
  MediaInsertIndexType mediaInsertIndexType;

  MediaBaseInsertPage({
    Key? key,
    this.mediaInsertIndexType = MediaInsertIndexType.None,
  }) : super(key: key);
}

/// 裁剪
class InsertCrop extends MediaBaseInsertPage {
  String? url;
  int? insertTypes;

  InsertCrop({
    Key? key,
    this.url,
    this.insertTypes = -1,
  }) : super(key: key);

  @override
  State<InsertCrop> createState() => _InsertCropState();
}

class _InsertCropState extends State<InsertCrop> {
  final GlobalKey<ExtendedImageEditorState> editorKey = GlobalKey<ExtendedImageEditorState>();

  @override
  Widget build(BuildContext context) {
    Widget ne = ExtendedImage.network(widget.url.toString(), fit: BoxFit.contain, mode: ExtendedImageMode.editor, extendedImageEditorKey: editorKey, initEditorConfigHandler: (ExtendedImageState? state) {
      return EditorConfig(
          maxScale: 4.0,
          cropRectPadding: const EdgeInsets.all(20.0),
          hitTestSize: 20.0,
          initCropRectType: InitCropRectType.imageRect,
          cropAspectRatio: CropAspectRatios.ratio4_3,
          editActionDetailsIsChanged: (EditActionDetails? details) {
            //print(details?.totalScale);
          });
    });
    Widget lo = ExtendedImage.asset(
      'assets/image.jpg',
      fit: BoxFit.contain,
      mode: ExtendedImageMode.editor,
      enableLoadState: true,
      extendedImageEditorKey: editorKey,
      initEditorConfigHandler: (ExtendedImageState? state) {
        return EditorConfig(
          maxScale: 8.0,
          cropRectPadding: const EdgeInsets.all(20.0),
          hitTestSize: 20.0,
          // cropLayerPainter: _cropLayerPainter!,
          initCropRectType: InitCropRectType.imageRect,
          // cropAspectRatio: _aspectRatio!.value,
        );
      },
      cacheRawData: true,
    );
    Map editWidget = {
      -1: Text("Not image"),
      0: lo,
      1: ne,
      2: ne,
    };

    return editWidget[widget.insertTypes];
  }
}

/// 预览InsertPreview
class InsertPreview extends MediaBaseInsertPage {
  String? url;

  InsertPreview({
    Key? key,
    this.url = "",
  }) : super(key: key);

  @override
  State<InsertPreview> createState() => _InsertPreviewState();
}

class _InsertPreviewState extends State<InsertPreview> {
  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: PhotoView(
        enablePanAlways: true,
        loadingBuilder: (BuildContext context, ImageChunkEvent? event) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        imageProvider: NetworkImage(widget.url!),
        backgroundDecoration: BoxDecoration(color: Theme.of(context).bottomAppBarTheme.color),
        enableRotation: true,
      ),
    );
  }
}
