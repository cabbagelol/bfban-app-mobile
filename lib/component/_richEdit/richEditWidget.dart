import 'package:flutter/material.dart';

import 'richEditCore.dart';

class RichEditWidget extends StatefulWidget {
  String? data;

  RichEditWidget({
    Key? key,
    this.data = "",
  }) : super(key: key);

  @override
  State<RichEditWidget> createState() => _RichEditWidgetState();
}

class _RichEditWidgetState extends State<RichEditWidget> {
  @override
  Widget build(BuildContext context) {
    return RichEditCore(
      data: widget.data,
    );
  }
}
