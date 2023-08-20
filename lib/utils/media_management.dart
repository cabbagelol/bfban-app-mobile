import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';

import 'package:bfban/utils/index.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class MediaManagement {
  /// [Event]
  /// 储存图片
  Future saveLocalImages(
    String? url, {
    String? fileUrl = "",
  }) async {
    var response = await Dio().get(
      url!,
      options: Options(
        responseType: ResponseType.bytes,
      ),
    );

    final Directory extDir = await getApplicationSupportDirectory();
    final fileDir = await Directory('${extDir.path}/media').create(recursive: true);

    File newFile = File("${fileDir.path}/${const Uuid().v4()}.png");
    newFile.writeAsBytes(Uint8List.fromList(response.data));
    File result = await newFile.create(recursive: true);

    if (result != "") {
      return {
        "src": result,
        "code": 0,
      };
    }

    return {
      "code": -1,
    };
  }
}
