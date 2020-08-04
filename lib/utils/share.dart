/// 分享
import 'package:flutter/services.dart';

import 'package:flutter_share/flutter_share.dart';

class Share {
  Future<void> text({
    title: 'Example share',
    text: 'Example share text',
    linkUrl: 'https://flutter.cn/',
    chooserTitle: 'Example Chooser Title',
  }) async {
    await FlutterShare.share(
      title: title,
      text: text,
      linkUrl: linkUrl,
      chooserTitle: chooserTitle,
    );
  }

  Future<void> file() async {
//    List<dynamic> docs = await DocumentsPicker.pickDocuments;
//    if (docs == null || docs.isEmpty) return null;
//
//    await FlutterShare.shareFile(
//      title: 'Example share',
//      text: 'Example share text',
//      filePath: docs[0] as String,
//    );
  }
}
