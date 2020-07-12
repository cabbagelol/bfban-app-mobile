import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_plugin_elui/elui.dart';

import 'package:bfban/utils/storage.dart';
import 'package:bfban/utils/index.dart';

class loginPage extends StatefulWidget {
  @override
  _loginPageState createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  String valueCaptcha = "";
  String CaotchaCookie = "";
  bool valueCaptchaLoad = false;

  Widget buildTextField(TextEditingController controller, IconData icon,
      bool obscureText, TextAlign align, int length) {
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
      'api/captcha?r=${t}',
      method: Http.GET,
    );

    result.headers['set-cookie'].forEach((i) {
      CaotchaCookie += i + ';';
    });

    setState(() {
      valueCaptcha = result.data;
      valueCaptchaLoad = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userController = TextEditingController();
    final passController = TextEditingController();
    final verificationController = TextEditingController();

    /// 登陆
    void _onLogin() async {
      var self = this;
      var result = await Http.request(
        'api/account/signin',
        method: Http.POST,
        headers: {'Cookie': self.CaotchaCookie},
        data: {
          "captcha": verificationController.text.toString(),
          "password": "zsezse", // passController.text.toString()??
          "username": "cabbagelol" //  userController.text.toString()??
        },
      );

      if (result != null && result.data['error'] == 0) {
        Storage.set('com.bfban.login', value: jsonEncode(result.data['data']));
        Navigator.pop(context, 'loginBack');
      } else {
        switch (result.data["msg"]) {
          case "invalid captcha":
//            EluiMessageComponent.error(context)(child: Text("请输入验证码"));
            break;
        }
      }
    }

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bk-companion.jpg'),
          fit: BoxFit.fitHeight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "".toString(),
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
                    child: buildTextField(
                      userController,
                      Icons.supervised_user_circle,
                      false,
                      TextAlign.left,
                      30,
                    ),
                    margin: EdgeInsets.only(bottom: 10),
                  ),
                  Container(
                    child: buildTextField(
                      passController,
                      Icons.visibility,
                      true,
                      TextAlign.left,
                      30,
                    ),
                    margin: EdgeInsets.only(bottom: 10),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: buildTextField(
                          verificationController,
                          null,
                          false,
                          TextAlign.center,
                          5,
                        ),
                      ),
                      GestureDetector(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(5))
                          ),
                          margin: EdgeInsets.only(left: 10),
                          width: 100,
                          height: 55,
                          child: valueCaptchaLoad
                              ? Icon(
                                  Icons.slow_motion_video,
                                  color: Colors.black54,
                                )
                              : new SvgPicture.string(
                                  valueCaptcha,
                                ),
                        ),
                        onTap: () {
                          this._getCaptcha();
                        },
                      )
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    child: RaisedButton(
                      child: Text(
                        "登陆",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      color: Colors.black54,
                      onPressed: () {
                        _onLogin();
                      },
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
