/// 消息中心
library;

import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/_message/index.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

import '/component/_time/index.dart';
import '/component/_loading/index.dart';
import '/provider/chat_provider.dart';
import '/component/_refresh/index.dart';
import '/utils/index.dart';
import '../not_found/index.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatListPage> {
  final UrlUtil _urlUtil = UrlUtil();

  /// 列表
  final GlobalKey<RefreshState> _refreshKey = GlobalKey<RefreshState>();

  /// 消息转让
  ChatProvider? providerUtil;

  /// 异步
  Future? futureBuilder;

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
  Future _onRefresh() async {
    if (!mounted) return;

    setState(() {
      chatRequestLoad = true;
    });

    futureBuilder = providerUtil!.onUpDate();

    _refreshKey.currentState?.controller.finishRefresh();
    _refreshKey.currentState?.controller.resetFooter();

    setState(() {
      chatRequestLoad = false;
    });
  }

  /// [Evnet]
  /// 删除
  onDeleteMessage(num id) {
    try {
      providerUtil!.onDelete(id);
    } catch (E) {
      EluiMessageComponent.error(context)(child: Text(E.toString()));
    }
  }

  /// [Evnet]
  /// 已读
  onReadMessage(num id) {
    try {
      providerUtil!.onRead(id);
    } catch (E) {
      EluiMessageComponent.error(context)(child: Text(E.toString()));
    }
  }

  /// [Evnet]
  /// 未读
  onUnReadChat(num id) {
    try {
      providerUtil!.onUnread(id);
    } catch (E) {
      EluiMessageComponent.error(context)(child: Text(E.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureBuilder,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            if (snapshot.data == null) {
              return const NotFoundPage();
            }

            return Scaffold(
              appBar: AppBar(
                title: Text(FlutterI18n.translate(context, "profile.chat.title")),
                actions: [
                  IconButton(
                    padding: const EdgeInsets.all(16),
                    onPressed: () async {
                      _urlUtil.opEnPage(context, "/profile/notice");
                    },
                    icon: const Icon(Icons.settings),
                  ),
                ],
              ),
              body: Refresh(
                key: _refreshKey,
                edgeOffset: MediaQuery.of(context).padding.top + kTextTabBarHeight,
                onRefresh: _onRefresh,
                child: Consumer<ChatProvider>(
                  builder: (BuildContext context, data, Widget? child) {
                    return ListView.separated(
                      separatorBuilder: (BuildContext context, int index) => const Divider(indent: 10),
                      itemCount: data.list.length.toInt(),
                      itemBuilder: (BuildContext context, int index) {
                        Map i = data.list[index];

                        return ListTile(
                          title: Wrap(
                            children: [
                              Text(
                                i["content"].toString(),
                                softWrap: true,
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 2,
                              ),
                            ],
                          ),
                          leading: ExcludeSemantics(
                            child: CircleAvatar(
                              child: Icon(i["haveRead"] == 0 ? Icons.visibility : Icons.visibility_off),
                            ),
                          ),
                          subtitle: Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children: [
                              if (!['reply', 'direct'].contains(i['type']))
                                Card.outlined(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 5),
                                    constraints: BoxConstraints(minHeight: 15),
                                    child: Text(
                                      FlutterI18n.translate(context, "profile.chat.types.${i["type"]}.text"),
                                    ),
                                  ),
                                ),
                              Card.outlined(
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                  constraints: BoxConstraints(minHeight: 15),
                                  child: TimeWidget(
                                    data: i["createTime"],
                                    style: TextStyle(
                                      color: Theme.of(context).textTheme.labelLarge!.color,
                                    ),
                                  ),
                                ),
                              ),
                              Card.outlined(
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                  constraints: BoxConstraints(minHeight: 15),
                                  child: Text(
                                    "${i["byUserId"] ?? 'N/A'}",
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            iconColor: Theme.of(context).iconTheme.color,
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
          default:
            return Scaffold(
              appBar: AppBar(
                actions: [
                  IconButton(
                    padding: const EdgeInsets.all(16),
                    onPressed: () async {
                      _urlUtil.opEnPage(context, "/profile/notice");
                    },
                    icon: const Icon(Icons.settings),
                  ),
                ],
              ),
              body: const Center(
                child: LoadingWidget(),
              ),
            );
        }
      },
    );
  }
}
