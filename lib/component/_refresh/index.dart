import 'dart:async';

import 'package:bfban/component/_loading/index.dart';
import 'package:bfban/component/_refresh/headr.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class Refresh extends StatefulWidget {
  final FutureOr<dynamic> Function()? onRefresh;
  final FutureOr<dynamic> Function()? onLoad;
  final double edgeOffset;
  final double triggerOffset;
  final Widget child;
  final Axis triggerAxis;

  const Refresh({
    super.key,
    this.onRefresh,
    this.onLoad,
    this.edgeOffset = 100,
    this.triggerOffset = 70,
    this.triggerAxis = Axis.vertical,
    required this.child,
  });

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
    Header app = AppHeader(
      triggerOffset: widget.edgeOffset,
      backgroundColor: Theme.of(context).canvasColor,
      color: Theme.of(context).colorScheme.primary,
    );
    return app;
  }

  Footer? onFooter() {
    return ClassicFooter(
      triggerOffset: widget.triggerOffset,
      showText: false,
      textStyle: TextStyle(fontSize: FontSize.large.value),
      iconTheme: Theme.of(context).iconTheme.copyWith(size: FontSize.xLarge.value),
      pullIconBuilder: (BuildContext content, IndicatorState state, double d) {
        if (state.mode == IndicatorMode.processing || state.mode == IndicatorMode.ready) {
          return LoadingWidget();
        }

        switch (state.result) {
          case IndicatorResult.noMore:
            return SizedBox(
              child: const Icon(
                Icons.inbox_outlined,
              ),
            );
          case IndicatorResult.none:
            return SizedBox();
          case IndicatorResult.success:
            return SizedBox(
              child: const Icon(
                Icons.done,
              ),
            );
          case IndicatorResult.fail:
            return SizedBox(
              child: const Icon(
                Icons.error_outline,
              ),
            );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return EasyRefresh(
      controller: controller,
      triggerAxis: widget.triggerAxis,
      header: onHeader(),
      footer: onFooter(),
      onRefresh: widget.onRefresh,
      onLoad: widget.onLoad,
      child: widget.child,
    );
  }
}
