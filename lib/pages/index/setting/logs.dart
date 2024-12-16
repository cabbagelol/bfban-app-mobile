import 'dart:io';

import 'package:bfban/component/_Time/index.dart';
import 'package:bfban/component/_empty/index.dart';
import 'package:bfban/component/_html/htmlWidget.dart';
import 'package:bfban/component/_loading/index.dart';
import 'package:bfban/constants/api.dart';
import 'package:bfban/provider/dir_provider.dart';
import 'package:bfban/provider/log_provider.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';

import '../../../component/_refresh/index.dart';

class LogFilterData {
  late bool reverse;
  late bool isTime;
  late bool isStackTrace;

  LogFilterData({
    this.reverse = false,
    this.isTime = false,
    this.isStackTrace = false,
  });
}

class AppLogsPage extends StatefulWidget {
  const AppLogsPage({super.key});

  @override
  State<AppLogsPage> createState() => _AppLogsPageState();
}

class _AppLogsPageState extends State<AppLogsPage> {
  final GlobalKey<RefreshState> _refreshKey = GlobalKey<RefreshState>();

  final LogFilterData _logFilterData = LogFilterData(reverse: true, isTime: true, isStackTrace: false);

  final TextEditingController _textEditingController = TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
    _textEditingController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  Future _onRefresh() async {
    // 强制更新
    setState(() {});

    _refreshKey.currentState?.controller.finishRefresh();
    _refreshKey.currentState?.controller.resetFooter();
  }

  /// [Event]
  /// 保存前配置
  void _onSaveBeforeSettingModel(LogProvider logData, DirProvider dirData) {
    String fileName = DateTime.now().toLocal().toString();
    TextEditingController saveFileNameController = TextEditingController(text: fileName);
    bool saveLoading = false;
    bool isOpen = true;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      isDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext statefulContext, StateSetter statefulState) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  SizedBox(
                    height: 120,
                    child: Center(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 10,
                        children: [
                          Icon(
                            Icons.save_alt,
                            size: 60,
                          ),
                          Opacity(
                            opacity: .3,
                            child: Icon(
                              Icons.linear_scale,
                              size: 20,
                            ),
                          ),
                          Icon(
                            Icons.file_present,
                            size: 60,
                          )
                        ],
                      ),
                    ),
                  ),
                  TextField(
                    controller: saveFileNameController,
                    decoration: InputDecoration(
                      hintText: fileName,
                      prefixIcon: Icon(Icons.title),
                      suffix: Text(".log"),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  ListTile(
                    title: Text("save path"),
                    subtitle: Text(dirData.currentDefaultSavePath),
                  ),
                  Divider(indent: 8),
                  ListTile(
                    title: Text("open after save"),
                    trailing: Switch.adaptive(
                      value: isOpen,
                      onChanged: (value) {
                        statefulState(() {
                          isOpen = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () async {
                      statefulState(() {
                        saveLoading = true;
                      });
                      await _onSaveError(logData, dirData, fileName, isOpen);
                      statefulState(() {
                        saveLoading = false;
                        Navigator.of(context).pop();
                      });
                    },
                    child: SizedBox(
                      height: 40,
                      child: Center(
                        child: saveLoading ? LoadingWidget() : Icon(Icons.done),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// [Event]
  /// 保存会话错误本地
  Future _onSaveError(LogProvider logData, DirProvider dirData, String fileName, bool isOpen) async {
    String path = "${dirData.currentDefaultSavePath}/logs/$fileName.log";
    File file = File(path);
    String content = logData.list.map((i) => "${i.time.toString()}:${i.error ?? ''}\n${i.stackTrace ?? ''}").join('\n');

    await file.writeAsString(
      content,
      mode: FileMode.append,
    );

    if (isOpen) OpenFile.open(path);
    return;
  }

  /// [Event]
  /// 日志设置
  void _onSettingLogModel(LogProvider logData) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      isDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext statefulContext, StateSetter statefulState) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: ListBody(
                children: [
                  ListTile(
                    title: Text("list reverse"),
                    trailing: Switch.adaptive(
                      value: _logFilterData.reverse,
                      onChanged: (value) {
                        statefulState(() {
                          _logFilterData.reverse = value;
                        });
                      },
                    ),
                  ),
                  Divider(indent: 8),
                  ListTile(
                    title: Text("show stack trace"),
                    trailing: Switch.adaptive(
                      value: _logFilterData.isStackTrace,
                      onChanged: (value) {
                        statefulState(() {
                          _logFilterData.isStackTrace = value;
                        });
                      },
                    ),
                  ),
                  Divider(indent: 8),
                  ListTile(
                    title: Text("show time"),
                    trailing: Switch.adaptive(
                      value: _logFilterData.isTime,
                      onChanged: (value) {
                        statefulState(() {
                          _logFilterData.isTime = value;
                        });
                      },
                    ),
                  ),
                  Divider(indent: 8),
                  ListTile(
                    title: Text("clear logs"),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      setState(() {
                        logData.list.clear();
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                  Divider(),
                  ListTile(
                    title: Text("add test"),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      setState(() {
                        _onTest();
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        Navigator.of(context).pop();
                      });
                    },
                    child: SizedBox(
                      height: 40,
                      child: Center(
                        child: Icon(Icons.done),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// [Event]
  /// 测试
  void _onTest() {
    throw Exception("text");
  }

  /// 取得日志列表
  List list(logData) {
    List l = _logFilterData.reverse ? logData.reverseList : logData.list;
    return l.where((i) => (i.error.toString()).contains(_textEditingController.text)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<LogProvider, DirProvider>(
      builder: (content, logData, dirData, widget) {
        return Scaffold(
          appBar: AppBar(
            actions: [
              if (logData.list.isNotEmpty)
                IconButton(
                  onPressed: () => _onSaveBeforeSettingModel(logData, dirData),
                  icon: Icon(Icons.save),
                ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  _onSettingLogModel(logData);
                },
              ),
            ],
          ),
          body: Refresh(
            key: _refreshKey,
            onRefresh: _onRefresh,
            child: logData.list.isNotEmpty
                ? Column(
                    children: [
                      /// search
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: TextField(
                          decoration: InputDecoration(prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
                        ),
                      ),

                      /// logs list
                      Flexible(
                        flex: 1,
                        child: ListView.separated(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          itemBuilder: (context, index) {
                            LogItemData i = list(logData)[index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  children: [
                                    if (_logFilterData.isTime) TimeWidget(data: i.time.toString()),
                                    if (_logFilterData.isTime) VerticalDivider(),
                                    Text(i.error.toString()),
                                  ],
                                ),
                                if (_logFilterData.isStackTrace) SizedBox(height: 5),
                                if (_logFilterData.isStackTrace) HtmlWidget(content: i.stackTrace.toString()),
                              ],
                            );
                          },
                          separatorBuilder: (context, index) => Divider(),
                          itemCount: logData.list.length,
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      EmptyWidget(),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
