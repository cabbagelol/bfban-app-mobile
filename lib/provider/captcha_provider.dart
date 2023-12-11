import 'package:flutter/foundation.dart';

class CaptchaProvider with ChangeNotifier {
  // 包名
  String packageName = "captcha";

  Map record = {};

  void set(String key, int value) {
    if (key.isEmpty || value.isNaN) return;
    record[key] = value;
    notifyListeners();
  }

  int get(String key) {
    if (key.isEmpty) return -1;
    int res = record[key] ?? -1;
    notifyListeners();
    return res;
  }

  rem(String key) {
    record.remove(key);
  }
}
