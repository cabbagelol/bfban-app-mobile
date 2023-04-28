import 'package:bfban/component/_richEdit/index.dart';
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
  final Storage _storage = Storage();

  final GlobalKey<RichEditCoreState> _richEditCoreKey = GlobalKey<RichEditCoreState>();

  late String data = "";

  bool richeditLoad = true;

  // 异步
  Future? futureBuilder;

  final QuillEditorController controller = QuillEditorController();

  List<ToolBarStyle> toolBarList = [
    ToolBarStyle.listBullet,
    ToolBarStyle.listOrdered,
    ToolBarStyle.bold,
  ];

  @override
  void initState() {
    super.initState();
    data = 'Hello world!<img src="https://secure.download.dm.origin.com/production/avatar/prod/userAvatar/43705278/208x208.JPEG" />';
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
    String html = await _richEditCoreKey.currentState!.controllerContent;
    Navigator.pop(
      context,
      {
        "code": 1,
        "html": html,
      },
    );
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

          return RichEditCore(
            key: _richEditCoreKey,
            data: data,
          );
        },
      ),
    );
  }
}
