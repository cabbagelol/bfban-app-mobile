import 'dart:convert';

import 'package:bfban/pages/detail/cheaters.dart';
import 'package:bfban/router/router.dart';
import 'package:bfban/utils/storage.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_plugin_elui/elui.dart';

class usercenter extends StatefulWidget {
  @override
  _usercenterState createState() => _usercenterState();
}

class _usercenterState extends State<usercenter> {
  /// 用户信息
  Map userInfo;

  /// 用户状态
  bool userInfoState = false;

  @override
  void initState() {
    super.initState();

    this.getUserInfo();
  }

  /**
   * 获取用户信息
   */
  getUserInfo() async {
    var result = await Storage.get('com.bfban.login');

    if (result == null) {
      return;
    }

    var data = jsonDecode(result);

    setState(() {
      userInfo = data;
      userInfoState = data.toString().length > 0 ? true : false;
    });
  }

  /**
   * 销毁用户信息
   */
  remUserInfo() async {
    await Storage.remove('com.bfban.login');
    setState(() {
      userInfoState = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        !userInfoState
            ? Container(
                padding: EdgeInsets.all(40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      child: Align(
                        child: Image.asset(
                          "assets/images/bfban-logo.png",
                          width: 60,
                          height: 60,
                        ),
                      ),
                      padding: EdgeInsets.only(bottom: 20),
                    ),
                    Text(
                      '宣入反作弊联盟，',
                      style: TextStyle(color: Colors.white, fontSize: 40),
                    ),
                    Text(
                      '维护公平的竞争环境',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    Wrap(
                      children: <Widget>[
                        Text('你愿加入联盟成员贡献作弊者名单吗？', style: TextStyle(color: Colors.white, fontSize: 15)),
                      ],
                    ),
                  ],
                ),
              )
            : Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'BFBAN联盟',
                      style: TextStyle(color: Colors.white, fontSize: 40),
                    ),
                    Text(
                      '制裁不会缺席',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ],
                ),
              ),

        /// 用户板块
        !userInfoState
            ? GestureDetector(
                onTap: () {
                  Routes.router.navigateTo(context, '/login', transition: TransitionType.fadeIn).then((res) {
                    if (res == 'loginBack') {
                      this.getUserInfo();
                    }
                  });
                },
                child: detailCheatersCard(
                  value: "登陆",
                  cont: "",
                  type: "1",
                ),
              )
            : EluiCellComponent(
                title: "用户名称",
                theme: EluiCellTheme(
                  backgroundColor: Color.fromRGBO(255, 255, 255, .07),
                ),
                cont: Text(
                  "${userInfo['username']}",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Routes.router.navigateTo(
                    context,
                    '/record',
                    transition: TransitionType.cupertino,
                  );
                },
              ),
        userInfoState
            ? EluiCellComponent(
                title: "举报记录",
                theme: EluiCellTheme(
                  backgroundColor: Color.fromRGBO(255, 255, 255, .07),
                ),
                islink: true,
                onTap: () {
                  Routes.router.navigateTo(
                    context,
                    '/record',
                    transition: TransitionType.cupertino,
                  );
                },
              )
            : Container(),
        Padding(
          padding: EdgeInsets.only(bottom: 20),
        ),

        EluiCellComponent(
          title: "网站地址",
          theme: EluiCellTheme(
            backgroundColor: Color.fromRGBO(255, 255, 255, .07),
          ),
          cont: Text(
            "https://bfban.com",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        EluiCellComponent(
          title: "版本",
          theme: EluiCellTheme(
            backgroundColor: Color.fromRGBO(255, 255, 255, .07),
          ),
          cont: Text(
            "0.0.1",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),

        userInfoState
            ? Padding(
                padding: EdgeInsets.only(
                  top: 30,
                  left: 20,
                  right: 20,
                ),
                child: EluiButtonComponent(
                  child: Text(
                    "注销",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    this.remUserInfo();
                  },
                ),
              )
            : Container()
      ],
    );
  }
}
