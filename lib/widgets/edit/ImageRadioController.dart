import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';


class ImageRadio extends StatefulWidget {

  ImageRadio(@required this.imageUrl, {
    this.isSeleted: false,
    this.controller,
    this.onChange,
    this.width: 60.0,
    this.height: 60.0,
    this.activeBorderColor: Colors.red,
    this.inactiveBorderColor: Colors.transparent,
    this.activeBorderWidth: 3.0,
    this.inactiveBorderWidth: 3.0,
    this.borderRadius: 2.0
  });


  bool isSeleted;

  VoidCallback callMe;

  final String imageUrl;

  final ImageRadioController controller;
  final ValueChanged<bool> onChange;
  final double width;
  final double height;
  final Color activeBorderColor;
  final Color inactiveBorderColor;
  final double activeBorderWidth;
  final double inactiveBorderWidth;
  final double borderRadius;




  @override
  _ImageRadioState createState() => _ImageRadioState();
}

class _ImageRadioState extends State<ImageRadio> {

  VoidCallback makeMeUnselect;

  @override
  void initState() {
    // init
    makeMeUnselect = () {
      setState(() {
        widget.isSeleted = false;
      });

      if (widget.onChange != null) {
        widget.onChange(false);
      }
    };

    // backup
    widget.callMe = makeMeUnselect;

    // add
    if (widget.controller != null) {
      print("initState() add callback--->$makeMeUnselect");
      widget.controller.add(makeMeUnselect);
    }

    super.initState();
  }

  @override
  void dispose() {
    if (widget.controller != null) {
      print("dispose() remove callback--->$makeMeUnselect");
      widget.controller.remove(makeMeUnselect);
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(ImageRadio oldWidget) {
    if (oldWidget != widget && oldWidget.callMe != makeMeUnselect) {
      if (widget.controller != null) {
        //print("old callback == new callback ? --->${oldWidget.callMe == makeMeUnselect}");

        widget.controller.remove(oldWidget.callMe);
        widget.controller.add(makeMeUnselect);

        print("didUpdateWidget() remove--->$makeMeUnselect");
        print("didUpdateWidget() add--->$makeMeUnselect");
      }
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          widget.isSeleted = true;
        });

        if (widget.onChange != null) {
          widget.onChange(true);
        }

        widget.controller.unselectOthers(makeMeUnselect);

      },
      child: Container(
        width: widget.width,
        height: widget.height,
        alignment: Alignment.center,
        decoration: new BoxDecoration(
          border: new Border.all(
              width: widget.isSeleted ? widget.activeBorderWidth : widget.inactiveBorderWidth,
              color: widget.isSeleted ? widget.activeBorderColor : widget.inactiveBorderColor),
          borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius)),
        ),

        child: Image.network(
          widget.imageUrl,
          fit: BoxFit.cover,
          width: widget.width,
          height: widget.height,
        ),
      ),
    );
  }
}

class ImageRadioController {

  List<VoidCallback> _callbackList;

  ImageRadioController() {
    _callbackList = [];
  }

  void add(VoidCallback callback) {
    if (_callbackList == null) _callbackList = [];
    _callbackList.add(callback);
  }

  void remove(VoidCallback callback) {
    if (_callbackList != null) _callbackList.remove(callback);
  }

  void dispose() {
    if (_callbackList != null) {
      _callbackList.clear();
      _callbackList = null;
    }
  }

  void unselectOthers(VoidCallback currentCallback) {
    if (_callbackList != null && _callbackList.length > 0) {

      for(int i = 0, len = _callbackList.length; i < len; i++) {
        VoidCallback callback = _callbackList[i];

        if (callback == currentCallback) continue;

        callback();
      }
    }
  }
}