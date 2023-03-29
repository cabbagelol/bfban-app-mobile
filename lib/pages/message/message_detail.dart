import 'package:bfban/data/index.dart';
import 'package:bfban/utils/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../constants/api.dart';
import '../../provider/message_provider.dart';
import '../not_found/index.dart';

/// 消息详情

class MessageDetailPage extends StatefulWidget {
  // 消息id
  final String? id;

  const MessageDetailPage({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  _messageDetailPageState createState() => _messageDetailPageState();
}

class _messageDetailPageState extends State<MessageDetailPage> {
  final UrlUtil _urlUtil = UrlUtil();

  Future? futureBuilder;

  MessageProvider? providerMessage;

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
    providerMessage = ProviderUtil().ofMessage(context);

    /// TODO 暂无查询详情接口
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

    Response result = await Http.request(
      Config.httpHost["user_info"],
      parame: userinfo.parame!.toMap,
      method: Http.GET,
    );

    if (result.data["success"] == 1) {
      final d = result.data["data"];

      setState(() {
        userinfo.data = d;
      });
    }

    setState(() {
      userinfo.load = false;
    });

    return userinfo.data;
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
            if(snapshot.data == null) {
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
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
              ),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
        }
      },
    );
  }
}
