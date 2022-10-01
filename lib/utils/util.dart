import 'package:bfban/constants/api.dart';
import 'package:flutter_translate/flutter_translate.dart';

class Util {
  /// [Event]
  /// 将判决类型转换为标签
  getCheaterStatusLabel(String? value) {
    Map _cheaterStatus = Config.action["child"];

    if (_cheaterStatus == null || value!.isEmpty) return '';

    return _cheaterStatus["value"];
    // return _cheaterStatus.where((i) {
    //   List _values = i["values"];
    //   return (value is String) ? _values.contains(value) : value == i["value"];
    // }).toList()[0]["value"];
  }

  /// [Event]
  /// 将作弊行为转已翻译标签
  convertCheatMethods(List str) {
    List s = str;
    List tmpArr = [];
    List _cheatMethodsGlossary = Config.cheatMethodsGlossary["child"];

    s.forEach((str_item) {
      _cheatMethodsGlossary.forEach((i) {
        List _values = i["values"];
        if (_values.contains(str_item)) {
          tmpArr.add(translate("basic.cheatMethods.${i["value"]}.title"));
        }
      });
    });

    return tmpArr;

    // const s = str || [];
    // const tmpArr = [];
    //   if (_cheatMethodsGlossary == null) return '';
    //   _.each(s, (val) => {
    //   _.each(_cheatMethodsGlossary, (v, i) => {
    //   // v.values array
    //   // values是数组类型，内部的值是先前兼容v1版本之前举报类型
    //   if (v.values.indexOf(val) >= 0) {
    //   tmpArr.push(this.$i18n.t("cheatMethods." + v.value + ".title"));
    // }
    //   });
    //   });
    //   return tmpArr.sort().reverse().join(' ');
  }
}
