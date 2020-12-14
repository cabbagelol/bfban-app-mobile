/// 上传
import 'dart:io';

import 'package:uuid/uuid.dart';

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
  static upLoad(File file) async {
    dynamic uuid = Uuid();
    dynamic formdata = FormData.fromMap({
      "token": qiniuToken,
      "key": uuid.v4(),
      "file": await MultipartFile.fromFile(file.path, filename: file.path),
    });

    Response result = await Http.request(
      '',
      method: Http.POST,
      typeUrl: "upload",
      data: formdata,
    );

    return result.data["key"];
  }

  /// 上传事件
  static on(String path) async {
    File file = File(path);

    if (qiniuToken == "") {
      await getToken();
    }

    String result = await upLoad(file);

    return result;
  }
}
