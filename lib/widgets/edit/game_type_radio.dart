import 'package:flutter/material.dart';

/// 游戏类型单选
class GameTypeRadioWidget extends StatelessWidget {
  final Widget? child;
  final bool index;
  final bool errorHint;
  final GestureTapCallback? onTap;

  const GameTypeRadioWidget({
    super.key,
    this.child,
    this.index = false,
    this.errorHint = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: BorderSide(
            color: !errorHint ? Theme.of(context).colorScheme.error : Theme.of(context).dividerTheme.color!,
            width: 1,
          ),
        ),
        elevation: 0,
        color: index ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          child: child!,
        ),
      ),
    );
  }
}
