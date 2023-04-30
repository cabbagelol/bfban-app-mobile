import 'package:bfban/constants/api.dart';

class Util {
  /// [Event]
  /// 对比行为名称
  /// 这里为的是从字典取得国际化，同时解决旧数据库行为值兼容
  queryAction(key) {
    String _key = key;
    List action = Config.action["child"] ?? [];
    if (action.isNotEmpty) {
      for (int i = 0; i < action.length; i++) {
        if (action[i]["values"].contains(key)) _key = action[i]["value"];
      }
    }
    return _key;
  }

  /// [Event]
  /// 将判决类型转换为标签
  getCheaterStatusLabel(String? value) {
    Map cheaterStatus = Config.action["child"] ?? {};

    if (value!.isEmpty) return "";

    return cheaterStatus["value"];
  }

  /// [Event]
  /// 查询作弊方法词汇
  queryCheatMethodsGlossary(String key) {
    List cheatMethodsGlossary = Config.cheatMethodsGlossary["child"] ?? [];
    if (cheatMethodsGlossary.isNotEmpty) {
      for (int i = 0; i < cheatMethodsGlossary.length; i++) {
        if (cheatMethodsGlossary[i]["values"].contains(key)) key = cheatMethodsGlossary[i]["value"];
      }
    }
    return key;
  }

  /// [Event]
  ///
  onReplacementStringVariable(String text, Map params) {
    for (var i in params.entries) {
      text = text.replaceAll("{${i.key}}", i.value);
    }
    return text;
  }
}
