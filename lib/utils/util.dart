import 'package:bfban/constants/api.dart';

class Util {
  /// [Event]
  /// 将判决类型转换为标签
  getCheaterStatusLabel(String? value) {
    Map _cheaterStatus = Config.action["child"];

    if (_cheaterStatus == null || value!.isEmpty) return '';

    return _cheaterStatus["value"];
  }
}
