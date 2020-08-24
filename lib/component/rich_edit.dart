import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:flutter_plugin_elui/elui.dart' show EluiPopupComponent, EluiPopupPlacement;

import 'package:bfban/constants/api.dart';
import 'package:bfban/utils/index.dart' show upload;

enum RichEditDataType { TEXT, IMAGE, VIDEO, NONE }

class RichEditData {
  RichEditDataType type;
  dynamic data;
  TextEditingController controller;
  FocusNode controllerFocus;
  bool onOly;

  RichEditData(
    this.type,
    this.data, {
    this.controller,
    this.controllerFocus,
    this.onOly = false,
  });
}

abstract class RichEditController {
  final List<RichEditData> _data = List.of({
    RichEditData(
      RichEditDataType.TEXT,
      "",
      controller: TextEditingController(),
      controllerFocus: FocusNode(),
    )
  });

  final TextStyle textStyle;
  final InputDecoration inputDecoration;
  final Icon deleteIcon;
  final Icon imageIcon;
  final Icon videoIcon;
  final Icon emptyIcon;
  final bool isImageIcon;
  final bool isVideoIcon;
  final bool isEmptyIcon;

  RichEditController({
    this.textStyle,
    InputDecoration inputDecoration,
    Icon deleteIcon,
    Icon imageIcon,
    Icon videoIcon,
    Icon emptyIcon,
    bool isImageIcon = true,
    bool isVideoIcon = true,
    bool isEmptyIcon = true,
  })  : deleteIcon = deleteIcon ?? Icon(Icons.cancel),
        inputDecoration = inputDecoration ??
            InputDecoration(
              hintText: "输入内容",
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
            ),
        imageIcon = imageIcon ?? Icon(Icons.image, color: Color(0xff364e80),),
        videoIcon = videoIcon ?? Icon(Icons.videocam, color: Color(0xff364e80),),
        emptyIcon = emptyIcon ?? Icon(Icons.delete, color: Color(0xff364e80),),
        isImageIcon = isImageIcon ?? true,
        isVideoIcon = isVideoIcon ?? true,
        isEmptyIcon = isEmptyIcon ?? true;

  addVideo();

  generateImageView(RichEditData data);

  generateVideoView(RichEditData data);

  String generateText() {
    StringBuffer sb = StringBuffer();
    _data.forEach((element) {
      sb.write(element.data);
    });
    return sb.toString();
  }

  String generateHtml() {
    StringBuffer sb = StringBuffer();
    _data.forEach((element) {
      switch (element.type) {
        case RichEditDataType.TEXT:
          generateTextHtml(sb, element);
          break;
        case RichEditDataType.IMAGE:
          generateImageHtml(sb, element);
          break;
        case RichEditDataType.VIDEO:
          generateVideoHtml(sb, element);
          break;
      }
    });
    return sb.toString();
  }

  String remStringHtml(text) {
    RegExp reg = new RegExp("<[^>]*>");
    Iterable<RegExpMatch> matches = reg.allMatches(text);
    String value = "";

    matches.forEach((m) {
      value = m.input.toString().replaceAll(reg, "");
    });

    return value;
  }

  List generateView(String html) {
    RegExp regDom = new RegExp('<[img|images|p|br].*?>([^\<]*?)<\/[img|images|p|br]>|<img.*?src="(.*?)".*?\/?>');
    RegExp regDomImg = new RegExp('<img.*?src="(.*?)".*?\/?>');
    RegExp regDomImgSrc = new RegExp(" src=\"(.*)\" ");
    RegExp regDomName = new RegExp('<(img|p)');

    Iterable<RegExpMatch> matches = regDom.allMatches(html);

    if (html == "") {
      return [];
    }

    _data.removeAt(0);

    matches.forEach((m) {
      String DomContent = m.input.substring(m.start, m.end);
      Iterable<RegExpMatch> srcValue = regDomImgSrc.allMatches(DomContent);

      /// img or image tag
      srcValue.forEach((_rt) {
        String src = _rt.input.substring(_rt.start, _rt.end).replaceAll("src=\"", "").replaceAll("\"", "");
        if (DomContent.toString().indexOf("<img") >= 0) {
          print(_data[_data.length - 1].type);

          _data.addAll([
            RichEditData(
              RichEditDataType.IMAGE,
              src.trim(),
            ),
            (_data[_data.length - 1].type == RichEditDataType.IMAGE || _data[_data.length - 1].type == RichEditDataType.VIDEO)
                ? RichEditData(
                    RichEditDataType.TEXT,
                    "",
                    controller: TextEditingController(),
                    controllerFocus: FocusNode(),
                  )
                : RichEditData(
                    RichEditDataType.NONE,
                    "",
                  ),
          ]);
        }
      });

      if (DomContent.toString().indexOf("<p") >= 0) {
        _data.add(
          RichEditData(
            RichEditDataType.TEXT,
            this.remStringHtml(m.input.substring(m.start, m.end)),
            controller: TextEditingController(),
            controllerFocus: FocusNode(),
          ),
        );
      }
    });

    _data.add(
      RichEditData(
        RichEditDataType.TEXT,
        "",
        controller: TextEditingController(),
        controllerFocus: FocusNode(),
      ),
    );
  }

  void generateTextHtml(StringBuffer sb, RichEditData element) {
    if (element.data != "") {
      sb.write("<p>");
      sb.write(element.data);
      sb.write("<\/p>");
    }
  }

  void generateImageHtml(StringBuffer sb, RichEditData element) {
    if (element.data != "") {
      sb.write("<img src=\"");
      sb.write(element.data);
      sb.write("\" />");
    }
  }

  void generateVideoHtml(StringBuffer sb, RichEditData element) {
    sb.write("<p>");
    sb.write('''
          <video src="${element.data}" playsinline="true" webkit-playsinline="true" x-webkit-airplay="allow" airplay="allow" x5-video-player-type="h5" x5-video-player-fullscreen="true" x5-video-orientation="portrait" controls="controls"  style="width: 100%;height: 300px;"></video>
          ''');
    sb.write("<\/p>");
  }

  List<RichEditData> getDataList() {
    return _data;
  }
}

class RichEdit extends StatefulWidget {
  final RichEditController controller;

  RichEdit(
    this.controller, {
    Key key,
  }) : super(key: key);

  @override
  RichEditState createState() => new RichEditState();
}

class RichEditState extends State<RichEdit> {
  ScrollController _controller;

  Map<int, FocusNode> focusNodes = Map();

  Map<int, TextEditingController> textControllers = Map();

  final List fileType = [
    {
      "name": "拍照",
      "icon": Icons.party_mode,
      "type": ImageSource.camera,
    },
    {
      "name": "相册",
      "icon": Icons.camera,
      "type": ImageSource.gallery,
    }
  ];

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    focusNodes.clear();
    textControllers.clear();
    return Column(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: 50,
            ),
            child: ListView.builder(
              controller: _controller,
              itemCount: widget.controller._data.length,
              itemBuilder: (context, index) {
                var data = widget.controller._data[index];

                Widget item = Container();

                switch (data.type) {
                  case RichEditDataType.NONE:
                    item = Container();
                    break;
                  case RichEditDataType.TEXT:
                    textControllers[index] = widget.controller._data[index].controller;
                    focusNodes[index] = widget.controller._data[index].controllerFocus;

                    /// 赋予值
                    textControllers[index].text = data.data;

                    /// 监听变动
                    textControllers[index].addListener(() {});

                    item = GestureDetector(
                      onTap: () {
                        FocusScope.of(context).requestFocus(focusNodes[index]);
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                          left: 10,
                        ),
                        padding: EdgeInsets.only(
                          left: 5,
                          top: 5,
                          bottom: 5,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              width: 1,
                              color: Color(0xfff2f2f2),
                            ),
                          ),
                        ),
                        child: EditableText(
                          controller: textControllers[index],
                          focusNode: focusNodes[index],
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.newline,
                          autofocus: true,
                          style: widget.controller.textStyle ??
                              TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                          minLines: 1,
                          maxLines: null,
                          cursorColor: Color(0xff364e80),
                          backgroundCursorColor: Colors.transparent,
                          onChanged: (text) {
                            if (text == "" && widget.controller._data.length > 1) {
                              print(index);
                              setState(() {
                                focusNodes.remove(focusNodes[index]);
                                widget.controller._data.removeAt(index);
                              });
                              return;
                            }

                            if (text.indexOf("\n") >= 0) {
                              List t = text.split("\n");
                              widget.controller._data[index].data = t[0];
                              widget.controller._data.insert(
                                index + 1,
                                RichEditData(
                                  RichEditDataType.TEXT,
                                  t.length > 1 ? t[1].toString().replaceAll("\n", "") ?? "" : "",
                                  controller: TextEditingController(),
                                  controllerFocus: FocusNode(),
                                ),
                              );

                              FocusScope.of(context).unfocus();

                              setState(() {});
                            } else {
                              widget.controller._data[index].data = text;
                            }
                          },
                        ),
                      ),
                    );
                    break;
                  case RichEditDataType.IMAGE:
                    item = GestureDetector(
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 10,
                        ),
                        child: Stack(
                          children: <Widget>[
                            widget.controller.generateImageView(data),
                            Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  decoration: new BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Colors.transparent, Colors.black26],
                                    ),
                                  ),
                                  child: IconButton(
                                    icon: Icon(Icons.cancel),
                                    color: Colors.white,
                                    onPressed: () {
                                      remove(index);
                                    },
                                  ),
                                ))
                          ],
                        ),
                      ),
                    );
                    break;
                  case RichEditDataType.VIDEO:
                    item = Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.cancel),
                            onPressed: () {
                              remove(index);
                            },
                          ),
                          widget.controller.generateVideoView(data),
                        ],
                      ),
                    );
                }
                return item;
              },
            ),
          ),
        ),
        Container(
          child: Container(
            height: 50,
            color: Color(0xfff2f2f2),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Wrap(
                    children: <Widget>[
                      Offstage(
                        offstage: !widget.controller.isImageIcon,
                        child: IconButton(
                            icon: widget.controller.imageIcon,
                            onPressed: () async {
                              FocusScope.of(context).requestFocus(FocusNode());

                              this.image(context, camera: true, gallery: true, onSucceed: (String path) {
                                addView(
                                  RichEditData(RichEditDataType.IMAGE, path),
                                );
                              });
                            }),
                      ),
                      Offstage(
                        offstage: !widget.controller.isVideoIcon,
                        child: IconButton(
                            icon: widget.controller.videoIcon,
                            onPressed: () async {
                              FocusScope.of(context).requestFocus(FocusNode());

                              String path = await widget.controller.addVideo();
                              if (path != null) {
                                addView(
                                  RichEditData(
                                    RichEditDataType.VIDEO,
                                    path,
                                  ),
                                );
                              }
                            }),
                      ),
                    ],
                  ),
                ),
                Offstage(
                  offstage: !widget.controller.isEmptyIcon,
                  child: IconButton(
                    icon: widget.controller.emptyIcon,
                    onPressed: () => initial(),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Future image(
    context, {
    camera: true,
    gallery: false,
    Function onSucceed,
  }) async {
    final picker = ImagePicker();
    Function popupClose;

    popupClose = await EluiPopupComponent(context)(
      placement: EluiPopupPlacement.bottom,
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: fileType.asMap().keys.map((index) {
            return FileWidgetUI(
              i: fileType[index],
              onSucceed: () async {
                popupClose.call();

                PickedFile pickedImage = await picker.getImage(
                  source: fileType[index]["type"],
                  imageQuality: 30,
                );

                String key = await upload.on(pickedImage.path);
                onSucceed(key != null ? "${Config.apiHost["qiniuyunSrc"]}/$key" : "");
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void initial() {
    print(widget.controller._data.length);
    setState(() {
      widget.controller._data.asMap().keys.map((index) {
        remove(index);
      });
      widget.controller._data.add(RichEditData(
        RichEditDataType.TEXT,
        "",
        controller: TextEditingController(),
        controllerFocus: FocusNode(),
      ));
    });
  }

  void remove(int index) {
    var next = widget.controller._data[index + 1];
    if (next != null && next.data == "") {
      widget.controller._data.removeAt(index + 1);
      widget.controller._data.removeAt(index);
    } else if (index > 0) {
      var pre = widget.controller._data[index - 1];
      if (pre.type == RichEditDataType.TEXT) {
        pre.data += "\n${next.data}";
      }
      widget.controller._data.removeAt(index);
    }

    setState(() {});
  }

  void addView(RichEditData richEditData) {
    int insertIndex = widget.controller._data.length;
    String text = "";
    focusNodes.forEach((key, value) {
      if (value.hasFocus) {
        insertIndex = key + 1;
        var textController = textControllers[key];
        text = textController.selection.textAfter(textController.text);
        widget.controller._data[key].data = textController.text.substring(0, textController.text.length - text.length);
      }
    });
    widget.controller._data.insert(insertIndex, richEditData);
    widget.controller._data.insert(
      insertIndex + 1,
      RichEditData(
        RichEditDataType.TEXT,
        text,
        controller: TextEditingController(),
        controllerFocus: FocusNode(),
      ),
    );
    setState(() {});
  }
}

class FileWidgetUI extends StatefulWidget {
  final i;

  final Function onSucceed;

  FileWidgetUI({
    this.i,
    this.onSucceed,
  });

  @override
  _FileWidgetUIState createState() => _FileWidgetUIState();
}

class _FileWidgetUIState extends State<FileWidgetUI> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.only(
          top: 20,
          bottom: 20,
        ),
        child: Center(
          child: Wrap(
            spacing: 10,
            children: <Widget>[
              Icon(
                widget.i["icon"],
                size: 20,
                color: Colors.black,
              ),
              Text(widget.i["name"]),
            ],
          ),
        ),
      ),
      onTap: () async {
        widget.onSucceed();
      },
    );
  }
}
