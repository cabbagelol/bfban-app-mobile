import 'dart:async';
import 'dart:io';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class Refresh extends StatefulWidget {
  final FutureOr Function()? onRefresh;
  final FutureOr Function()? onLoad;
  final double edgeOffset;
  final Widget child;

  const Refresh({
    Key? key,
    this.onRefresh,
    this.onLoad,
    this.edgeOffset = 100,
    required this.child,
  }) : super(key: key);

  @override
  State<Refresh> createState() => RefreshState();
}

class RefreshState extends State<Refresh> {
  late EasyRefreshController controller;

  @override
  void initState() {
    controller = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Header? onHeader() {
    Header ch = CupertinoHeader();
    Header mh = MaterialHeader(
      triggerOffset: widget.edgeOffset,
      backgroundColor: Theme.of(context).canvasColor,
      color: Theme.of(context).colorScheme.primary,
    );
    return {'ios': ch, 'macos': ch, 'android': mh}['android' ?? Platform.operatingSystem] ?? mh;
  }

  @override
  Widget build(BuildContext context) {
    return EasyRefresh(
      controller: controller,
      header: onHeader(),
      footer: ClassicFooter(
        showText: false,
        textStyle: TextStyle(fontSize: FontSize.large.value),
        iconTheme: Theme.of(context).iconTheme.copyWith(size: FontSize.xLarge.value),
      ),
      onRefresh: widget.onRefresh,
      onLoad: widget.onLoad,
      child: widget.child,
    );
  }
}