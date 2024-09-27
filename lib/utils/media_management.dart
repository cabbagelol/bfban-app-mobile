import 'dart:io';
import 'dart:typed_data';

import 'package:bfban/utils/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../provider/dir_provider.dart';

class MediaManagement {
  /// [Event]
  /// 储存图片
  Future saveLocalImages(
    BuildContext context,
    String? url, {
    String? fileUrl = "",
  }) async {
    var response = await Dio().get(
      url!,
      options: Options(
        responseType: ResponseType.bytes,
      ),
    );

    DirProvider dirProvider = Provider.of<DirProvider>(context, listen: false);

    File newFile = File("${dirProvider.currentDefaultSavePath}/media/${const Uuid().v4()}.png");
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
