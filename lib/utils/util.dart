import 'package:bfban/constants/api.dart';

class Util {
  /// [Event]
  /// 将判决类型转换为标签
  getCheaterStatusLabel(String? value) {
    Map cheaterStatus = Config.action["child"];

    if (value!.isEmpty) return '';

    return cheaterStatus["value"];
  }

  queryCheatMethodsGlossary (String key, List<dynamic> cheatMethodsGlossary) {
    if (cheatMethodsGlossary.isNotEmpty) {
      for (int i = 0; i < cheatMethodsGlossary.length; i++) {
        if (cheatMethodsGlossary[i]["values"].contains(key)) key = cheatMethodsGlossary[i]["value"];
      }
    }
    return key;
  }
}
