import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingWidget extends StatelessWidget {
  final num? strokeWidth;
  final double? size;
  final Color? color;

  const LoadingWidget({
    super.key,
    this.strokeWidth,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingAnimationWidget.discreteCircle(
      size: size ?? 30,
      color: color ?? Color.alphaBlend(Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primaryContainer)!,
      secondRingColor: Theme.of(context).colorScheme.secondary,
      thirdRingColor: Theme.of(context).colorScheme.surface,
    );
  }
}
