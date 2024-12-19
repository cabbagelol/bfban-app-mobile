import 'package:flutter/material.dart';

class RedDotWidget extends StatelessWidget {
  final bool show;

  final Widget child;

  const RedDotWidget({
    super.key,
    required this.child,
    this.show = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (show)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          )
      ],
    );
  }
}
