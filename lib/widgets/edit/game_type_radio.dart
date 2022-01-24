import 'package:flutter/material.dart';

/// 游戏类型单选
class gameTypeRadio extends StatelessWidget {
  final Widget? child;
  final bool index;
  final GestureTapCallback? onTap;

   const gameTypeRadio({Key? key,
    this.child,
    this.index = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: BorderSide(
            color: Theme.of(context).backgroundColor.withOpacity(.09),
            width: 1,
          ),
        ),
        color: index ? const Color(0xff364e80) : Theme.of(context).sliderTheme.disabledActiveTickMarkColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          child: child!,
        ),
      ),
      onTap: onTap,
    );
  }
}
