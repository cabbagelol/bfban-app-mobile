/// 通知
library;

import 'package:flutter/material.dart';

import 'package:bfban/provider/chat_provider.dart';
import 'package:flutter_elui_plugin/_cell/cell.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class NoticePage extends StatefulWidget {
  const NoticePage({super.key});

  @override
  NoticePageState createState() => NoticePageState();
}

class NoticePageState extends State<NoticePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "app.setting.notice.title")),
      ),
      body: Consumer<ChatProvider>(builder: (BuildContext context, data, Widget? child) {
        return ListView(
          children: [
            // 通知
            EluiCellComponent(
              title: FlutterI18n.translate(context, "app.setting.notice.switch.title"),
              label: FlutterI18n.translate(context, "app.setting.notice.switch.describe"),
              theme: EluiCellTheme(
                titleColor: Theme.of(context).textTheme.titleMedium?.color,
                labelColor: Theme.of(context).textTheme.displayMedium?.color,
                linkColor: Theme.of(context).textTheme.titleMedium?.color,
                backgroundColor: Theme.of(context).cardTheme.color,
              ),
              cont: Switch(
                value: data.messageJiguanStatus.autoSwitchAppMessage,
                onChanged: (bool value) {
                  data.messageJiguanStatus.autoSwitchAppMessage = value;
                  data.onJiguanPush();
                },
              ),
            ),

            // 站内
            EluiCellComponent(
              title: FlutterI18n.translate(context, "app.setting.notice.site.title"),
              label: FlutterI18n.translate(context, "app.setting.notice.site.describe"),
              theme: EluiCellTheme(
                titleColor: Theme.of(context).textTheme.titleMedium?.color,
                labelColor: Theme.of(context).textTheme.displayMedium?.color,
                linkColor: Theme.of(context).textTheme.titleMedium?.color,
                backgroundColor: Theme.of(context).cardTheme.color,
              ),
              cont: Switch(
                value: data.messageJiguanStatus.onSwitchSiteMessage,
                onChanged: (bool value) {
                  data.messageJiguanStatus.onSwitchSiteMessage = value;
                },
              ),
            ),

            const SizedBox(height: 10),

            EluiCellComponent(
              title: FlutterI18n.translate(context, "app.setting.notice.tagstitle"),
              theme: EluiCellTheme(
                titleColor: Theme.of(context).textTheme.titleMedium?.color,
                labelColor: Theme.of(context).textTheme.displayMedium?.color,
                linkColor: Theme.of(context).textTheme.titleMedium?.color,
                backgroundColor: Theme.of(context).cardTheme.color,
              ),
              cont: TextButton(
                onPressed: () {
                  Uuid uuid = const Uuid();
                  data.onJiguanAddTag(uuid.v4(), true);
                },
                child: const Icon(Icons.add),
              ),
            ),
            Column(
              children: [
                for (final tag in data.messageJiguanStatus.AppMessageTags!)
                  ListTile(
                    title: Text(tag["value"].toString()),
                  )
              ],
            ),
          ],
        );
      }),
    );
  }
}
