/// 用户登录

import 'dart:ui' as ui;

import 'package:bfban/component/_captcha/index.dart';
import 'package:bfban/constants/api.dart';
import 'package:bfban/data/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_elui_plugin/elui.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import 'package:bfban/utils/index.dart';
import 'package:provider/provider.dart';

import '../../provider/userinfo_provider.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({Key? key}) : super(key: key);

  @override
  _SigninPageState createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final Storage _storage = Storage();

  /// 登录数据
  LoginStatus loginStatus = LoginStatus(
    load: false,
    parame: LoginStatusParame(
      username: "",
      password: "",
      visitType: "client-phone",
      cookie: "",
    ),
  );

  late Map<String, dynamic> localLoginRecord = {};

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
    ready();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void ready() async {
    StorageData localLoginRecordData = await _storage.get("login.localLoginRecord");
    setState(() {
      localLoginRecord = localLoginRecordData.value ?? {};
    });
  }

  /// [Response]
  /// 登陆
  void _onLogin() async {
    if (loginStatus.parame!.value.isEmpty) {
      EluiMessageComponent.error(context)(child: Text(FlutterI18n.translate(context, "app.signin.accountId")));
      return;
    } else if (loginStatus.parame!.password!.isEmpty) {
      EluiMessageComponent.error(context)(child: Text(FlutterI18n.translate(context, "app.signin.emptyPassword")));
      return;
    } else if (loginStatus.parame!.username!.isEmpty) {
      EluiMessageComponent.error(context)(child: Text(FlutterI18n.translate(context, "app.signin.emptyAccount")));
      return;
    }

    setState(() {
      loginStatus.load = true;
    });

    Response result = await Http.request(
      Config.httpHost["account_signin"],
      method: Http.POST,
      headers: {'Cookie': loginStatus.parame!.cookie},
      data: loginStatus.parame!.toMap,
    );

    if (result.data["success"] == 1) {
      late Map d = result.data["data"];

      d["time"] = DateTime.now().millisecondsSinceEpoch;
      if (d["userinfo"]["userAvatar"].toString().isNotEmpty) {
        localLoginRecord.addAll({
          d["userinfo"]["username"].toString(): d["userinfo"]["userAvatar"],
        });
      }

      TextInput.finishAutofillContext();

      Future.wait([
        _storage.set("login.localLoginRecord", value: localLoginRecord),
        // 持久存用户信息
        _storage.set("login", value: d),
      ]).then((value) {
        // 持久储存 -> 状态机 -> HTTP -> Widget

        // 用户数据状态管理 存用户账户
        ProviderUtil().ofUser(context).setData(result.data["data"]);

        // 设置http模块 token
        Http.setToken(result.data["data"]["token"]);

        // 更新消息
        ProviderUtil().ofChat(context).onUpDate();
      }).catchError((E) {
        EluiMessageComponent.error(context)(
          child: Text("$E"),
        );
      }).whenComplete(() => Navigator.pop(context, 'loginBack'));
    } else {
      EluiMessageComponent.error(context)(
        child: Text(result.data["code"]),
      );
    }

    setState(() {
      loginStatus.load = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double? avater = 40;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: ClipRect(
        child: Consumer<UserInfoProvider>(
          builder: (BuildContext context, data, Widget? child) {
            return Stack(
              fit: StackFit.loose,
              alignment: AlignmentDirectional.center,
              children: <Widget>[
                // Positioned(
                //   top: 0,
                //   bottom: 0,
                //   child: Container(),
                // ),
                BackdropFilter(
                  filter: ui.ImageFilter.blur(
                    sigmaX: 6.0,
                    sigmaY: 6.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      data.isLogin
                          ? const Center(
                              child: Icon(Icons.account_circle),
                            )
                          : Expanded(
                              flex: 1,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ClipOval(
                                    clipBehavior: Clip.hardEdge,
                                    child: localLoginRecord.containsKey(loginStatus.parame!.username)
                                        ? Image.network(localLoginRecord[loginStatus.parame!.username]!)
                                        : CircleAvatar(
                                            minRadius: avater,
                                            child: Icon(
                                              Icons.account_circle,
                                              size: avater + 10.0,
                                            ),
                                          ),
                                  ),
                                  const SizedBox(height: 50),
                                  Card(
                                    margin: const EdgeInsets.symmetric(horizontal: 20),
                                    child: EluiInputComponent(
                                      theme: EluiInputTheme(textStyle: Theme.of(context).textTheme.bodyMedium),
                                      placeholder: FlutterI18n.translate(context, "app.signin.accountId"),
                                      autofillHints: const [AutofillHints.username],
                                      onChange: (data) {
                                        setState(() {
                                          loginStatus.parame!.username = data["value"];
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
                                      theme: EluiInputTheme(textStyle: Theme.of(context).textTheme.bodyMedium),
                                      placeholder: FlutterI18n.translate(context, "app.signin.password"),
                                      autofillHints: const [AutofillHints.password],
                                      type: TextInputType.visiblePassword,
                                      onChange: (data) => loginStatus.parame!.password = data["value"],
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
                                      placeholder: FlutterI18n.translate(context, "captcha.title"),
                                      internalstyle: true,
                                      maxLenght: 4,
                                      theme: EluiInputTheme(textStyle: Theme.of(context).textTheme.bodyMedium),
                                      right: CaptchaWidget(
                                        context: context,
                                        seconds: 25,
                                        onChange: (Captcha captcha) => loginStatus.parame!.setCaptcha(captcha),
                                      ),
                                      onChange: (data) {
                                        setState(() {
                                          loginStatus.parame!.value = data["value"];
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                    child: TextButton(
                      child: loginStatus.load!
                          ? SizedBox(
                              height: 40,
                              child: ELuiLoadComponent(
                                type: "line",
                                lineWidth: 2,
                                color: Theme.of(context).textTheme.bodyMedium!.color!,
                                size: 25,
                              ),
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
      ),
    );
  }
}
