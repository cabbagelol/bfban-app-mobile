import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/_load/index.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import 'package:quill_html_editor/quill_html_editor.dart';

import '../../utils/index.dart';
import '../not_found/index.dart';

class RichEditPage extends StatefulWidget {
  const RichEditPage({
    Key? key,
  }) : super(key: key);

  @override
  _richEditPageState createState() => _richEditPageState();
}

class _richEditPageState extends State<RichEditPage> {
  final UrlUtil _urlUtil = UrlUtil();

  final Storage _storage = Storage();

  late String data = "";

  bool richeditLoad = true;

  // 异步
  Future? futureBuilder;

  // 滚动控制器
  final ScrollController? _scrollController = ScrollController();

  final QuillEditorController controller = QuillEditorController();

  List<ToolBarStyle> toolBarList = [
    ToolBarStyle.listBullet,
    ToolBarStyle.listOrdered,
    ToolBarStyle.bold,
  ];

  @override
  void initState() {
    super.initState();
    futureBuilder = _ready();

    Future.delayed(const Duration(seconds: 1)).then((value) {
      setState(() {
        richeditLoad = false;
      });
    });
  }

  Future _ready() async {
    StorageData richeditData = await _storage.get("richedit");
    data = richeditData.value;
    return data;
  }

  /// 确认
  void _onSubmit() async {
    Navigator.pop(
      context,
      {
        "code": 1,
        "html": await controller.getText(),
      },
    );
  }

  /// [Event]
  /// 打开媒体插入
  void _openMediaPage() {
    _urlUtil.opEnPage(context, "/account/media/insert").then((value) async {
      if (value.toString().isNotEmpty) await controller.embedImage(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(
              context,
              {"code": 2},
            );
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: () => _onSubmit(),
          ),
        ],
      ),
      body: FutureBuilder(
        future: futureBuilder,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return const NotFoundPage();
          }

          return Stack(
            children: [
              Container(
                margin: const EdgeInsets.all(10),
                child: SingleChildScrollView(
                  child: QuillHtmlEditor(
                    text: data,
                    hintText: FlutterI18n.translate(context, "app.richedit.placeholder"),
                    hintTextStyle: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 16),
                    textStyle: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 16),
                    controller: controller,
                    isEnabled: true,
                    minHeight: 100,
                    hintTextAlign: TextAlign.start,
                    padding: EdgeInsets.zero,
                    hintTextPadding: EdgeInsets.zero,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  ),
                ),
              ),
              if (richeditLoad)
                Positioned.fill(
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: ELuiLoadComponent(
                      type: "line",
                      lineWidth: 1,
                      color: Theme.of(context).textTheme.displayMedium!.color!,
                      size: 16,
                    ),
                  ),
                ),
            ],
          );
        },
      ), // bo
      bottomSheet: Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: ToolBar(
          controller: controller,
          toolBarConfig: toolBarList,
          toolBarColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(.2),
          iconColor: Theme.of(context).colorScheme.primary.withOpacity(.5),
          activeIconColor: Theme.of(context).colorScheme.primary,
          customButtons: [
            InkWell(
              onTap: () => _openMediaPage(),
              child: Icon(
                Icons.image_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          ],
        ),
      ),
    );
  }
}
