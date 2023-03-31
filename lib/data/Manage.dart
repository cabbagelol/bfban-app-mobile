import 'Captcha.dart';

/// 裁判
class ManageStatus {
  late bool? load;
  late ManageData? parame;

  ManageStatus({
    this.load,
    this.parame,
  });
}

/// 裁判参数
class ManageData {
  // 描述内容
  late String? content;

  // 判决类型 如石锤
  late String? action;

  // 行为 如透视
  late List? cheatMethods;

  // 玩家id
  late String? toPlayerId;

  late Captcha? captcha;

  ManageData({
    this.captcha,
    this.content,
    this.action,
    this.cheatMethods,
    this.toPlayerId,
  });

  get toMap {
    Map map = {
      "data": {
        "content": content,
        "action": action,
        "toPlayerId": toPlayerId,
        "cheatMethods": ["kill", "guilt"].contains(action) ? cheatMethods : null
      },
      "encryptCaptcha": captcha!.hash,
      "captcha": captcha!.value,
    };
    return map;
  }
}
