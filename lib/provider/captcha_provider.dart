import 'package:flutter/foundation.dart';

class CaptchaProvider with ChangeNotifier {
  // 包名
  String packageName = "captcha";

  Map record = {};

  set (String key,int value) {
    record[key] = value;
    notifyListeners();
  }

  int get (String key) {
    int res = record[key] ?? -1;
    notifyListeners();
    return res;
  }

  rem (String key) {
    record.remove(key);
  }
}