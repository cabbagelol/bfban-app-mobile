/// 用户中心

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';

import 'package:bfban/constants/api.dart';
import 'package:flutter_plugin_elui/elui.dart';
import 'package:flutter/widgets.dart';

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
                    textLoad(
                      value: "BFBAN联盟",
                      fontSize: 40,
                    ),
                    Text(
                      '制裁不会缺席',
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
                  title: "登陆",
                ),
              )
            : EluiCellComponent(
                title: "用户名称",
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
                )),
        Offstage(
          offstage: !userInfoState,
          child: EluiCellComponent(
            title: "举报记录",
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
          title: "网站地址",
          label: "BFBAN联盟网站",
          theme: EluiCellTheme(
            backgroundColor: Color.fromRGBO(255, 255, 255, .07),
          ),
          islink: true,
          onTap: () => _urlUtil.onPeUrl("https://bfban.com"),
        ),
        EluiCellComponent(
          title: "支援",
          label: "程序数据由不同服务商提供",
          theme: EluiCellTheme(
            backgroundColor: Color.fromRGBO(255, 255, 255, .07),
          ),
          islink: true,
          onTap: () => _urlUtil.opEnPage(context, '/usercenter/support'),
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
                "注销",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              type: ButtonType.error,
              onTap: () {
                this.remUserInfo();
              },
            ),
          ),
        ),
      ],
    );
  }
}
