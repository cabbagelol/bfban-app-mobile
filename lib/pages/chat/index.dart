import 'package:bfban/component/_Time/index.dart';
import 'package:bfban/component/_html/htmlWidget.dart';
import 'package:bfban/component/_loading/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/elui.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

import '../../constants/api.dart';
import '../../data/index.dart';
import '../../provider/chat_provider.dart';
import '../../utils/index.dart';
import '../not_found/index.dart';

class MessagePage extends StatefulWidget {
  /// 用户id
  final String? id;

  const MessagePage({
    super.key,
    this.id,
  });

  @override
  MessagePageState createState() => MessagePageState();
}

class MessagePageState extends State<MessagePage> {
  Future? futureBuilder;

  GlobalKey buttonGlobalKey = GlobalKey();

  /// 消息状态机
  ChatProvider? providerMessage;

  /// 滚动视图控制器
  ScrollController? listViewController = ScrollController();

  /// 文本控制器
  TextEditingController? textFieldController;

  /// 自身信息
  Map? selfInfo;

  /// 消息详情
  MessageStatus messageStatus = MessageStatus(
    load: false,
    data: {},
  );

  /// Ta用户信息
  StationUserInfoStatus userinfo = StationUserInfoStatus(
    data: StationUserInfoData(),
    parame: StationUserInfoParame(
      id: null,
      skip: 0,
      limit: 20,
    ),
    load: false,
  );

  Map? messageSendStatus = {
    "load": false,
    "data": {
      "toUserId": "",
      "type": "direct", // direct 聊天
      "content": "",
    },
  };

  double? semanticBoundsHeight = 80.0;

  @override
  void initState() {
    super.initState();

    semanticBoundsHeight = buttonGlobalKey.currentContext?.findRenderObject()!.semanticBounds.size.height;
    textFieldController = TextEditingController();
    selfInfo = ProviderUtil().ofUser(context).userinfo;
    providerMessage = ProviderUtil().ofChat(context);

    /// 取发消息用户id
    userinfo.parame!.id = int.parse(widget.id!);

    futureBuilder = _getUserInfo();

    /// 初始本地消息内容
    // _onLocal();
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
        userinfo.data!.setData(d);
      });
    }

    setState(() {
      userinfo.load = false;
    });

    return userinfo.data;
  }

  /// [Response]
  /// 发送聊天
  Future _setMessage() async {
    setState(() {
      messageSendStatus!["load"] = true;
    });

    // 更新
    messageSendStatus!["data"]["content"] = textFieldController!.text;
    messageSendStatus!["data"]["toUserId"] = widget.id;

    Response result = await HttpToken.request(
      Config.httpHost["user_message"],
      data: {
        "data": messageSendStatus!["data"],
      },
      method: Http.POST,
    );

    if (result.data["error"] != null && result.data["error"] >= 1) {
      EluiMessageComponent.error(context)(
        child: Text(result.data["message"]),
      );
    }

    setState(() {
      messageSendStatus!["load"] = false;
    });

    return result.data;
  }

  /// [Event]
  /// 发送按钮
  _healButton() {
    return () async {
      if (textFieldController!.text.toString().isEmpty) return;

      Map messageContent = {
        "username": selfInfo!["username"],
        "createTime": DateTime.now().toString(),
        "content": textFieldController!.text.toString(),
        "byUserId": selfInfo!["userId"],
        "toUserId": widget.id,
        "onLocal": true,
      };

      // 完成后发送
      Map messageResult = await _setMessage();
      // Map messageResult = {"success": 1};

      if (messageResult["success"] == 1) {
        // messageResult为true 成功发送并处理:

        // 插入本地消息
        providerMessage!.addData(messageContent);
        // 同时储存本地
        _setLocal(messageContent);

        listViewController!.jumpTo(listViewController!.position.maxScrollExtent);
        textFieldController!.text = "";
      }
    };
  }

  /// [Event]
  /// 储存消息
  _setLocal(Map data) async {
    Map localList = await providerMessage!.getLocalMessage();
    if (localList["child"] == null) {
      localList["child"] = [];
    }
    localList["child"].add(data);
    await Storage().set(providerMessage!.packageName, value: localList);
  }

  /// [Event]
  /// 对消息列表数据处理
  /// 排序 and 筛选
  _getData(ChatProvider data) {
    Time time = Time();
    List list = data.list;

    // 筛选
    list = list.where((item) {
      bool idValid = false;
      if (item["byUserId"].toString() == selfInfo!["userId"].toString() && widget.id.toString() == item["toUserId"].toString() || item["byUserId"].toString() == widget.id.toString()) {
        idValid = true;
      }
      return idValid;
    }).toList();

    // 排序
    list.sort((a, b) => time.parse(a["createTime"]).getExtendSecondDate.millisecondsSinceEpoch.toString().compareTo(time.parse(b["createTime"]).getExtendSecondDate.millisecondsSinceEpoch.toString()));

    return list;
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
                title: TextButton(
                  child: Wrap(
                    runAlignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text("${userinfo.data!.username} (${widget.id})"),
                      const SizedBox(width: 10),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                  onPressed: () {},
                ),
              ),
              body: Consumer<ChatProvider>(
                builder: (BuildContext context, data, Widget? child) {
                  return Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: ListView(
                          controller: listViewController,
                          children: _getData(data).toList().map<Widget>((e) {
                            if (e["onLocal"] != null && e["onLocal"] == true) {
                              // 我
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                child: Stack(
                                  alignment: AlignmentDirectional.topEnd,
                                  children: <Widget>[
                                    Container(
                                      margin: const EdgeInsets.only(right: 60, top: 10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: TimeWidget(data: e!["createTime"]),
                                          ),
                                          Text(
                                            selfInfo!["username"].toString(),
                                            style: TextStyle(
                                              color: Theme.of(context).textTheme.titleMedium!.color,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (selfInfo!["userAvatar"] != null)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: EluiImgComponent(
                                          width: 40,
                                          height: 40,
                                          src: selfInfo!["userAvatar"] ?? "",
                                        ),
                                      )
                                    else
                                      Container(
                                        margin: const EdgeInsets.only(top: 10),
                                        child: CircleAvatar(
                                          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                                          child: Text(selfInfo!["username"][0].toString()),
                                        ),
                                      ),
                                    Card(
                                      margin: const EdgeInsets.only(right: 60, top: 40),
                                      child: HtmlWidget(
                                        content: "<p>${e["content"]}</p>",
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              // 对话对方
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                child: Stack(
                                  children: <Widget>[
                                    CircleAvatar(
                                      child: Text(userinfo.data!.username![0].toString()),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(left: 60),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              userinfo.data!.username.toString(),
                                              style: TextStyle(
                                                color: Theme.of(context).textTheme.titleSmall!.color,
                                              ),
                                            ),
                                          ),
                                          TimeWidget(
                                            data: e!["createTime"],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Card(
                                      margin: const EdgeInsets.only(left: 60, top: 25),
                                      child: HtmlWidget(
                                        content: "<p>${e["content"]}</p>",
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: semanticBoundsHeight),
                    ],
                  );
                },
              ),
              bottomSheet: Container(
                key: buttonGlobalKey,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Card(
                        child: TextField(
                          controller: textFieldController,
                          maxLines: 1,
                          maxLength: 10,
                          decoration: InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                            isCollapsed: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                            hintText: FlutterI18n.translate(context, "basic.button.reply"),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: TextButton(
                        onPressed: _healButton(),
                        child: !messageSendStatus!["load"]
                            ? Text(FlutterI18n.translate(context, "basic.button.commit"))
                            : const SizedBox(
                                height: 20,
                                width: 20,
                                child: LoadingWidget(
                                  strokeWidth: 2,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          default:
            return Scaffold(
              appBar: AppBar(),
              body: const Center(
                child: LoadingWidget(),
              ),
            );
        }
      },
    );
  }
}
