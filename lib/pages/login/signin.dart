/// 用户登录

import 'dart:ui' as ui;
import 'dart:convert';

import 'package:bfban/constants/api.dart';
import 'package:bfban/data/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_elui_plugin/elui.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:bfban/utils/index.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:provider/provider.dart';

import '../../provider/userinfo_provider.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({Key? key}) : super(key: key);

  @override
  _SigninPageState createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  /// 登录数据
  LoginStatus loginStatus = LoginStatus(
    load: false,
    username: "cabbagelol_T",
    password: "zsezse",
    captcha: Captcha(
      load: false,
      cookie: "",
    ),
  );

  Widget buildTextField(TextEditingController controller, IconData icon, bool obscureText, TextAlign align, int length) {
    return TextField(
      controller: controller,
      maxLengthEnforcement: MaxLengthEnforcement.none,
      maxLength: length,
      maxLines: 1,
      autocorrect: true,
      autofocus: true,
      obscureText: obscureText,
      textAlign: align,
      style: const TextStyle(
        fontSize: 30.0,
        color: Colors.white,
      ),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(10),
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
    _getCaptcha();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// [Response]
  /// 更新验证码
  void _getCaptcha() async {
    String time = DateTime.now().millisecondsSinceEpoch.toString();

    setState(() {
      loginStatus.captcha!.load = true;
    });

    Response result = await Http.request(
      "${Config.httpHost["captcha"]}?t=$time",
      method: Http.GET,
    );

    if (result.data["success"] == 1) {
      final d = result.data["data"];

      result.headers['set-cookie']?.forEach((i) {
        loginStatus.captcha?.cookie += i + ';';
      });

      // await ProviderUtil().ofApp(context).Storage_OS.set("com.bfban.cookie", value: loginStatus.captcha?.cookie);

      setState(() {
        loginStatus.captcha!.hash = d["hash"];
        loginStatus.captcha!.captchaSvg = d["content"];
      });
    }

    setState(() {
      loginStatus.captcha!.load = false;
    });
  }

  /// [Response]
  /// 登陆
  void _onLogin() async {
    if (loginStatus.captcha!.value.isEmpty) {
      EluiMessageComponent.error(context)(child: Text(translate("signin.accountId")));
      return;
    } else if (loginStatus.password!.isEmpty) {
      EluiMessageComponent.error(context)(child: Text(translate("signin.emptyPassword")));
      return;
    } else if (loginStatus.username!.isEmpty) {
      EluiMessageComponent.error(context)(child: Text(translate("signin.emptyAccount")));
      return;
    }

    setState(() {
      loginStatus.load = true;
    });

    Response result = await Http.request(
      Config.httpHost["account_signin"],
      method: Http.POST,
      headers: {'Cookie': loginStatus.captcha!.cookie},
      data: {
        "data": loginStatus.toMap,
        "encryptCaptcha": loginStatus.captcha!.hash,
        "captcha": loginStatus.captcha!.value,
      },
    );

    if (result.data["success"] == 1) {
      late Map d = result.data["data"];
      d["time"] = DateTime.now().millisecondsSinceEpoch;

      Future.wait([
        // 持久存用户信息
        Storage().set(
          'com.bfban.login',
          value: jsonEncode(d),
        ),
      ]).then((value) {
        // 持久储存 -> 状态机 -> HTTP -> Widget

        // 用户数据状态管理 存用户账户
        ProviderUtil().ofUser(context).setData(result.data["data"]);

        // 设置http模块 token
        Http.setToken(result.data["data"]["token"]);

        // 更新消息
        ProviderUtil().ofMessage(context).onUpDate();
      }).catchError((E) {
        EluiMessageComponent.error(context)(
          child: Text("$E"),
        );
      }).whenComplete(() => Navigator.pop(context, 'loginBack'));
    } else {
      switch (result.data["msg"]) {
        case "invalid captcha":
          EluiMessageComponent.error(context)(
            child: const Text("请输入验证码"),
          );
          break;
        case "captcha expires":
        case "wrong captcha":
          EluiMessageComponent.error(context)(
            child: const Text("错误的验证码"),
          );
          break;
        case "User not found or password mismatch":
          EluiMessageComponent.error(context)(
            child: const Text("用户名或密码错误"),
          );
          break;
        default:
          EluiMessageComponent.error(context)(
            child: Text(result.toString()),
          );
      }
      _getCaptcha();
    }

    setState(() {
      loginStatus.load = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomRight,
              colors: [Colors.transparent, Colors.black54],
            ),
          ),
        ),
      ),
      body: Consumer<UserInfoProvider>(
        builder: (BuildContext context, data, Widget? child) {
          return Stack(
            fit: StackFit.loose,
            children: <Widget>[
              // Positioned(
              //   top: 0,
              //   bottom: 0,
              //   child: Image.asset(
              //     "assets/images/bk-companion.jpg",
              //     fit: BoxFit.cover,
              //   ),
              // ),
              BackdropFilter(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    data.isLogin
                        ? const Center(
                            child: Text("已登录"),
                          )
                        : Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 20),
                                  child: EluiInputComponent(
                                    placeholder: translate("signin.accountId"),
                                    internalstyle: true,
                                    onChange: (data) {
                                      setState(() {
                                        loginStatus.username = data["value"];
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 20),
                                  child: EluiInputComponent(
                                    placeholder: translate("signin.password"),
                                    type: TextInputType.visiblePassword,
                                    internalstyle: true,
                                    onChange: (data) {
                                      setState(() {
                                        loginStatus.password = data["value"];
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Card(
                                  clipBehavior: Clip.none,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: EluiInputComponent(
                                    placeholder: translate("signin.verificationCode"),
                                    internalstyle: true,
                                    maxLenght: 4,
                                    right: GestureDetector(
                                      child: AnimatedContainer(
                                        duration: const Duration(seconds: 1),
                                        margin: const EdgeInsets.only(left: 10),
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        height: 50,
                                        width: 100,
                                        child: loginStatus.captcha!.load
                                            ? const ELuiLoadComponent(
                                                type: "line",
                                                color: Colors.black,
                                                lineWidth: 2,
                                                size: 20,
                                              )
                                            : SvgPicture.string(
                                                loginStatus.captcha!.captchaSvg,
                                                color: Theme.of(context).textTheme.bodyText1!.color,
                                              ),
                                      ),
                                      onTap: () => _getCaptcha(),
                                    ),
                                    onChange: (data) {
                                      setState(() {
                                        loginStatus.captcha!.value = data["value"];
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ],
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
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
                  child: TextButton(
                    child: loginStatus.load
                        ? const SizedBox(
                            height: 40,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const SizedBox(
                            height: 40,
                            child: Icon(
                              Icons.done,
                            ),
                          ),
                    onPressed: () => _onLogin(),
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
