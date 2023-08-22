
import 'package:flutter/cupertino.dart';
// import 'package:jpush_flutter/jpush_flutter.dart';

import '../constants/api.dart';
import '../data/index.dart';
import '../utils/index.dart';

enum MessageType {
  none,
  read,
  unread,
  del,
}

class ChatProvider with ChangeNotifier {
  // 包名
  String packageName = "user.chat";

  // 极光
  // JPush jpush = JPush();

  // 通知列表
  List _list = [];

  // 极光管理
  MessageJiguanStatus messageJiguanStatus = MessageJiguanStatus(
    autoSwitchAppMessage: true,
    onSwitchSiteMessage: false,
    AppMessageTags: [
      {
        "value": "user",
        "edit": false,
      }
    ],
  );

  // 消息管理
  MessageStatus messageStatus = MessageStatus(
    load: false,
    params: MessageParams(
      id: 0,
      type: "",
    ),
    total: 0,
  );

  final Storage _storage = Storage();

  init() {
    initJIGUANG();
  }

  /// 极光初始
  initJIGUANG() async {
    Map loaclMessage = await getLocalMessage();

    if (loaclMessage["onSwitchSiteMessage"] != null) messageJiguanStatus.onSwitchSiteMessage = loaclMessage["onSwitchSiteMessage"];
    if (loaclMessage["autoSwitchAppessage"] != null) messageJiguanStatus.autoSwitchAppMessage = loaclMessage["autoSwitchAppessage"];
    if (loaclMessage["tags"] != null) messageJiguanStatus.AppMessageTags = loaclMessage["tags"];

    // jpush.setAlias("bfban.app");

    // 设置身份标签
    if (loaclMessage["tags"] != null) {
      List<String> tags = [];
      for (var i in messageJiguanStatus.AppMessageTags!) {
        tags.add(i["value"]);
      }
      // jpush.setTags(tags);
    }

    notifyListeners();
  }

  /// [Event]
  /// 极光Tag添加
  void onJiguanAddTag(String name, bool edit) async {
    Map _tag = {"value": name, "edit": true};
    messageJiguanStatus.AppMessageTags!.add(_tag);

    // 极光配置
    // jpush.addTags([name]);

    await setLoaclMessage();

    notifyListeners();
  }

  /// [Event]
  /// 极光推送开关
  void onJiguanPush() async {
    messageJiguanStatus.autoSwitchAppMessage ? resumePush() : stopPush();
    await setLoaclMessage();
    notifyListeners();
  }

  /// [Event]
  /// 极光
  /// 停止推送
  Future stopPush() async {
    messageJiguanStatus.autoSwitchAppMessage = false;
    // await jpush.stopPush();
    return true;
  }

  /// [Event]
  /// 极光
  /// 重新接收推送
  Future resumePush() async {
    messageJiguanStatus.autoSwitchAppMessage = true;
    // await jpush.resumePush();
    return true;
  }

  /// [Response]
  /// 消息接口
  /// 获取消息
  Future _api() async {
    messageStatus.load = true;
    _list = [];

    Response result = await Http.request(
      Config.httpHost["user_message"],
      method: Http.GET,
    );

    if (result.data["success"] == 1) {
      final d = result.data["data"];
      int total = 0;
      _list = d["messages"];
      for (var e in _list) {
        if (e["haveRead"] == 0) {
          total += 1;
        }
      }
      messageStatus.total = total;
    }

    messageStatus.load = false;
    notifyListeners();
    return result.data;
  }

  /// [Response]
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
          for (var i = 0; i < _list.length; i++) {
            if (_list[i]["id"] == id) {
              _list[i]["haveRead"] = 0;
            }
          }
          break;
        case MessageType.read:
          for (var i = 0; i < _list.length; i++) {
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
  Future _onLocal() async {
    Map list = await getLocalMessage();

    if (list.isNotEmpty) {
      await addAllData(list["child"]);
    }

    return true;
  }

  /// [Event]
  /// 读取本地消息内容
  Future<Map> getLocalMessage() async {
    StorageData userChatData = await _storage.get(packageName);
    dynamic localChat = userChatData.value;

    if (userChatData.code == 0) {
      return localChat;
    }

    return {};
  }

  /// [Event]
  /// 清除本地所有储存
  Future delectLocalMessage() async {
    await Storage().remove(packageName);

    return true;
  }

  Future setLoaclMessage() async {
    Map data = await getLocalMessage();

    data["child"] = data["child"] ?? [];
    data["autoSwitchAppessage"] = messageJiguanStatus.autoSwitchAppMessage;
    data["onSwitchSiteMessage"] = messageJiguanStatus.onSwitchSiteMessage;
    data["tags"] = messageJiguanStatus.AppMessageTags;

    await Storage().set(packageName, value: data);

    notifyListeners();
    return true;
  }

  /// [Event]
  /// 插入数据
  addData(Map data) {
    if (data.isEmpty) return;
    _list.add(data);
    notifyListeners();
  }

  /// [Event]
  /// 插入数据
  Future addAllData(List data) async {
    if (data.isNotEmpty) {
      _list.addAll(data);
    }
    notifyListeners();
    return _list;
  }

  /// [Event]
  /// 更新消息
  Future onUpDate() async {
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
