import 'Captcha.dart';

/// 回复
class ReplyStatus {
  late bool? load;
  late ReplyData? data;
  late Captcha? captcha;

  ReplyStatus({
    this.load,
    this.data,
    this.captcha,
  });
}

/// 回复参数
class ReplyData {
  num? toPlayerId;
  num? toCommentId;
  String? content;
  num? toFloor;

  ReplyData({
    this.toPlayerId,
    this.toCommentId,
    this.content,
    this.toFloor,
  });

  get toMap {
    return {
      "data":  {
        "toPlayerId": toPlayerId,
        "toCommentId": toCommentId,
        "content": content,
        "toFloor": toFloor,
      },
    };
  }
}
