/// 富文本页面

import 'package:flutter/material.dart';

import 'package:bfban/utils/index.dart';
import 'package:minimal_html_editor/minimal_html_editor.dart';

import '../not_found/index.dart';

class RichEditPage extends StatefulWidget {
  const RichEditPage({Key? key}) : super(key: key);

  @override
  _richEditPageState createState() => _richEditPageState();
}

class _richEditPageState extends State<RichEditPage> {
  late String data = "";

  // 异步
  Future? futureBuilder;

  // 滚动控制器
  final ScrollController? _scrollController = ScrollController();

  // 文本控制器
  EditorController? _editorController;

  @override
  void initState() {
    super.initState();

    _editorController = EditorController(
      scrollController: _scrollController,
    );
    futureBuilder = _ready();
  }

  Future _ready() async {
    data = await Storage().get("richedit");

    return data;
  }

  /// 确认
  void _onSubmit() async {
    dynamic content = await _editorController!.getHtml();

    Navigator.pop(
      context,
      {
        "code": 1,
        "html": content.toString(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
        title: const Text("编辑"),
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
          if(snapshot.data == null) {
            return const NotFoundPage();
          }

          return ListView(
            controller: _scrollController,
            children: [
              SingleChildScrollView(
                child: HtmlEditor(
                  flexibleHeight: true,
                  autoAdjustScroll: false,
                  controller: _editorController,
                  minHeight: 300,
                  scaleFactor: 1,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  initialText: data,
                  placeholder: "",
                  webViewTitle: "Editor",
                  printWebViewLog: false,
                  useAndroidHybridComposition: false,
                  showLoadingWheel: false,
                  onChange: (content, height) => print(content),
                ),
              ),
            ],
          );
        },
      ), // bottomNavigationBar: ,
    );
  }
}
