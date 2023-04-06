import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import 'package:quill_html_editor/quill_html_editor.dart';

import '../../utils/index.dart';
import '../not_found/index.dart';

class RichEditPage extends StatefulWidget {
  RichEditPage({
    Key? key,
  }) : super(key: key);

  @override
  _richEditPageState createState() => _richEditPageState();
}

class _richEditPageState extends State<RichEditPage> {
  late String data = "";

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
  }

  Future _ready() async {
    data = await Storage().get("richedit");

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
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: () => _onSubmit(),
          ),
        ],
      ),
      bottomSheet: ToolBar(
        controller: controller,
        toolBarConfig: toolBarList,
        activeIconColor: Theme.of(context).primaryColor,
      ),
      body: FutureBuilder(
        future: futureBuilder,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return const NotFoundPage();
          }

          return ListView(
            controller: _scrollController,
            children: [
              SingleChildScrollView(
                child: QuillHtmlEditor(
                  text: data,
                  hintText: "",
                  hintTextStyle: TextStyle(color: Colors.black54, fontSize: 16),
                  textStyle: TextStyle(color: Colors.black, fontSize: 16),
                  controller: controller,
                  isEnabled: true,
                  minHeight: 300,
                  hintTextAlign: TextAlign.start,
                  padding: EdgeInsets.all(5),
                  hintTextPadding: EdgeInsets.all(5),
                ),
              )
            ],
          );
        },
      ), // bottomNavigationBar: ,
    );
  }
}
