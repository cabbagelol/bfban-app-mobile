import 'dart:io';

import 'package:bfban/component/_Time/index.dart';
import 'package:bfban/component/_html/htmlWidget.dart';
import 'package:bfban/provider/dir_provider.dart';
import 'package:bfban/provider/log_provider.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';

import '../../../component/_refresh/index.dart';

class AppLogsPage extends StatefulWidget {
  const AppLogsPage({super.key});

  @override
  State<AppLogsPage> createState() => _AppLogsPageState();
}

class _AppLogsPageState extends State<AppLogsPage> {
  final GlobalKey<RefreshState> _refreshKey = GlobalKey<RefreshState>();

  @override
  void initState() {
    super.initState();
  }

  Future _onRefresh() async {
    _refreshKey.currentState?.controller.finishRefresh();
    _refreshKey.currentState?.controller.resetFooter();
  }

  /// [Event]
  /// 保存会话错误本地
  void _onSaveError(LogProvider logData, DirProvider dirData) async {
    String path = "${dirData.currentDefaultSavePath}/logs/${DateTime.now()}.log";
    File file = File(path);
    String content = logData.list.map((i) => "${i.time.toString()}:${i.error ?? ''}\n${i.stackTrace ?? ''}").join('\n');

    await file.writeAsString(
      content,
      mode: FileMode.append,
    );

    OpenFile.open(path);
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
                  onPressed: () => _onSaveError(logData, dirData),
                  icon: Icon(Icons.save),
                ),
              if (logData.list.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    logData.list.clear();
                  },
                ),
            ],
          ),
          body: Refresh(
            key: _refreshKey,
            onRefresh: _onRefresh,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              itemBuilder: (context, index) {
                LogItemData i = logData.list[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      children: [
                        TimeWidget(data: i.time.toString()),
                        VerticalDivider(),
                        Text(i.error.toString()),
                      ],
                    ),
                    SizedBox(height: 5),
                    HtmlWidget(content: i.stackTrace.toString()),
                  ],
                );
              },
              separatorBuilder: (context, index) => Divider(),
              itemCount: logData.list.length,
            ),
          ),
        );
      },
    );
  }
}
