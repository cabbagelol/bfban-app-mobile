/// 用户登录
import 'dart:ui' as ui;
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:bfban/utils/index.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_plugin_elui/elui.dart';
import 'package:flutter_svg/flutter_svg.dart';

class loginPage extends StatefulWidget {
  @override
  _loginPageState createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
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

  @override
  void initState() {
    super.initState();
    this._getCaptcha();
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
      backgroundColor: Color(0xff111b2b),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Opacity(
            opacity: 0.5,
            child: Image.asset(
              "assets/images/bk-companion-1.jpg",
              fit: BoxFit.cover,
            ),
          ),
          BackdropFilter(
            child: ListView(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(20),
                  child: Column(
                    children: <Widget>[
                      Container(
                        color: Colors.black26,
                        padding: EdgeInsets.only(
                          left: 10,
                          right: 10,
                        ),
                        child: EluiInputComponent(
                          placeholder: "输入账户ID",
                          Internalstyle: true,
                          theme: EluiInputTheme(
                            textStyle: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          onChange: (data) {
                            setState(() {
                              loginInfo["userController"] = data["value"];
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        height: 1,
                      ),
                      Container(
                        color: Colors.black26,
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
                              color: Colors.white,
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Container(
                              color: Colors.black26,
                              padding: EdgeInsets.only(
                                left: 10,
                                right: 10,
                              ),
                              child: EluiInputComponent(
                                placeholder: "验证码",
                                Internalstyle: true,
                                maxLenght: 4,
                                theme: EluiInputTheme(
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                right: GestureDetector(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(3),
                                      ),
                                    ),
                                    margin: EdgeInsets.only(left: 10),
                                    width: 60,
                                    height: 30,
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
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      EluiButtonComponent(
                        type: ButtonType.none,
                        child: loginLoad
                            ? ELuiLoadComponent(
                                type: "line",
                                lineWidth: 2,
                                color: Colors.white,
                              )
                            : Text(
                                "登陆",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                        onTap: () => _onLogin(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            filter: ui.ImageFilter.blur(
              sigmaX: 0.0,
              sigmaY: 0.0,
            ),
          ),
        ],
      ),
    );
  }
}
