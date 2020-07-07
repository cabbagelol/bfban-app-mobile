/**
 * 功能：首页控制器
 * 描述：导航切换
 */

import 'package:flutter/material.dart';

import 'package:bfban/widgets/index.dart';
import 'package:bfban/utils/index.dart';
import 'package:bfban/constants/index.dart';

import 'home.dart';
import 'usercenter.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  PageController pageController;
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: Klength.designWidth)..init(context);

    List<Widget> widgets = [homePage(), usercenter()];

    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bk-companion.jpg'),
            fit: BoxFit.fitHeight,
          ),
        ),
        child: Column(
          children: <Widget>[
            Expanded(
                flex: 1,
                child: IndexedStack(
                  children: widgets,
                  index: currentPage,
                ),
            ),
            KKBottomAppBar(
              onTabSeleted: onTap,
              actviveColor: Colors.yellow,
              color: Colors.white,
              items: [
                BottomAppBarItemModal(
                  {
                    "icon": Icon(
                      Icons.home,
                      color: Colors.white,
                    ),
                    "icon_s": Icon(
                      Icons.home,
                      color: Colors.yellow,
                    ),
                  },
                  '首页',
                ),
                BottomAppBarItemModal(
                  {
                    "icon": Icon(
                      Icons.my_location,
                      color: Colors.white,
                    ),
                    "icon_s": Icon(
                      Icons.my_location,
                      color: Colors.yellow,
                    ),
                  },
                  '个人中心',
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  void onTap(int index) {
    setState(() {
      this.currentPage = index;
    });
  }
}
