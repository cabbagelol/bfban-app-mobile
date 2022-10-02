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

  get toMap {
    return {
      "data":  {
        "toPlayerId": data!.toPlayerId,
        "toCommentId": data!.toCommentId,
        "content": data!.content
      },
      "encryptCaptcha": captcha!.hash,
      "captcha": captcha!.value
    };
  }
}

/// 回复参数
class ReplyData {
  num? toPlayerId;
  dynamic? toCommentId;
  String? content;

  ReplyData({
    this.toPlayerId,
    this.toCommentId,
    this.content
  });
}
