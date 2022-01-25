/// 消息通知管理
/// 内置api

import 'dart:convert';

import 'package:flutter/cupertino.dart';


import '../constants/api.dart';
import '../data/index.dart';
import '../utils/index.dart';

enum MessageType {
  none,
  read,
  unread,
  del,
}

class MessageProvider with ChangeNotifier {
  // 通知列表
  List _list = [];

  // 消息管理
  MessageStatus messageStatus = MessageStatus(
    load: false,
    params: MessageParams(
      id: 0,
      type: "",
    ),
    total: 0,
  );

  /// 消息接口
  /// 获取消息
  Future _api() async {
    messageStatus.load = true;
    notifyListeners();

    Response result = await Http.request(
      Config.httpHost["user_message"],
      method: Http.GET,
    );

    if (result.data["success"] == 1) {
      final d = result.data["data"];
      _list = d["messages"];
      messageStatus.total = d["total"];
    }

    messageStatus.load = false;
    notifyListeners();

    return result.data;
  }

  /// 消息接口
  /// 管理消息
  Future<bool> _api_mark(dynamic id, MessageType typeIndex) async {
    Map type = {
      MessageType.read: "read",
      MessageType.unread: "unread",
      MessageType.del: "del",
    };

    // 更新
    messageStatus.params!.id = id;
    messageStatus.params!.type = type[typeIndex];

    messageStatus.load = true;
    notifyListeners();

    Response result = await Http.request(
      Config.httpHost["user_message_mark"],
      parame: messageStatus.params!.toMap,
      method: Http.POST,
    );

    if (result.data["success"] == 1) {
      switch (typeIndex) {
        case MessageType.del:
          // 删除本地列表的对应id
          _list.removeWhere((element) => element["id"] == id);
          break;
        case MessageType.unread:
          for(var i = 0; i < _list.length; i++) {
            if (_list[i]["id"] == id) {
              _list[i]["haveRead"] = 0;
            }
          }
          break;
        case MessageType.read:
          for(var i = 0; i < _list.length; i++) {
            if (_list[i]["id"] == id) {
              _list[i]["haveRead"] = 1;
            }
          }
          break;
        case MessageType.none:
          // TODO: Handle this case.
          break;
      }

      notifyListeners();
      return true;
    }

    messageStatus.load = false;

    notifyListeners();
    return false;
  }

  /// [Event]
  /// 处理列表 用于同步状态机
  _onLocal() async {
    Map list = await getLocalMessage();

    addAllData(list["child"]);
  }

  /// [Event]
  /// 读取本地消息内容
  Future<Map> getLocalMessage() async {
    dynamic loacl = await Storage().get("com.bfban.message");

    if (loacl != null) {
      return jsonDecode(loacl);
    }

    return {};
  }

  /// [Event]
  /// 清楚本地所有储存
  Future delectLocalMessage () async {
    await Storage().remove("com.bfban.message");

    return true;
  }

  /// [Event]
  /// 插入数据
  addData (Map data) {
    if (data.isEmpty) return;
    _list.add(data);
    notifyListeners();
  }

  /// [Event]
  /// 插入数据
  addAllData (List data) {
    if (data.isEmpty) return;
    _list.addAll(data);
    notifyListeners();
  }

  /// [Event]
  /// 更新消息
  Future<bool> onUpDate() async {
    await _api();
    await _onLocal();
    return true;
  }

  /// [Event]
  /// 删除
  onDelete(dynamic id) {
    _api_mark(id, MessageType.del);
  }

  /// [Event]
  /// 未读
  onRead(dynamic id) {
    _api_mark(id, MessageType.read);
  }

  /// [Event]
  /// 未读
  onUnread(dynamic id) {
    _api_mark(id, MessageType.unread);
  }

  /// 列表是否空
  bool get isNull => _list.isEmpty;

  num get length => _list.length;

  List get list => _list;

  num? get total => messageStatus.total;
}
