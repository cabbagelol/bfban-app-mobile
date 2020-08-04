/// 选择器
/// 文件 、图片、拍照、相册

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

import 'package:flutter_plugin_elui/elui.dart';

class Files {
  final Map fileType = {
    ImageSource.camera: {
      "name": "拍照",
      "icon": Icons.party_mode,
    },
    ImageSource.gallery: {
      "name": "相册",
      "icon": Icons.camera,
    },
  };

  List fileList = [ImageSource.camera, ImageSource.gallery];

  Future on(
    context, {
    camera: true,
    gallery: false,
    Function onSucceed,
  }) async {
    Function popupClose;

    final picker = ImagePicker();

    popupClose = EluiPopupComponent(context)(
      placement: EluiPopupPlacement.bottom,
      child: Container(
        color: Colors.white,
        child: Column(
          children: fileList.asMap().keys.map((index) {
            return GestureDetector(
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.only(
                  top: 20,
                  bottom: 20,
                ),
                child: Wrap(
                  spacing: 10,
                  children: <Widget>[
                    Icon(
                      fileType[fileList[index]]["icon"],
                      size: 20,
                      color: Colors.black,
                    ),
                    Text(fileType[fileList[index]]["name"]),
                  ],
                ),
              ),
              onTap: () async {
                popupClose.call();

                final pickedFile = await picker.getImage(
                  source: fileList[index],
                );

                onSucceed({
                  "name": fileType[fileList[index]]["name"],
                  "value": fileList[index],
                  "img": File(pickedFile.path),
                });
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
