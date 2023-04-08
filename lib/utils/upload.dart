/// 上传
import 'dart:io';

import 'package:bfban/utils/file.dart';
import 'package:uuid/uuid.dart';

import '../constants/api.dart';
import 'http.dart';

class Upload extends Http {
  int FILESIZE = 2 * 1024 * 1024;

  Map GETURL = {};

  FileManagement fileManagement = FileManagement();

  location() {
    return Config.apiUpload.url;
  }

  /// On
  Future on(File file) async {
    if (file == null) return;

    if (await file.readAsBytesSync().length <= FILESIZE) {
      uploadDateSmallFile(file).then((res) => {
            if (res["code"] >= 1) {},
          });
    } else {
      uploadDateLargeFile(file).then((res) => {
            if (res["code"] >= 1) {},
          });
    }
  }

  /// 小文件
  /// 2m以内
  Future uploadDateSmallFile(File file) async {
    if (file == null) {
      return {
        "code": -1,
        "message": "Missing parameter",
      };
    }

    // test
    return {"code": 1, "url": "https://"};

    Response result = await Http.request(
      Config.apiHost["service_upload"],
      method: Http.PUT,
      headers: {
        ["Content-Type"]: "file/image",
        ["Content-Length"]: file.readAsBytesSync().length,
        ['x-access-token']: Http.TOKEN
      },
    )
      ..then((result) {
        return {
          "code": 1,
          "url": "${location()}service/file?filename=${result.data["data"]["name"]}",
        };
      })
      ..catchError((err) {
        return {
          "code": -1,
          "message": err,
        };
      });
  }

  /// 大文件
  /// 超出2m以上
  Future uploadDateLargeFile(File file) async {
    String fileName = fileManagement.splitFileUrl(file.path)["fileName"];

    Response result = await Http.request(
      Config.apiHost["service_upload"],
      method: Http.POST,
      data: FormData.fromMap({
        "size": file.readAsBytesSync().length,
        "mimeType": "file/image",
        "body": await MultipartFile.fromFile(file.path, filename: fileName)
      }),
      headers: {
        ['x-access-token']: Http.TOKEN,
      },
    )
      ..then((result) {
        return {
          "code": 1,
          "url": "${location()}service/file?filename=${result.data["data"]["name"]}",
        };
      })
      ..catchError((err) {
        return {
          "code": -1,
          "message": err,
        };
      });
  }

  /// 查询文件详情
  Future serviceFile (String filename) async {
    if (filename == null) return;

    Response result = await Http.request(
      Config.httpHost["service_file"],
      parame: {"filename": filename, "explain": true},
      method: Http.GET,
    );

    return result;
  }
}
