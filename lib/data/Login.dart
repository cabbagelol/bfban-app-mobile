import './Captcha.dart';

/// 登录状态
class LoginStatus {
  late bool load;
  late Captcha? captcha;
  late String? username;
  late String? password;

  LoginStatus({
    this.load = false,
    this.captcha,
    this.username,
    this.password,
  });

  get toMap {
    return {
      "username": username,
      "password": password,
    };
  }
}