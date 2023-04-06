import 'Captcha.dart';

/// 回复
class ReplyStatus {
  late bool? load;
  late ReplyStatusParame? parame;

  ReplyStatus({
    this.load,
    this.parame,
  });

}

/// 回复参数
class ReplyStatusParame extends Captcha  {
  num? toPlayerId;
  dynamic toCommentId;
  String? content;

  ReplyStatusParame({
    this.toPlayerId,
    this.toCommentId,
    this.content
  });

  get toMap {
    Map map = {
      "data":  {
        "toPlayerId": toPlayerId,
        "toCommentId": toCommentId,
        "content": content
      },
    };
    map.addAll(captchaToMap);
    return map;
  }
}
