import 'dart:io';

import 'package:animations/animations.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_elui_plugin/elui.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:image_picker/image_picker.dart';

import '../../utils/index.dart';

class InsertMediaPage extends StatefulWidget {
  const InsertMediaPage({super.key});

  @override
  State<InsertMediaPage> createState() => _InsertMediaPageState();
}

class _InsertMediaPageState extends State<InsertMediaPage> {
  final Regular _regular = Regular();

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
      if (await _regular.authImage(imageUrl) && imageUrl.isNotEmpty) {
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
      backgroundColor: Colors.transparent,
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 150),
        transitionBuilder: (Widget child, Animation<double> primaryAnimation, Animation<double> secondaryAnimation) {
          return SharedAxisTransition(
            fillColor: Colors.transparent,
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
  final Function? onNext;

  final Function? onValue;

  const InsertSelect({
    super.key,
    this.onNext,
    this.onValue,
  });

  @override
  State<InsertSelect> createState() => _InsertSelectState();
}

class _InsertSelectState extends State<InsertSelect> {
  final UrlUtil _urlUtil = UrlUtil();

  final TextEditingController _textEditingController = TextEditingController(text: "");

  String insertValue = "0";

  List insertTypes = [
    {"name": "textarea.type.url", "value": "0"},
    // {"name": "textarea.type.upload", "value": "1"},
    {"name": "textarea.type.media", "value": "2"},
  ];

  @override
  void initState() {
    super.initState();

    _textEditingController.addListener(() {
      setState(() {
        if (widget.onValue != null) widget.onValue!(_textEditingController.text);
      });
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  /// [Event]
  /// 选择文件上传文件
  _onUploadFile() async {
    ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.gallery);

    var value = await Upload.on(File(image!.path));

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
          DropdownButtonFormField(
            dropdownColor: Theme.of(context).bottomAppBarTheme.color,
            style: Theme.of(context).dropdownMenuTheme.textStyle,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.more_vert_rounded),
            ),
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
          const SizedBox(height: 20),
          if (insertValue == "0")
            TextField(
              controller: _textEditingController,
              decoration: InputDecoration(
                hintText: "http(s)://",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
              minLines: 2,
              maxLines: 4,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r"^(https?://)?[^\s]+")),
              ],
              autofillHints: [AutofillHints.url],
            )
          else if (insertValue == "1")
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton(
                  style: ButtonStyle(padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 30))),
                  onPressed: () => _onUploadFile(),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
            TextField(
              controller: _textEditingController,
              readOnly: true,
              decoration: InputDecoration(
                hintText: "file://",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.perm_media),
              ),
              onTap: () => _onMediaPage(),
            )
          else
            const Icon(Icons.dangerous),
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
  final MediaInsertIndexType mediaInsertIndexType;

  MediaBaseInsertPage({
    super.key,
    this.mediaInsertIndexType = MediaInsertIndexType.None,
  });
}

/// 裁剪
class InsertCrop extends MediaBaseInsertPage {
  final String? url;
  final int? insertTypes;

  InsertCrop({
    super.key,
    this.url,
    this.insertTypes = -1,
  });

  @override
  State<InsertCrop> createState() => _InsertCropState();
}

class _InsertCropState extends State<InsertCrop> {
  final GlobalKey<ExtendedImageEditorState> editorKey = GlobalKey<ExtendedImageEditorState>();

  @override
  Widget build(BuildContext context) {
    Widget network = ExtendedImage.network(
      widget.url.toString(),
      fit: BoxFit.contain,
      mode: ExtendedImageMode.editor,
      extendedImageEditorKey: editorKey,
      initEditorConfigHandler: (ExtendedImageState? state) {
        return EditorConfig(
          maxScale: 4.0,
          cropRectPadding: const EdgeInsets.all(20.0),
          hitTestSize: 20.0,
          initCropRectType: InitCropRectType.imageRect,
          cropAspectRatio: CropAspectRatios.ratio4_3,
          editActionDetailsIsChanged: (EditActionDetails? details) {
            //print(details?.totalScale);
          },
        );
      },
    );
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
      -1: const Text("Not image"),
      0: lo,
      1: network,
      2: network,
    };
    return editWidget[widget.insertTypes];
  }
}

/// 预览InsertPreview
class InsertPreview extends MediaBaseInsertPage {
  final String? url;

  InsertPreview({
    super.key,
    this.url = "",
  });

  @override
  State<InsertPreview> createState() => _InsertPreviewState();
}

class _InsertPreviewState extends State<InsertPreview> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ExtendedImage.network(
        widget.url!,
        fit: BoxFit.contain,
        mode: ExtendedImageMode.gesture,
        cache: true,
      ),
    );
  }
}
