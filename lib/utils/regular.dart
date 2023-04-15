import 'package:bfban/utils/index.dart';

class Regular {
  Map REGULARTYPE = {
    "link": {
      "v": RegExp(r'/^(ftp|http|https):\/\/[^ "]+$/g'),
    },
    "image": {},
    "video": {},
    "date": {
      // yyyy-MM-dd HH:mm:ss
      "v": RegExp(r'/^(?:19|20)[0-9][0-9]-(?:(?:0[1-9])|(?:1[0-2]))-(?:(?:[0-2][1-9])|(?:[1-3][0-1])) (?:(?:[0-2][0-3])|(?:[0-1][0-9])):[0-5][0-9]:[0-5][0-9]$/')
    },
    "mobile": {"v": RegExp(r'/(phone|pad|pod|iPhone|iPod|ios|iPad|Android|Mobile|BlackBerry|IEMobile|MQQBrowser|JUC|Fennec|wOSBrowser|BrowserNG|WebOS|Symbian|Windows Phone)/i')}
  };

  /// 正则验证
  check(String regularType, dynamic value) {
    if (regularType.isEmpty) return;
    final checkResult = REGULARTYPE[regularType]["V"].hasMatch(value);

    if (checkResult) {
      return {"code": 0, "checkResult": checkResult};
    }

    return {"code": -1};
  }

  /// 图片验证
  /// 检查在线图片是否可访问
  Future<bool> authImage(String url) async {
    if (url.isEmpty) return false;

    Response result = await Http.dio.head(url);

    if (result.statusCode == 200) {
      return true;
    }

    return false;
  }
}
