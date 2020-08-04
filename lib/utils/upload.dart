/// 上传
import 'dart:io';

import 'http.dart';

class upload extends Http {
  /// 七牛token
  static String qiniuToken = "";

  /// 获取七牛token
  static getToken() async {
    Response result = await Http.request(
      'api/auth/qiniu',
      method: Http.POST,
    );

    qiniuToken = result.data["token"];

    return qiniuToken;
  }

  /// 上传
  static upLoad(File src) async {
    Response result = await Http.request(
      '',
      method: Http.POST,
      typeUrl: "upload",
      data: FormData.fromMap({
        "token": qiniuToken,
        "key": src.path,
        "file": src,
      }),
    );

    return result;
  }

  /// 上传事件
  static on(File src) async {
    if (qiniuToken == "") {
      await getToken();
    }

    Response result = await upLoad(src);

    return result;
  }
}
