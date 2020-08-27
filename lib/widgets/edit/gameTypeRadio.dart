import 'package:flutter/material.dart';

/// 游戏类型单选
class gameTypeRadio extends StatelessWidget {
  final child;
  final bool index;
  final Function onTap;
  final Map theme;

  gameTypeRadio(this.theme, {
    this.child,
    this.index = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.only(
          left: 10,
          right: 10,
          top: 5,
          bottom: 5,
        ),
        color: index ? (theme['nameColor'] ?? Color(0xff364e80)) : Colors.transparent,
        child: child,
      ),
      onTap: this.onTap,
    );
  }
}
