/// 版本管理器

import 'package:bfban/constants/api.dart';

class Version {
  /// [Event]
  /// 对比版本
  /// 通常格式 0.0.1-beta
  bool getContrast(String v1, String v2) {
    Map _vs = {
      "beta": 0,
      "release": 1,
    };
    Map _v1 = _setSplitfactory(v1);
    Map _v2 = _setSplitfactory(v2);

    if (_v1["0"] > _v2["0"]) {
      return true;
    } else if (_v1["0"] == _v2["0"]) {
      if (_vs[_v1["1"]] > _vs[_v2["1"]]) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Map _setSplitfactory(v) {
    List s = v.split("-");

    return {
      "0": int.parse(s[0].replaceAll(".", "")),
      "1": (s ?? s[1]).toString(),
    };
  }
}
