/// 消息中心

import 'package:bfban/provider/message_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

import '../../utils/index.dart';

class MessageListPage extends StatefulWidget {
  const MessageListPage({Key? key}) : super(key: key);

  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessageListPage> {
  final UrlUtil _urlUtil = UrlUtil();

  /// 消息转让
  MessageProvider? providerUtil;

  /// 自身信息
  Map? selfInfo;

  @override
  void initState() {
    super.initState();

    providerUtil = ProviderUtil().ofMessage(context);
    selfInfo = ProviderUtil().ofUser(context).userinfo;

    _onRefresh();
  }

  /// [Event]
  /// 刷新
  Future<void> _onRefresh() async {
    await providerUtil!.onUpDate();
  }

  /// [Evnet]
  /// 删除
  onDeleteMessage(num id) {
    providerUtil!.onDelete(id);
  }

  /// [Evnet]
  /// 已读
  onReadMessage(num id) {
    providerUtil!.onRead(id);
  }

  /// [Evnet]
  /// 未读
  onunReadMessage(num id) {
    providerUtil!.onUnread(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              _urlUtil.opEnPage(context, "/profile/notice");
              // await providerUtil!.delectLocalMessage();
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Consumer<MessageProvider>(
          builder: (BuildContext context, data, Widget? child) {
            return ListView.builder(
              itemCount: data.list
                  .where(
                      (element) => element["byUserId"] != selfInfo!["userId"])
                  .length
                  .toInt(),
              itemBuilder: (BuildContext context, int index) {
                Map i = data.list
                    .where(
                        (element) => element["byUserId"] != selfInfo!["userId"])
                    .toList()[index];

                return ListTile(
                  horizontalTitleGap: 10,
                  title: Wrap(
                    children: [
                      Text(
                        i["content"].toString(),
                        softWrap: true,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  leading: ExcludeSemantics(
                    child: CircleAvatar(
                      child: Text(
                          FlutterI18n.translate(context, i["haveRead"] == 0 ? "profile.message.tabsList.form.unread" : "profile.message.tabsList.form.read"),
                      ),
                    ),
                  ),
                  subtitle: Text(
                    Date().getFriendlyDescriptionTime(
                      i["createTime"].toString(),
                    ),
                    style: TextStyle(
                      color: Theme.of(context).textTheme.subtitle2!.color,
                    ),
                  ),
                  trailing: PopupMenuButton(
                    onSelected: (index) {
                      switch (index) {
                        case 1:
                          onReadMessage(i["id"]);
                          break;
                        case 2:
                          onunReadMessage(i["id"]);
                          break;
                        case 3:
                          onDeleteMessage(i["id"]);
                          break;
                        case 10:
                          _urlUtil.opEnPage(
                              context, "/message/detail/${i["id"]}");
                          break;
                        case 20:
                          _urlUtil.opEnPage(
                              context, "/message/${i["byUserId"]}");
                          break;
                      }
                    },
                    itemBuilder: (content) => <PopupMenuEntry>[
                      PopupMenuItem(
                        child: Text(FlutterI18n.translate(context, "profile.message.look")),
                        value: 10,
                      ),
                      PopupMenuItem(
                        child: Text(FlutterI18n.translate(context, "basic.button.reply")),
                        value: 20,
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        child: Text(FlutterI18n.translate(context, "profile.message.tabsList.form.read")),
                        value: 1,
                      ),
                      PopupMenuItem(
                        child: Text(FlutterI18n.translate(context, "profile.message.tabsList.form.unread")),
                        value: 2,
                      ),
                    ],
                  ),
                  onTap: () {
                    _urlUtil.opEnPage(context, "/message/${i["byUserId"]}");
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
