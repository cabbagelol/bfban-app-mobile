/// 用户登录
import 'dart:ui' as ui;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_plugin_elui/elui.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:bfban/utils/index.dart';
import 'package:bfban/constants/theme.dart';

import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';

class loginPage extends StatefulWidget {
  @override
  _loginPageState createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  Map theme = THEMELIST['none'];

  /// 登录数据
  Map loginInfo = {
    "valueCaptcha": "",
    "CaotchaCookie": "",
    "userController": "",
    "passController": "",
    "verificationController": "",
  };

  bool valueCaptchaLoad = false;

  bool loginLoad = false;

  Widget buildTextField(TextEditingController controller, IconData icon, bool obscureText, TextAlign align, int length) {
    return TextField(
      controller: controller,
      maxLength: length,
      maxLengthEnforced: true,
      maxLines: 1,
      autocorrect: true,
      autofocus: true,
      obscureText: obscureText,
      textAlign: align,
      style: TextStyle(
        fontSize: 30.0,
        color: Colors.white,
      ),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        fillColor: Colors.black54,
        filled: true,
        prefixIcon: Icon(
          icon,
          color: Colors.white,
        ),
      ),
      enabled: true, //是否禁用
    );
  }

  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    this._getCaptcha();

    _controller = VideoPlayerController.asset('assets/video/bf-video-hero-medium-steam-launch.mp4')
      ..initialize().then((_) {
        setState(() {});
      })
      ..setLooping(true);
    _controller.play();

    this.onReadyTheme();
  }

  void onReadyTheme() async {
    /// 初始主题
    Map _theme = await ThemeUtil().ready(context);
    setState(() => theme = _theme);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  /// 更新验证码
  void _getCaptcha() async {
    var t = DateTime.now().millisecondsSinceEpoch.toString();

    setState(() {
      valueCaptchaLoad = true;
    });

    Response<dynamic> result = await Http.request(
      'api/captcha?r=$t',
      method: Http.GET,
    );

    result.headers['set-cookie'].forEach((i) {
      loginInfo["CaotchaCookie"] += i + ';';
    });

    Storage.set("com.bfban.cookie", value: loginInfo["CaotchaCookie"]);

    setState(() {
      loginInfo["valueCaptcha"] = result.data;
      valueCaptchaLoad = false;
    });
  }

  /// 登陆
  void _onLogin() async {
    if (loginInfo["verificationController"] == "") {
      EluiMessageComponent.error(context)(child: Text("请填写验证码"));
      return;
    } else if (loginInfo["passController"] == "") {
      EluiMessageComponent.error(context)(child: Text("请填写密码"));
      return;
    } else if (loginInfo["userController"] == "") {
      EluiMessageComponent.error(context)(child: Text("请填写用户名"));
      return;
    }

    setState(() {
      loginLoad = true;
    });

    Response result = await Http.request(
      'api/account/signin',
      method: Http.POST,
      headers: {'Cookie': loginInfo["CaotchaCookie"]},
      data: {
        "captcha": loginInfo["verificationController"],
        "password": loginInfo["passController"],
        "username": loginInfo["userController"],
      },
    );

    if (result.data['error'] == 0) {
      Storage.set(
        'com.bfban.login',
        value: jsonEncode(result.data['data']),
      );
      Storage.set(
        'com.bfban.token',
        value: jsonEncode({
          "value": result.data['token'],
          "time": new DateTime.now().millisecondsSinceEpoch,
        }),
      );

      Http.setToken(result.data['token']);
      Navigator.pop(context, 'loginBack');
    } else {
      switch (result.data["msg"]) {
        case "invalid captcha":
          EluiMessageComponent.error(context)(
            child: Text("请输入验证码"),
          );
          break;
        case "captcha expires":
        case "wrong captcha":
          EluiMessageComponent.error(context)(
            child: Text("错误的验证码"),
          );
          break;
        case "username or password wrong":
          EluiMessageComponent.error(context)(
            child: Text("用户名或密码错误"),
          );
          break;
        default:
          EluiMessageComponent.error(context)(
            child: Text(result.toString()),
          );
      }

      this._getCaptcha();
    }

    setState(() {
      loginLoad = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: theme['appBar']['flexibleSpace'],
      ),
      body: Stack(
        fit: StackFit.loose,
        children: <Widget>[
          Positioned(
            top: 0,
            bottom: 0,
            child: Container(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            ),
          ),
          BackdropFilter(
            child: Container(
              child: Column(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: ListView(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          color: theme['input']['prominent'] ??Color(0xff111b2b),
                          padding: EdgeInsets.only(
                            left: 10,
                            right: 10,
                          ),
                          child: EluiInputComponent(
                            placeholder: "输入账户ID",
                            Internalstyle: true,
                            theme: EluiInputTheme(
                              textStyle: TextStyle(
                                color: theme['text']['subtitle'] ?? Colors.white,
                              ),
                            ),
                            onChange: (data) {
                              setState(() {
                                loginInfo["userController"] = data["value"];
                              });
                            },
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          color:theme['input']['prominent'] ?? Color(0xff111b2b),
                          padding: EdgeInsets.only(
                            left: 10,
                            right: 10,
                          ),
                          child: EluiInputComponent(
                            placeholder: "密码",
                            type: TextInputType.visiblePassword,
                            Internalstyle: true,
                            theme: EluiInputTheme(
                              textStyle: TextStyle(
                                color: theme['text']['subtitle'] ?? Colors.white,
                              ),
                            ),
                            onChange: (data) {
                              setState(() {
                                loginInfo["passController"] = data["value"];
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          color: theme['input']['prominent'] ?? Color(0xff111b2b),
                          padding: EdgeInsets.only(
                            left: 10,
                          ),
                          child: EluiInputComponent(
                            placeholder: "验证码",
                            Internalstyle: true,
                            maxLenght: 4,
                            theme: EluiInputTheme(
                              textStyle: TextStyle(
                                color: theme['text']['subtitle'] ?? Colors.white,
                              ),
                            ),
                            right: GestureDetector(
                              child: Container(
                                color: Colors.white,
                                margin: EdgeInsets.only(left: 10),
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                height: 50,
                                child: valueCaptchaLoad
                                    ? Icon(
                                        Icons.access_time,
                                        color: Colors.black54,
                                      )
                                    : new SvgPicture.string(
                                        loginInfo["valueCaptcha"],
                                      ),
                              ),
                              onTap: () => this._getCaptcha(),
                            ),
                            onChange: (data) {
                              setState(() {
                                loginInfo["verificationController"] = data["value"];
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              color: theme['login_index']['backgroundColor'] ?? Color.fromRGBO(17, 27, 43, .8),
            ),
            filter: ui.ImageFilter.blur(
              sigmaX: 6.0,
              sigmaY: 6.0,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
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
                    EluiButtonComponent(
                      type: ButtonType.none,
                      theme: EluiButtonTheme(
                        backgroundColor: theme['button']['backgroundColor'] ?? Color(0xff364e80),
                      ),
                      child: loginLoad
                          ? ELuiLoadComponent(
                              type: "line",
                              lineWidth: 2,
                              color: theme['button']['textColor'] ?? Colors.white,
                            )
                          : Icon(
                              Icons.done,
                              color: theme['button']['textColor'] ?? Colors.white,
                            ),
                      onTap: () => _onLogin(),
                    ),
                    SizedBox(
                      height: 30,
                      child: Center(
                        child: Text(
                          "or",
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      child: Wrap(
                        spacing: 5,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
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
                      onTap: () => UrlUtil().onPeUrl("https://bfban.com/#/signup"),
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}
