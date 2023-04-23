import 'Captcha.dart';

/// 裁判
class ManageStatus {
  late bool? load;
  late ManageParame? parame;

  ManageStatus({
    this.load,
    this.parame,
  });
}

/// 裁判参数
class ManageParame extends Captcha {
  // 描述内容
  late String? content;

  // 判决类型 如石锤
  late String? action;

  // 行为 如透视
  late List? cheatMethods;

  // 玩家id
  late String? toPlayerId;

  ManageParame({
    this.content,
    this.action,
    this.cheatMethods,
    this.toPlayerId,
  });

  Map<String, dynamic> get toMap {
    Map<String, dynamic> map = {
      "data": {
        "content": content,
        "action": action,
        "toPlayerId": toPlayerId,
        "cheatMethods": ["kill", "guilt"].contains(action) ? cheatMethods : null
      },
    };
    map.addAll(captchaToMap);
    return map;
  }
}
