// ignore: file_names
import './Captcha.dart';

/// 登录状态
class LoginStatus {
  bool? load;
  LoginStatusParame? parame;

  LoginStatus({
    this.load = false,
    this.parame,
  });
}

class LoginStatusParame extends Captcha implements CaptchaCookie {
  String? username;
  String? password;

  LoginStatusParame({
    this.username,
    this.password,
    this.cookie,
  });

  get toMap {
    Map map = {
      "data": {
        "username": username,
        "password": password,
      }
    };
    map.addAll(captchaToMap);
    return map;
  }

  @override
  String? cookie;
}
