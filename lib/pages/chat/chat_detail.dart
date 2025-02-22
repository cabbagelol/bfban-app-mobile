import 'package:bfban/component/_loading/index.dart';
import 'package:bfban/data/index.dart';
import 'package:bfban/utils/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../constants/api.dart';
import '../../provider/chat_provider.dart';
import '../not_found/index.dart';

/// 消息详情

class ChatDetailPage extends StatefulWidget {
  // 消息id
  final String? id;

  const ChatDetailPage({
    super.key,
    required this.id,
  });

  @override
  ChatDetailPageState createState() => ChatDetailPageState();
}

class ChatDetailPageState extends State<ChatDetailPage> {
  final UrlUtil _urlUtil = UrlUtil();

  Future? futureBuilder;

  ChatProvider? providerMessage;

  /// 消息详情
  MessageStatus messageStatus = MessageStatus(
    data: {},
  );

  /// 站内用户信息
  StationUserInfoStatus userinfo = StationUserInfoStatus(
    data: StationUserInfoData(),
    parame: StationUserInfoParame(
      id: null,
      skip: 0,
      limit: 20,
    ),
    load: false,
  );

  @override
  void initState() {
    super.initState();
    providerMessage = ProviderUtil().ofChat(context);

    /// 现在从本地状态中查询
    messageStatus.data = providerMessage!.list.where((i) => i["id"].toString() == widget.id.toString()).toList()[0];

    /// 取发消息用户id
    userinfo.parame!.id = int.parse(messageStatus.data["byUserId"].toString());

    futureBuilder = _getUserInfo();
  }

  /// [Response]
  /// 获取用户数据
  Future _getUserInfo() async {
    setState(() {
      userinfo.load = true;
    });

    Response result = await HttpToken.request(
      Config.httpHost["user_info"],
      parame: userinfo.parame!.toMap,
      method: Http.GET,
    );

    if (result.data["success"] == 1) {
      final d = result.data["data"];

      setState(() {
        userinfo.data!.setData(d);
      });
    }

    setState(() {
      userinfo.load = false;
    });

    return userinfo.data!.toMap;
  }

  /// [Event]
  /// 查看用户ID信息
  openPlayerDetail(id) {
    return () {
      _urlUtil.opEnPage(context, '/account/$id');
    };
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
                centerTitle: true,
                title: Text(userinfo.data!.username.toString()),
              ),
              body: Column(
                children: [
                  ListTile(
                    leading: ExcludeSemantics(
                      child: CircleAvatar(
                        child: Text(userinfo.data!.username![0]),
                      ),
                    ),
                    title: Text(userinfo.data!.username.toString()),
                    subtitle: Text(userinfo.data!.id.toString()),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: openPlayerDetail(userinfo.data!.id),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: Html(
                      data: messageStatus.data["content"],
                    ),
                  ),
                ],
              ),
            );
          default:
            return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: Text(userinfo.data!.username.toString()),
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
