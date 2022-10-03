/// 通知
import 'package:flutter/material.dart';

import 'package:bfban/provider/message_provider.dart';
import 'package:flutter_elui_plugin/_cell/cell.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class NoticePage extends StatefulWidget {
  const NoticePage({Key? key}) : super(key: key);

  @override
  _NoticePageState createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
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
      body: Consumer<MessageProvider>(builder: (BuildContext context, data, Widget? child) {
        return ListView(
          children: [
            // 通知
            EluiCellComponent(
              title: FlutterI18n.translate(context, "app.setting.notice.switch.title"),
              label: FlutterI18n.translate(context, "app.setting.notice.switch.describe"),
              theme: EluiCellTheme(
                titleColor: Theme.of(context).textTheme.subtitle1?.color,
                labelColor: Theme.of(context).textTheme.subtitle2?.color,
                linkColor: Theme.of(context).textTheme.subtitle1?.color,
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
                titleColor: Theme.of(context).textTheme.subtitle1?.color,
                labelColor: Theme.of(context).textTheme.subtitle2?.color,
                linkColor: Theme.of(context).textTheme.subtitle1?.color,
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
                titleColor: Theme.of(context).textTheme.subtitle1?.color,
                labelColor: Theme.of(context).textTheme.subtitle2?.color,
                linkColor: Theme.of(context).textTheme.subtitle1?.color,
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
