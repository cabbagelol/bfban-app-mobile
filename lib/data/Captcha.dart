/// 验证码
library;

enum CaptchaType {
  None(value: 'none'),
  SVG(value: 'svg'),
  TURNSTILE(value: 'Turnstile');

  final String value;

  const CaptchaType({
    required this.value,
  });
}

class Captcha {
  CaptchaBaseType? captcha;

  set value(value) {
    if (captcha != null) captcha?.value = value;
  }

  get value => captcha!.value ?? '';

  Captcha({
    captcha,
  });

  /// 设置Captcha
  setCaptcha(CaptchaBaseType captcha) {
    this.captcha = captcha;
    return captchaToMap;
  }

  get captchaToMap => {
        "captcha": captcha?.toMap,
      };
}

// 验证基座
class CaptchaBaseType {
  CaptchaType captchaType = CaptchaType.None;

  // 用户输入
  String value = "";

  get toMap => {"captchaType": captchaType.value, "response": value};
}

// svg验证
class CaptchaSvg extends CaptchaBaseType {
  @override
  CaptchaType captchaType = CaptchaType.SVG;

  /// Captcha 验证 code
  String encryptCaptcha;

  /// Svg node
  String captchaSvg;

  /// 验证hash, 用户输入
  String response;

  /// 实现输入
  @override
  set value(value) {
    response = value;
  }

  @override
  get value => response;

  CaptchaSvg({
    this.encryptCaptcha = "",
    this.captchaSvg = "",
    this.response = "",
  });

  @override
  get toMap => {
        "captchaType": captchaType.value,
        "encryptCaptcha": encryptCaptcha,
        "response": response,
      };
}

// cf turnstile 验证
class CaptchaTurnstile extends CaptchaBaseType {
  @override
  CaptchaType captchaType = CaptchaType.TURNSTILE;

  /// 验证hash, 用户输入
  String response;

  /// 实现输入
  @override
  set value(value) {
    response = value;
  }

  @override
  get value => response;

  CaptchaTurnstile({
    this.response = "",
  });

  @override
  get toMap => {
        "captchaType": captchaType.value,
        "response": response,
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
