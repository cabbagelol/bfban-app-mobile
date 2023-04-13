import 'package:flutter/material.dart';

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
        iconColor: Theme.of(context).primaryColor.withOpacity(.5),
        activeIconColor: Theme.of(context).primaryColor,
        customButtons: [
          InkWell(
            onTap: () => _openMediaPage(),
            child: Icon(
              Icons.image_outlined,
              color: Theme.of(context).primaryColor,
            ),
          )
        ],
      ),
      body: FutureBuilder(
        future: futureBuilder,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return const NotFoundPage();
          }

          return Container(
            margin: const EdgeInsets.all(10),
            child: SingleChildScrollView(
              child: QuillHtmlEditor(
                text: data,
                hintText: "",
                hintTextStyle: const TextStyle(color: Colors.black54, fontSize: 16),
                textStyle: const TextStyle(color: Colors.black, fontSize: 16),
                controller: controller,
                isEnabled: true,
                minHeight: 300,
                hintTextAlign: TextAlign.start,
                padding: EdgeInsets.zero,
                hintTextPadding: EdgeInsets.zero,
              ),
            ),
          );
        },
      ), // bottomNavigationBar: ,
    );
  }
}
