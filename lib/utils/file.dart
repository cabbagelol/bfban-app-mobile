///// 选择器
///// 文件 、图片、拍照、相册
//
//import 'package:flutter/cupertino.dart';
//import 'package:flutter/material.dart';
//
//import 'package:image_picker/image_picker.dart';
//
//import 'package:flutter_plugin_elui/elui.dart' show EluiPopupComponent, EluiPopupPlacement;
//
//class Files {
//  final List fileType = [
//    {
//      "name": "拍照",
//      "icon": Icons.party_mode,
//      "type": ImageSource.camera,
//    },
//    {
//      "name": "相册",
//      "icon": Icons.camera,
//      "type": ImageSource.gallery,
//    }
//  ];
//
////  await Files().on(context, camera: true, gallery: true, onSucceed: (Map pickedImgs) {
////  print("+++" + pickedImgs.toString());
////
////  if (pickedImgs != null) {
////  //模拟上传后返回的路径
////  return pickedImgs["img"];
////  }
////
////  return null;
////  });
//  Future on(
//    context, {
//    camera: true,
//    gallery: false,
//  }) async {
//    final picker = ImagePicker();
//    PickedFile pickedFile;
//    Function popupClose;
//
//    popupClose = await EluiPopupComponent(context)(
//      placement: EluiPopupPlacement.bottom,
//      child: Container(
//        color: Colors.white,
//        child: Column(
//          crossAxisAlignment: CrossAxisAlignment.stretch,
//          children: fileType.asMap().keys.map((index) {
//            return FileWidgetUI(
//              i: fileType[index],
//              onSucceed: () async {
//                popupClose.call();
//
//                pickedFile = await picker.getImage(
//                  source: fileType[index]["type"],
//                );
//
//                print("出发pickedFile");
//
//                return pickedFile;
//              },
//            );
//          }).toList(),
//        ),
//      ),
//    );
//
//    return pickedFile;
//  }
//}
//
//class FileWidgetUI extends StatefulWidget {
//  final i;
//
//  final Function onSucceed;
//
//  FileWidgetUI({this.i, this.onSucceed,});
//
//  @override
//  _FileWidgetUIState createState() => _FileWidgetUIState();
//}
//
//class _FileWidgetUIState extends State<FileWidgetUI> {
//  @override
//  Widget build(BuildContext context) {
//    return GestureDetector(
//      child: Container(
//        color: Colors.white,
//        padding: EdgeInsets.only(
//          top: 20,
//          bottom: 20,
//        ),
//        child: Center(
//          child: Wrap(
//            spacing: 10,
//            children: <Widget>[
//              Icon(
//                widget.i["icon"],
//                size: 20,
//                color: Colors.black,
//              ),
//              Text(widget.i["name"]),
//            ],
//          ),
//        ),
//      ),
//      onTap: () async {
//        widget.onSucceed();
//
//      },
//    );
//  }
//}
//
