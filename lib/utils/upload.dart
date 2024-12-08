/// 上传
library;

import 'dart:io' as io;
import 'dart:io';

import 'package:bfban/utils/index.dart';
import 'package:uuid/uuid.dart';

import '../constants/api.dart';

class Upload extends Http {
  static int FILESIZE = 2 * 1024 * 1024;

  static int MAX_FILESIZE = 100 * 1024 * 1024;

  static Map GETURL = {};

  static FileManagement fileManagement = FileManagement();

  static String get location {
    return Config.apiUpload.url;
  }

  /// On
  static Future on(io.File file) async {
    try {
      var fileSize = file.readAsBytesSync();
      if (fileSize.isEmpty) return;

      if (fileSize.length <= FILESIZE) {
        var res = await Upload.uploadDateSmallFile(file);
        return res;
      } else if (fileSize.length > FILESIZE && fileSize.length <= MAX_FILESIZE) {
        var res = await Upload.uploadDateLargeFile(file);
        return res;
      } else {
        throw "超出最大文件上限";
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 小文件
  /// 2m以内
  static Future uploadDateSmallFile(io.File file) async {
    try {
      if (file.readAsBytesSync().isEmpty) {
        return {
          "code": -1,
          "message": "Missing parameter",
        };
      }

      var length = file.lengthSync();
      var postData = await file.readAsBytes();

      Response result = await HttpToken.request(
        Config.httpHost["service_upload"],
        httpDioType: HttpDioType.upload,
        method: Http.PUT,
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          Headers.contentLengthHeader: length,
          "Content-Type": fileManagement.resolutionFileType(file.path),
        },
        data: Stream.fromIterable(postData.map((e) => [e])), // 构建 Stream<List<int>>
      );

      if (result.data["success"] == 1) {
        return {
          "code": 1,
          "url": "${Upload.location}service/file?filename=${result.data["data"]["name"]}",
          "message": result.data["code"],
        };
      }

      throw result.data["code"];
    } catch (e) {
      return {
        "code": -1,
        "message": e.toString(),
      };
    }
  }

  /// 大文件
  /// 超出2m以上
  static Future uploadDateLargeFile(io.File file) async {
    String fileName = fileManagement.splitFileUrl(file.path)["fileName"];
    dynamic length = file.readAsBytesSync().length;

    Response result = await HttpToken.request(
      Config.apiHost["service_upload"]!.url,
      httpDioType: HttpDioType.upload,
      method: Http.POST,
      headers: {
        "Content-Type": fileManagement.resolutionFileType(file.path),
      },
      data: FormData.fromMap({
        "size": length,
        "mimeType": fileManagement.resolutionFileType(file.path),
        "body": await MultipartFile.fromFile(
          file.path,
          filename: "${const Uuid().v4()}_$fileName",
        ),
      }),
    );

    if (result.data["success"] == 1) {
      return {
        "code": 1,
        "url": "${Upload.location}service/file?filename=${result.data["data"]["name"]}",
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
    if (filename.isEmpty) return;

    Response result = await HttpToken.request(
      Config.httpHost["service_file"],
      parame: {"filename": filename, "explain": true},
      method: Http.GET,
    );

    return result;
  }
}
