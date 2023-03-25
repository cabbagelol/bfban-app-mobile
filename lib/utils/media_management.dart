import 'dart:typed_data';
import 'package:dio/dio.dart';

import 'package:bfban/utils/index.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

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

    final result = await ImageGallerySaver.saveImage(
      Uint8List.fromList(
        response.data,
      ),
    );

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
