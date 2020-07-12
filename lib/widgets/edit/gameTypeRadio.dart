import 'package:flutter/material.dart';

/// 游戏类型单选
class gameTypeRadio extends StatelessWidget {
  final select;
  final child;
  final bool index;
  final Function onTap;

  gameTypeRadio({
    this.select = 1,
    this.child,
    this.index = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.only(
          top: 8,
          left: 5,
          right: 5,
          bottom: 8,
        ),
        decoration: BoxDecoration(
          color: index ? Color(0xff364e80) : Colors.transparent,
          border: Border(
            top: BorderSide(
              width: 1,
              color: Color(0xff364e80) ,
            ),
            bottom: BorderSide(
              width: 1,
              color: Color(0xff364e80) ,
            ),
            left: select == 2
                ? BorderSide(
              width: 1,
              color: Colors.transparent,
            )
                : BorderSide(
              width: 1,
              color: Color(0xff364e80) ,
            ),
            right: select == 2
                ? BorderSide(
              width: 1,
              color: Colors.transparent,
            )
                : BorderSide(
              width: 1,
              color: Color(0xff364e80) ,
            ),
          ),
        ),
        child: child,
      ),
      onTap: this.onTap,
    );
  }
}
