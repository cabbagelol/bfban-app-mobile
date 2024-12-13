/// 用户登录
library;

import 'dart:math';
import 'dart:ui' as ui;

import 'package:bfban/component/_captcha/index.dart';
import 'package:bfban/component/_loading/index.dart';
import 'package:bfban/constants/api.dart';
import 'package:bfban/data/index.dart';
import 'package:bfban/utils/http_token.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_elui_plugin/elui.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:bfban/utils/index.dart';
import 'package:provider/provider.dart';

import '../../provider/userinfo_provider.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  SigninPageState createState() => SigninPageState();
}

class SigninPageState extends State<SigninPage> {
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

  final TextEditingController _accountController = TextEditingController(text: "");

  final TextEditingController _passwordController = TextEditingController(text: "");

  final TextEditingController _captchaController = TextEditingController(text: "");

  List games = ['bf1', 'bf6', 'bfv'];

  bool _passwordShow = false;

  List _backdropImages = [];

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
    onReady();
    super.initState();
  }

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    _captchaController.dispose();
    super.dispose();
  }

  void onReady() async {
    StorageData localLoginRecordData = await _storage.get("login.localLoginRecord");

    _accountController.addListener(() {
      setState(() {
        loginStatus.parame!.username = _accountController.text;
      });
    });

    _passwordController.addListener(() {
      setState(() {
        loginStatus.parame!.password = _passwordController.text;
      });
    });

    _captchaController.addListener(() {
      setState(() {
        loginStatus.parame!.value = _captchaController.text;
      });
    });

    setState(() {
      _backdropImages = List.generate(20, (q) => games[Random().nextInt(games.length)]);
      localLoginRecord = localLoginRecordData.value ?? {};
    });
  }

  /// [Response]
  /// 登陆
  void _onLogin() async {
    try {
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

      dynamic d = result.data;

      if (result.data["success"] == 1) {
        late Map dList = d["data"];

        EluiMessageComponent.success(context)(
          child: Text(FlutterI18n.translate(
            context,
            "appStatusCode.${d["code"].replaceAll(".", "_")}",
            translationParams: {"message": d["message"] ?? ""},
          )),
        );

        dList["time"] = DateTime.now().millisecondsSinceEpoch;
        if (dList["userinfo"]["userAvatar"].toString().isNotEmpty) {
          localLoginRecord.addAll({
            dList["userinfo"]["username"].toString(): dList["userinfo"]["userAvatar"],
          });
        }

        TextInput.finishAutofillContext();

        Future.wait([
          _storage.set("login.localLoginRecord", value: localLoginRecord),
          // 持久存用户信息
          _storage.set("login", value: dList),
        ]).then((value) {
          // 持久储存 -> 状态机 -> HTTP -> Widget

          // 用户数据状态管理 存用户账户
          ProviderUtil().ofUser(context).setData(result.data["data"]);

          // 设置http模块 token
          HttpToken.setToken(result.data["data"]["token"]);

          // 更新消息
          ProviderUtil().ofChat(context).onUpDate();
        }).catchError((err) {
          throw err;
        }).whenComplete(() => Navigator.pop(context, 'loginBack'));
      } else {
        EluiMessageComponent.error(context)(
            child: Text(FlutterI18n.translate(
              context,
              "appStatusCode.${d["code"].replaceAll(".", "_")}",
              translationParams: {"message": d["message"] ?? ""},
            )),
            duration: 10000);
      }

      setState(() {
        loginStatus.load = false;
      });
    } catch (err) {
      EluiMessageComponent.error(context)(
        child: Text(err.toString()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double avater = 40;

    return Scaffold(
      appBar: AppBar(
        primary: true,
        excludeHeaderSemantics: true,
        backgroundColor: Colors.transparent,
      ),
      body: ClipRect(
        child: Consumer<UserInfoProvider>(
          builder: (BuildContext context, data, Widget? child) {
            return Stack(
              children: <Widget>[
                Positioned.fill(
                  top: 10,
                  child: Opacity(
                    opacity: .05,
                    child: StaggeredGrid.count(
                      crossAxisCount: 3,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      children: [
                        ..._backdropImages.map(
                          (i) => Transform.rotate(
                            angle: 15 * 3.14159 / 180, // 旋转45度
                            child: Image.asset(
                              "assets/images/games/$i/bf.jpg",
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                BackdropFilter(
                  filter: ui.ImageFilter.blur(
                    sigmaX: 15.0,
                    sigmaY: 15.0,
                  ),
                  child: ListView(
                    children: [
                      data.isLogin
                          ? const Center(
                              child: Icon(Icons.account_circle),
                            )
                          : AutofillGroup(
                              onDisposeAction: AutofillContextAction.commit,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ClipOval(
                                    clipBehavior: Clip.hardEdge,
                                    child: localLoginRecord.containsKey(loginStatus.parame!.username)
                                        ? Image.network(localLoginRecord[loginStatus.parame!.username]!)
                                        : CircleAvatar(
                                            backgroundColor: Theme.of(context).primaryColor,
                                            minRadius: avater,
                                            child: Icon(
                                              Icons.account_circle,
                                              size: avater + 10.0,
                                            ),
                                          ),
                                  ),
                                  const SizedBox(height: 50),
                                  Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 20),
                                    child: TextFormField(
                                      controller: _accountController,
                                      autofocus: true,
                                      autocorrect: true,
                                      decoration: InputDecoration(
                                        hintText: FlutterI18n.translate(context, "app.signin.accountId"),
                                        prefixIcon: Icon(Icons.supervisor_account),
                                        border: OutlineInputBorder(),
                                        counterText: "",
                                        suffixIcon: _accountController.text.isNotEmpty
                                            ? IconButton(
                                                icon: Icon(Icons.clear),
                                                onPressed: () {
                                                  _accountController.clear();
                                                },
                                              )
                                            : null,
                                      ),
                                      maxLength: 40,
                                      autofillHints: [AutofillHints.username, AutofillHints.email],
                                      textInputAction: TextInputAction.next,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 20),
                                    child: Center(
                                      child: TextFormField(
                                        controller: _passwordController,
                                        decoration: InputDecoration(
                                          hintText: FlutterI18n.translate(context, "app.signin.password"),
                                          prefixIcon: Icon(Icons.password),
                                          border: OutlineInputBorder(),
                                          suffixIcon: AnimatedSwitcher(
                                            duration: Duration(milliseconds: 250),
                                            transitionBuilder: (Widget child, Animation<double> animation) {
                                              return ScaleTransition(scale: animation, child: child);
                                            },
                                            child: IconButton(
                                              key: ValueKey<bool>(_passwordShow),
                                              icon: Icon(_passwordShow ? Icons.remove_red_eye_rounded : Icons.remove_red_eye_outlined),
                                              onPressed: () {
                                                setState(() {
                                                  _passwordShow = !_passwordShow;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                        autofillHints: [AutofillHints.password],
                                        textInputAction: TextInputAction.done,
                                        obscureText: !_passwordShow,
                                        keyboardType: _passwordShow ? TextInputType.text : TextInputType.visiblePassword,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 20),
                                    child: TextFormField(
                                      controller: _captchaController,
                                      decoration: InputDecoration(
                                        hintText: FlutterI18n.translate(context, "captcha.title"),
                                        prefixIcon: Icon(Icons.closed_caption),
                                        border: OutlineInputBorder(),
                                        suffixIcon: CaptchaWidget(
                                          context: context,
                                          seconds: 25,
                                          onChange: (Captcha captcha) => loginStatus.parame!.setCaptcha(captcha),
                                        ),
                                      ),
                                      maxLength: 4,
                                      textInputAction: TextInputAction.done,
                                      keyboardType: TextInputType.visiblePassword,
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
                              child: Center(
                                child: LoadingWidget(
                                  color: Theme.of(context).progressIndicatorTheme.color!,
                                  size: 25,
                                ),
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
