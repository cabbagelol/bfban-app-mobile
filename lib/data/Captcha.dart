/// 验证码
class Captcha {
  /// Captcha 验证 code
  String encryptCaptcha;

  /// Svg node
  String captchaSvg;

  /// 验证hash, 用户输入
  String value;

  Captcha({
    this.encryptCaptcha = "",
    this.captchaSvg = "",
    this.value = "",
  });

  /// 设置Captcha
  setCaptcha(Captcha captcha) {
    encryptCaptcha = captcha.encryptCaptcha;
    captchaSvg = captcha.captchaSvg;
    value = captcha.value;
    return captchaToMap;
  }

  get captchaToMap => {
        "encryptCaptcha": encryptCaptcha,
        "captcha": value,
      };
}

abstract class CaptchaCookie {
  /// 验证cookie
  String? cookie;

  CaptchaCookie({
    this.cookie,
  });
}

class CaptchaStatus extends Captcha implements CaptchaCookie {
  /// 是否加载
  bool? load;

  CaptchaStatus({
    this.load = false,
    this.cookie = "",
  });

  @override
  String? cookie;
}
