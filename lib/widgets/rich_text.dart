// /// 富文本
// /// 组件类型，需要容器承载
// /// 实体页面[/eichEdit/signin.dart]
//
// import 'dart:async';
//
// // import 'package:flutter_rich_html/main.dart';
//
// import 'package:bfban/component/rich_edit.dart';
// import 'package:bfban/constants/api.dart';
// import 'package:bfban/utils/signin.dart' show upload;
//
// import 'package:video_player/video_player.dart';
// import 'package:image_picker/image_picker.dart';
//
// class MySimpleRichHtmlController extends RichHtmlController {
//   final context;
//   final RichHtmlTheme theme;
//
//   MySimpleRichHtmlController(
//       this.context, {
//         this.theme,
//       });
//
//   @override
//   Future<String> insertImage() async {
//     final picker = ImagePicker();
//     PickedFile pickedImage = await picker.getImage(
//       source: ImageSource.gallery,
//       imageQuality: 30,
//     );
//
//     String key = await upload.on(pickedImage.path);
//
//     return key != null ? "${Config.apiHost["qiniuyunSrc"]}/$key" : "";
//   }
//
//   @override
//   noSuchMethod(Invocation invocation) {
//     return super.noSuchMethod(invocation);
//   }
// }
