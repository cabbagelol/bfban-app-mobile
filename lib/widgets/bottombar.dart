/// 功能：首页底部导航
/// 描述：

import 'package:flutter/material.dart';

import 'package:bfban/utils/screen_util.dart';
import 'package:bfban/constants/index.dart';

class BottomAppBarItemModal {
  final Map iconData;
  final String text;

  BottomAppBarItemModal(
    this.iconData,
    this.text,
  );
}

class BottomAppBarItem extends StatelessWidget {
  final iconData;
  final String text;
  final Color color;
  final ValueChanged<int> onTabSeleted;
  final int index;

  BottomAppBarItem(
    this.iconData,
    this.text,
    this.color,
    this.onTabSeleted,
    this.index,
  );

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Container(
        child: GestureDetector(
          onTap: () => onTabSeleted(index),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
//              Image.asset(iconData, width: 20, height: 20),
              iconData,
              Container(
                margin: EdgeInsets.only(top: 2),
                child: Text(
                  text,
                  style: TextStyle(color: color, fontSize: 12),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class KKBottomAppBar extends StatefulWidget {
  final List<BottomAppBarItemModal> items;
  final ValueChanged<int> onTabSeleted;
  final Color actviveColor;
  final Color color;

  KKBottomAppBar({
    this.items,
    this.onTabSeleted,
    this.actviveColor,
    this.color,
  }) : super();

  @override
  BottomAppBarState createState() => BottomAppBarState();
}

class BottomAppBarState extends State<KKBottomAppBar> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    int l = widget.items.length;
    double bottom = ScreenUtil.bottomBarHeight; //IPhone 底部
    List<BottomAppBarItem> listWidgets = List.generate(l, (index) {
      BottomAppBarItemModal i = widget.items[index];
      return BottomAppBarItem(
        index == currentIndex ? i.iconData["icon_s"] : i.iconData["icon"],
        i.text,
        index == currentIndex ? widget.actviveColor : widget.color,
        onItemTap,
        index,
      );
    });
    return Container(
      height: Klength.bottomBarHeight,
      color: Color.fromRGBO(0, 0, 0, .7),
      alignment: Alignment.center,
      margin: EdgeInsets.only(bottom: bottom),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: listWidgets,
      ),
    );
  }

  onItemTap(int i) {
    setState(() => this.currentIndex = i);

    widget.onTabSeleted(i);
  }
}
