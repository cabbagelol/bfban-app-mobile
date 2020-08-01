/// 用户中心

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter_plugin_elui/elui.dart';
import 'package:flutter/widgets.dart';

import 'package:bfban/constants/api.dart';
import 'package:bfban/router/router.dart';
import 'package:bfban/utils/index.dart';
import 'package:bfban/widgets/index.dart';

class usercenter extends StatefulWidget {
  @override
  _usercenterState createState() => _usercenterState();
}

class _usercenterState extends State<usercenter> {
  UrlUtil _urlUtil = new UrlUtil();

  /// 用户信息
  Map userInfo;

  /// 用户状态
  bool userInfoState = false;

  @override
  void initState() {
    super.initState();

    this.getUserInfo();
  }

  /// 获取用户信息
  void getUserInfo() async {
    dynamic result = await Storage.get('com.bfban.login');

    if (result == null) {
      return;
    }

    dynamic data = jsonDecode(result);

    setState(() {
      userInfo = data;
      userInfoState = data.toString().length > 0 ? true : false;
    });
  }

  /// 销毁用户信息
  void remUserInfo() async {
    await Storage.remove('com.bfban.login');

    Response result = await Http.request(
      'api/account/signout',
      headers: {'Cookie': await Storage.get("com.bfban.cookie")},
      method: Http.GET,
    );

    if (result.data["error"] == 0) {
      List list = [
        "cookie",
        "token",
        "login",
      ];

      list.forEach((i) => {
            Storage.remove("com.bfban.$i"),
          });

      EluiMessageComponent.success(context)(
        child: Text("注销成功"),
      );
      setState(() {
        userInfoState = false;
      });
    } else {
      EluiMessageComponent.error(context)(
        child: Text("注册错误,请联系开发者"),
      );
    }
  }

  /// 打开权限中心
  void _opEnPermanently () async {
    openAppSettings();
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
                      '\u5ba3\u5165\u53cd\u4f5c\u5f0a\u8054\u76df\uff0c',
                      style: TextStyle(color: Colors.white, fontSize: 40),
                    ),
                    Text(
                      '\u7ef4\u62a4\u516c\u5e73\u7684\u7ade\u4e89\u73af\u5883',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    Wrap(
                      children: <Widget>[
                        Text('\u4f60\u613f\u52a0\u5165\u8054\u76df\u6210\u5458\u8d21\u732e\u4f5c\u5f0a\u8005\u540d\u5355\u5417\uff1f',
                            style: TextStyle(color: Colors.white, fontSize: 15)),
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
                    textLoad(
                      value: "\u0042\u0046\u0042\u0041\u004e\u8054\u76df",
                      fontSize: 40,
                    ),
                    Text(
                      '\u5236\u88c1\u4e0d\u4f1a\u7f3a\u5e2d',
                      style: TextStyle(
                        color: Colors.white24,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),

        /// 用户板块
        !userInfoState
            ? GestureDetector(
                onTap: () {
                  Routes.router
                      .navigateTo(
                    context,
                    '/login',
                    transition: TransitionType.cupertino,
                  )
                      .then((res) {
                    if (res == 'loginBack') {
                      this.getUserInfo();
                    }
                  });
                },
                child: EluiCellComponent(
                  theme: EluiCellTheme(
                    backgroundColor: Color.fromRGBO(255, 255, 255, .07),
                  ),
                  icons: Icon(
                    Icons.account_box,
                    color: Colors.white,
                  ),
                  title: "\u767b\u9646",
                ),
              )
            : EluiCellComponent(
                title: "\u7528\u6237\u540d\u79f0",
                theme: EluiCellTheme(
                  backgroundColor: Color.fromRGBO(255, 255, 255, .07),
                ),
                icons: Icon(
                  Icons.account_box,
                  color: Colors.white,
                ),
                cont: Wrap(
                  spacing: 5,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    Text(
                      "${userInfo['username']}",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    EluiTagComponent(
                      value: Config.usetIdentity[userInfo["userPrivilege"]][0].toString(),
                      color: EluiTagColor.succeed,
                      size: EluiTagSize.no2,
                    ),
                  ],
                ),
              ),
        Offstage(
          offstage: !userInfoState,
          child: EluiCellComponent(
            title: "\u4e3e\u62a5\u8bb0\u5f55",
            theme: EluiCellTheme(
              backgroundColor: Color.fromRGBO(255, 255, 255, .07),
            ),
            islink: true,
            onTap: () {
              Routes.router.navigateTo(
                context,
                '/record/-1',
                transition: TransitionType.cupertino,
              );
            },
          ),
        ),
        SizedBox(
          height: 20,
        ),
        EluiCellComponent(
          title: "\u7f51\u7ad9\u5730\u5740",
          label: "\u0042\u0046\u0042\u0041\u004e\u8054\u76df\u7f51\u7ad9",
          theme: EluiCellTheme(
            backgroundColor: Color.fromRGBO(255, 255, 255, .07),
          ),
          islink: true,
          onTap: () => _urlUtil.onPeUrl("https://bfban.com"),
        ),
        EluiCellComponent(
          title: "\u652f\u63f4",
          label: "\u7a0b\u5e8f\u6570\u636e\u7531\u4e0d\u540c\u670d\u52a1\u5546\u63d0\u4f9b",
          theme: EluiCellTheme(
            backgroundColor: Color.fromRGBO(255, 255, 255, .07),
          ),
          islink: true,
          onTap: () => _urlUtil.opEnPage(context, '/usercenter/support'),
        ),
        EluiCellComponent(
          title: "\u6743\u9650",
          theme: EluiCellTheme(
            backgroundColor: Color.fromRGBO(255, 255, 255, .07),
          ),
          islink: true,
          onTap: () => this._opEnPermanently(),
        ),
        EluiCellComponent(
          title: "\u7248\u672c",
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

        Offstage(
          offstage: !userInfoState,
          child: Padding(
            padding: EdgeInsets.only(
              top: 30,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            child: EluiButtonComponent(
              child: Text(
                "\u6ce8\u9500",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              type: ButtonType.error,
              onTap: () => this.remUserInfo(),
            ),
          ),
        ),
      ],
    );
  }
}
