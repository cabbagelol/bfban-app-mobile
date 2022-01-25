/// 登录面板

import 'dart:ui' as ui;

import 'package:bfban/utils/index.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/_button/index.dart';
import 'package:provider/provider.dart';

import '../../provider/userinfo_provider.dart';
import '../../utils/url.dart';

class LoginPanelPage extends StatefulWidget {
  const LoginPanelPage({Key? key}) : super(key: key);

  @override
  _LoginPanelState createState() => _LoginPanelState();
}

class _LoginPanelState extends State<LoginPanelPage> {
  final UrlUtil _urlUtil = UrlUtil();

  /// [Event]
  /// 取消
  _pop() {
    _urlUtil.popPage(context);
  }

  /// [Event]
  /// 登录
  dynamic _openSignin() {
    _urlUtil.opEnPage(
      context,
      '/signin',
      transition: TransitionType.materialFullScreenDialog,
    ).then((value) {
      if (ProviderUtil().ofUser(context).isLogin) {
        _urlUtil.popPage(context);
      }
    });
  }

  /// [Event]
  /// 注册
  dynamic _openSignup() {
    _urlUtil.opEnPage(context, '/signup').then((value) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              _urlUtil.opEnPage(context, "/network");
            },
            icon: Icon(Icons.electrical_services),
          ),
        ],
      ),
      body: Consumer<UserInfoProvider>(
        builder: (BuildContext context, data, Widget? child) {
          return Stack(
            fit: StackFit.loose,
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      child: Image.asset("assets/images/bfban-logo.png"),
                    ),
                    SizedBox(height: 15),
                    Text(
                      "BFBAN",
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "欢迎使用 BFBAN App",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.subtitle2!.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 50),
                    MaterialButton(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      color: Theme.of(context).appBarTheme.backgroundColor,
                      elevation: 5,
                      onPressed: () {
                        _openSignin();
                      },
                      child: Text("BFBAN 账户登录"),
                    ),
                    SizedBox(height: 20),
                    MaterialButton(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      color: Theme.of(context).backgroundColor,
                      elevation: 0,
                      onPressed: () {
                        _pop();
                      },
                      child: Text("取消"),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black87,
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        child: Wrap(
                          spacing: 5,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: const [
                            Text(
                              "注册BFBAN账户",
                              style: TextStyle(
                                color: Colors.white54,
                              ),
                            ),
                            Icon(
                              Icons.open_in_new,
                              color: Colors.white54,
                              size: 18,
                            ),
                          ],
                        ),
                        onTap: () =>
                            _urlUtil.onPeUrl("https://bfban.com/#/signup"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
