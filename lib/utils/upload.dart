/// 上传
import 'dart:io' as io;
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
  Future on(io.File file) async {
    if (file == null) return;

    if (await file.readAsBytesSync().length <= FILESIZE) {
      var res = await uploadDateSmallFile(file);
      return res;
    } else {
      var res = await uploadDateLargeFile(file);
      return res;
    }
  }

  /// 小文件
  /// 2m以内
  Future uploadDateSmallFile(io.File file) async {
    if (file == null) {
      return {
        "code": -1,
        "message": "Missing parameter",
      };
    }

    dynamic length = file.readAsBytesSync().length;

    Response result = await Http.request(
      Config.httpHost["service_upload"],
      method: Http.PUT,
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        "Content-Type": fileManagement.resolutionFileType(file.path),
        "Content-Length": length,
      },
      data: await file.readAsBytesSync(),
    );

    if (result.data["success"] == 1) {
      return {
        "code": 1,
        "url": "${location()}service/file?filename=${result.data["data"]["name"]}",
        "message": result.data["code"],
      };
    }

    return {
      "code": -1,
      // "message": "error"
      "message": result.data["code"],
    };
  }

  /// 大文件
  /// 超出2m以上
  Future uploadDateLargeFile(io.File file) async {
    String fileName = fileManagement.splitFileUrl(file.path)["fileName"];
    dynamic length = file.readAsBytesSync().length;

    Response result = await Http.request(
      Config.apiHost["service_upload"]!.url,
      method: Http.POST,
      data: FormData.fromMap({
        "size": length,
        "mimeType": fileManagement.resolutionFileType(file.path),
        "body": await MultipartFile.fromFile(
          file.path,
          filename: const Uuid().v4(),
        ),
      }),
    );

    if (result.data["success"] == 1) {
      return {
        "code": 1,
        "url": "${location()}service/file?filename=${result.data["data"]["name"]}",
        "message": result.data["code"],
      };
    }

    return {
      "code": -1,
      "message": result.data["code"],
    };
  }

  /// 查询文件详情
  Future serviceFile(String filename) async {
    if (filename == null) return;

    Response result = await Http.request(
      Config.httpHost["service_file"],
      parame: {"filename": filename, "explain": true},
      method: Http.GET,
    );

    return result;
  }
}
