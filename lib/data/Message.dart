/// 消息状态
class MessageStatus {
  // 当前详情消息
  dynamic data;
  bool? load;
  num total;
  MessageParams? params;

  MessageStatus({
    this.data,
    this.load = false,
    this.total = 0,
    this.params,
  });
}

///  消息参数
class MessageParams {
  num? id;

  String? type;

  MessageParams({
    this.id,
    this.type,
  });

  get toMap {
    return {
      "id": id,
      "type": type,
    };
  }
}

/// 极光状态
class MessageJiguanStatus {
  // 应用通知
  bool autoSwitchAppMessage;

  // 站内通知
  bool onSwitchSiteMessage;

  // tags
  List? AppMessageTags;

  MessageJiguanStatus({
    this.autoSwitchAppMessage = false,
    this.onSwitchSiteMessage = false,
    this.AppMessageTags,
  });
}
