import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_plugin_elui/elui.dart';
import 'package:flutter_svg/svg.dart';

import 'package:bfban/widgets/edit/ImageRadioController.dart';

class editPage extends StatefulWidget {
  @override
  _editPageState createState() => _editPageState();
}

class _editPageState extends State<editPage> {
  ImageRadioController controller;

  int gameTypeIndex = 1;

  var images = [
    "https://file03.16sucai.com/2016/10/1100/16sucai_p20161017095_34f.JPG",
    "https://file03.16sucai.com/2016/10/1100/16sucai_p20161017095_34f.JPG",
    "https://file03.16sucai.com/2016/10/1100/16sucai_p20161017095_34f.JPG",
  ];

  @override
  void initState() {
    controller = new ImageRadioController();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            'assets/images/bk-companion.jpg',
          ),
          fit: BoxFit.fitHeight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "举报作弊",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        body: ListView(
          children: <Widget>[
            /// S 游戏类型
            Container(
              color: Color(0xff111b2b),
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "游戏",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(
                    width: 45,
                  ),
                  Row(
                    children: <Widget>[
                      gameTypeRadio(
                        select: 1,
                        index: gameTypeIndex == 1,
                        child: Image.asset(
                          "assets/images/edit/battlefield-1-logo.png",
                          width: 80,
                        ),
                        onTap: () {
                          setState(() {
                            gameTypeIndex = 1;
                          });
                        },
                      ),
                      gameTypeRadio(
                        select: 2,
                        index: gameTypeIndex == 2,
                        child: Image.asset(
                          "assets/images/edit/battlefield-v-png-logo.png",
                          width: 80,
                        ),
                        onTap: () {
                          setState(() {
                            gameTypeIndex = 2;
                          });
                        },
                      ),
                      gameTypeRadio(
                        select: 3,
                        index: gameTypeIndex == 3,
                        child: Image.asset(
                          "assets/images/edit/battlefield-v-png-logo.png",
                          width: 80,
                        ),
                        onTap: () {
                          setState(() {
                            gameTypeIndex = 3;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            /// E 游戏类型

            /// S 游戏ID
            Container(
              color: Color(0xff111b2b),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "游戏ID",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    flex: 1,
                    child: EluiInputComponent(
                      theme: EluiInputTheme(
                          textStyle: TextStyle(
                            color: Colors.white,
                          )
                      ),
                      Internalstyle: true,
                      value: "",
                      placeholder: "233",
                    ),
                  )
                ],
              ),
            ),
            /// E 游戏ID

            /// S 视频链接
            Container(
              color: Color(0xff111b2b),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "视频链接",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    flex: 1,
                    child: EluiInputComponent(
                      theme: EluiInputTheme(
                          textStyle: TextStyle(
                            color: Colors.white,
                          )
                      ),
                      Internalstyle: true,
                      value: "",
                      placeholder: "233",
                    ),
                  )
                ],
              ),
            ),
            /// E 视频链接
            Container(
              margin: EdgeInsets.only(top: 20),
              padding: EdgeInsets.all(20),
              child: Text(
                "信息",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
