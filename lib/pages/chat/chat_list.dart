/// 消息中心

import 'package:bfban/component/_Time/index.dart';
import 'package:bfban/provider/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/_load/index.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

import '../../utils/index.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatListPage> {
  final UrlUtil _urlUtil = UrlUtil();

  /// 消息转让
  ChatProvider? providerUtil;

  /// 自身信息
  Map? selfInfo;

  bool chatRequestLoad = false;

  @override
  void initState() {
    super.initState();

    providerUtil = ProviderUtil().ofChat(context);
    selfInfo = ProviderUtil().ofUser(context).userinfo;

    _onRefresh();
  }

  /// [Event]
  /// 刷新
  Future<void> _onRefresh() async {
    setState(() {
      chatRequestLoad = true;
    });

    await providerUtil!.onUpDate();

    setState(() {
      chatRequestLoad = false;
    });
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
  onUnReadChat(num id) {
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
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: RefreshIndicator(
        displacement: 120,
        edgeOffset: MediaQuery.of(context).viewInsets.top,
        onRefresh: _onRefresh,
        child: Consumer<ChatProvider>(
          builder: (BuildContext context, data, Widget? child) {
            return ListView.builder(
              itemCount: data.list.where((element) => element["byUserId"] != selfInfo!["userId"]).length.toInt(),
              itemBuilder: (BuildContext context, int index) {
                Map i = data.list.where((element) => element["byUserId"] != selfInfo!["userId"]).toList()[index];

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
                      child: Icon(i["haveRead"] == 0 ? Icons.visibility : Icons.visibility_off),
                    ),
                  ),
                  subtitle: TimeWidget(
                    data: i["createTime"],
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
                          onUnReadChat(i["id"]);
                          break;
                        case 3:
                          onDeleteMessage(i["id"]);
                          break;
                        case 10:
                          _urlUtil.opEnPage(context, "/chat/detail/${i["id"]}");
                          break;
                        case 20:
                          _urlUtil.opEnPage(context, "/chat/${i["byUserId"]}");
                          break;
                      }
                    },
                    itemBuilder: (content) => <PopupMenuEntry>[
                      PopupMenuItem(
                        value: 10,
                        child: Text(FlutterI18n.translate(context, "profile.chat.look")),
                      ),
                      PopupMenuItem(
                        value: 20,
                        child: Text(FlutterI18n.translate(context, "basic.button.reply")),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: 1,
                        child: Text(FlutterI18n.translate(context, "profile.chat.tabsList.form.read")),
                      ),
                      PopupMenuItem(
                        value: 2,
                        child: Text(FlutterI18n.translate(context, "profile.chat.tabsList.form.unread")),
                      ),
                    ],
                  ),
                  onTap: () {
                    _urlUtil.opEnPage(context, "/chat/${i["byUserId"]}");
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
