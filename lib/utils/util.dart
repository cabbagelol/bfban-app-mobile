import 'package:bfban/constants/api.dart';

class Util {
  /// [Event]
  /// 将判决类型转换为标签
  getCheaterStatusLabel(String? value) {
    Map _cheaterStatus = Config.action["child"];

    if (value!.isEmpty) return '';

    return _cheaterStatus["value"];
  }

  queryCheatMethodsGlossary (String key, List<dynamic> cheatMethodsGlossary) {
    String _key = key;
    List _cheatMethodsGlossary = cheatMethodsGlossary;
    if (_cheatMethodsGlossary.isNotEmpty) {
      for (int i = 0; i < _cheatMethodsGlossary.length; i++) {
        if (_cheatMethodsGlossary[i]["values"].contains(key)) _key =_cheatMethodsGlossary[i]["value"];
      }
    }
    return _key;
  }
}
