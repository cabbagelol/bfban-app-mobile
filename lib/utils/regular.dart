import 'package:bfban/utils/index.dart';

enum RegularType { None, Link, Image, Video, Date, Mobile, P }

class Regular {
  Map<RegularType, RegularMapItem> REGULARTYPE = {
    RegularType.Link: RegularMapItem(v: RegExp(r'(http|ftp|https):\/\/[\w\-_]+(\.[\w\-_]+)+([\w\-\.,@?^=%&:/~\+#]*[\w\-\@?^=%&/~\+#])?')),
    RegularType.Video: RegularMapItem(v: RegExp(r'')),
    // yyyy-MM-dd HH:mm:ss
    RegularType.Date: RegularMapItem(v: RegExp(r'/^(?:19|20)[0-9][0-9]-(?:(?:0[1-9])|(?:1[0-2]))-(?:(?:[0-2][1-9])|(?:[1-3][0-1])) (?:(?:[0-2][0-3])|(?:[0-1][0-9])):[0-5][0-9]:[0-5][0-9]$/')),
    RegularType.Mobile: RegularMapItem(v: RegExp(r'/(phone|pad|pod|iPhone|iPod|ios|iPad|Android|Mobile|BlackBerry|IEMobile|MQQBrowser|JUC|Fennec|wOSBrowser|BrowserNG|WebOS|Symbian|Windows Phone)/i')),
    RegularType.P: RegularMapItem(v: RegExp(r'<p(([\s\S])*?)</p>')),
    RegularType.Image: RegularMapItem(v: RegExp(r'<img(([\s\S])*?)</img>')),
  };

  /// 正则验证
  check(RegularType regularType, dynamic value) {
    if (regularType == null || regularType == RegularType.None) return;
    final checkResult = REGULARTYPE[regularType]!.v.hasMatch(value);

    if (checkResult) {
      return {"code": 0, "checkResult": checkResult};
    }

    return {"code": -1};
  }

  /// 从检查内容中取出
  getCheckText(RegularType regularType, dynamic value) {
    if (regularType == RegularType.None || value == null) return;
    final checkResult = REGULARTYPE[regularType]!.v.allMatches(value);
    return checkResult;
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

class RegularMapItem {
  RegExp v;

  RegularMapItem({
    required this.v,
  });
}
