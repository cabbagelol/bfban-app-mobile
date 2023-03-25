/// 聊天窗口

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/elui.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

import '../../constants/api.dart';
import '../../data/index.dart';
import '../../provider/message_provider.dart';
import '../../utils/index.dart';

class MessagePage extends StatefulWidget {
  /// 用户id
  final String? id;

  const MessagePage({
    Key? key,
    this.id,
  }) : super(key: key);

  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  Future? futureBuilder;

  GlobalKey buttonGlobalKey = GlobalKey();

  /// 消息状态机
  MessageProvider? providerMessage;

  /// 滚动视图控制器
  ScrollController? listViewController = ScrollController();

  /// 文本控制器
  TextEditingController? textFieldcontroller;

  /// 自身信息
  Map? selfInfo;

  /// 消息详情
  MessageStatus messageStatus = MessageStatus(
    data: {},
  );

  /// Ta用户信息
  UserInfoStatuc userinfo = UserInfoStatuc(
    data: {},
    parame: UserInfoParame(
      id: "",
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

  double? H = 80.0;

  @override
  void initState() {
    super.initState();

    H = buttonGlobalKey.currentContext?.findRenderObject()!.semanticBounds.size.height;
    textFieldcontroller = TextEditingController();
    selfInfo = ProviderUtil().ofUser(context).userinfo;
    providerMessage = ProviderUtil().ofMessage(context);

    /// 取发消息用户id
    userinfo.parame!.id = widget.id;

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
        userinfo.data = d;
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
    messageSendStatus!["data"]["content"] = textFieldcontroller!.text;
    messageSendStatus!["data"]["toUserId"] = widget.id;

    Response result = await Http.request(
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
      if (textFieldcontroller!.text.toString().isEmpty) return;

      Map messageContent = {
        "username": selfInfo!["username"],
        "createTime": DateTime.now().toString(),
        "content": textFieldcontroller!.text.toString(),
        "byUserId": selfInfo!["userId"],
        "toUserId": widget.id,
        "onLoacl": true,
      };

      // 完成后发送
      // Map messageResult = await _setMessage();
      Map messageResult = {"success": 1};

      if (messageResult["success"] == 1) {
        // messageResult为true 成功发送并处理:

        // 插入本地消息
        providerMessage!.addData(messageContent);
        // 同时储存本地
        _setLoacl(messageContent);

        listViewController!.jumpTo(listViewController!.position.maxScrollExtent);
        textFieldcontroller!.text = "";
      }
    };
  }

  /// [Event]
  /// 储存消息
  _setLoacl(Map data) async {
    Map loaclList = await providerMessage!.getLocalMessage();
    if (loaclList["child"] == null) {
      loaclList["child"] = [];
    }
    loaclList["child"].add(data);
    await Storage().set(providerMessage!.packageName, value: jsonEncode(loaclList));
  }

  /// [Event]
  /// 对消息列表数据处理
  /// 排序 and 筛选
  _getData(MessageProvider data) {
    Date date = Date();
    List list = data.list;

    // 筛选
    list = list.where((item) {
      var _is = false;
      if (item["byUserId"].toString() == selfInfo!["userId"].toString() && widget.id.toString() == item["toUserId"].toString() || item["byUserId"].toString() == widget.id.toString()) {
        _is = true;
      }
      return _is;
    }).toList();

    // 排序
    list.sort((a, b) => date.getTurnTheTimestamp(a["createTime"])["millisecondsSinceEpoch"].compareTo(date.getTurnTheTimestamp(b["createTime"])["millisecondsSinceEpoch"]));

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureBuilder,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: TextButton(
                  child: Wrap(
                    runAlignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text("${userinfo.data!["username"]} (${widget.id})"),
                      const SizedBox(width: 10),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                  onPressed: () {},
                ),
              ),
              body: Consumer<MessageProvider>(
                builder: (BuildContext context, data, Widget? child) {
                  return Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: ListView(
                          controller: listViewController,
                          children: _getData(data).toList().map<Widget>((e) {
                            if (e["onLoacl"] != null && e["onLoacl"] == true) {
                              // 我
                              return Container(
                                child: Stack(
                                  alignment: AlignmentDirectional.topEnd,
                                  children: <Widget>[
                                    Container(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Text(Date().getFriendlyDescriptionTime(e!["createTime"]).toString()),
                                          ),
                                          Text(
                                            selfInfo!["username"].toString(),
                                            style: TextStyle(
                                              color: Theme.of(context).textTheme.subtitle2!.color,
                                            ),
                                          ),
                                        ],
                                      ),
                                      margin: const EdgeInsets.only(right: 60, top: 10),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      child: CircleAvatar(
                                        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                                        child: Text(selfInfo!["username"][0].toString()),
                                      ),
                                    ),
                                    Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Html(
                                          data: e["content"].toString(),
                                        ),
                                      ),
                                      margin: const EdgeInsets.only(right: 60, top: 40),
                                    ),
                                  ],
                                ),
                                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              );
                            } else {
                              // 对话对方
                              return Container(
                                child: Stack(
                                  children: <Widget>[
                                    CircleAvatar(
                                      child: Text(userinfo.data!["username"][0].toString()),
                                    ),
                                    Container(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              userinfo.data!["username"].toString(),
                                              style: TextStyle(
                                                color: Theme.of(context).textTheme.subtitle2!.color,
                                              ),
                                            ),
                                          ),
                                          Text(Date().getFriendlyDescriptionTime(e!["createTime"]).toString()),
                                        ],
                                      ),
                                      margin: const EdgeInsets.only(left: 60),
                                    ),
                                    Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Html(
                                          data: e["content"].toString(),
                                        ),
                                      ),
                                      margin: const EdgeInsets.only(left: 60, top: 25),
                                    ),
                                  ],
                                ),
                                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              );
                            }
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: H),
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
                      child: Card(
                        child: TextField(
                          controller: textFieldcontroller,
                          maxLines: null,
                          maxLength: 10,
                          decoration: InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 10),
                            hintText: FlutterI18n.translate(context, "basic.button.reply"),
                          ),
                        ),
                      ),
                      flex: 1,
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      child: TextButton(
                        onPressed: _healButton(),
                        child: !messageSendStatus!["load"]
                            ? Text(FlutterI18n.translate(context, "basic.button.commit"))
                            : const SizedBox(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                                height: 20,
                                width: 20,
                              ),
                      ),
                    ),
                  ],
                ),
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
