
/// 验证码
class Captcha {
  // 用户输入的验证
  late String value;

  // 获取的验证svg
  late dynamic captchaSvg;

  // 验证hash
  late String hash;

  // 验证cookie
  late String cookie;

  // 是否加载
  late bool load;

  Captcha({
    this.value = "",
    this.captchaSvg,
    this.hash = "",
    this.cookie = "",
    this.load = false,
  });
}