/// 用户登录

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
  String valueCaptcha = "";

  String CaotchaCookie = "";

  bool valueCaptchaLoad = false;

  String userController = "";

  String passController = "";

  String verificationController = "";

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
      CaotchaCookie += i + ';';
    });

    Storage.set("com.bfban.cookie", value: CaotchaCookie);

    setState(() {
      valueCaptcha = result.data;
      valueCaptchaLoad = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    /// 登陆
    void _onLogin() async {

      if (verificationController == "") {
        EluiMessageComponent.error(context)(
          child: Text("请填写验证码")
        );
        return;
      } else if (passController == "") {
        EluiMessageComponent.error(context)(
            child: Text("请填写密码")
        );
        return;
      } else if (userController == "") {
        EluiMessageComponent.error(context)(
            child: Text("请填写用户名")
        );
        return;
      }

      Response result = await Http.request(
        'api/account/signin',
        method: Http.POST,
        headers: {'Cookie': this.CaotchaCookie},
        data: {
          "captcha": verificationController,
          "password": passController,
          "username": userController,
        },
      );

      if (result.data['error'] == 0) {
        Storage.set(
          'com.bfban.login',
          value: jsonEncode(result.data['data']),
        );
        Storage.set(
          'com.bfban.token',
          value: result.data['token'],
        );
        Navigator.pop(context, 'loginBack');
      } else {
        switch (result.data["msg"]) {
          case "invalid captcha":
            EluiMessageComponent.error(context)(
              child: Text("请输入验证码"),
            );
            break;
        }
      }
    }

    return Scaffold(
      backgroundColor: Color(0xff111b2b),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
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
                        userController = data["value"];
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
                        passController = data["value"];
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
                                      valueCaptcha,
                                    ),
                            ),
                            onTap: () => this._getCaptcha(),
                          ),
                          onChange: (data) {
                            setState(() {
                              verificationController = data["value"];
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
                  child: Text(
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
    );
  }
}
