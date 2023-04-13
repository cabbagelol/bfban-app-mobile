import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bfban/utils/index.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../../provider/userinfo_provider.dart';

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
    _urlUtil.opEnPage(context, '/signin', transition: TransitionType.inFromBottom).then((value) {
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
    return SafeArea(
      top: false,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: () {
                _urlUtil.opEnPage(context, "/network");
              },
              icon: const Icon(Icons.electrical_services),
            ),
          ],
        ),
        body: Consumer<UserInfoProvider>(
          builder: (BuildContext context, data, Widget? child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 39,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.asset(
                      "assets/splash/splash_center_logo_.png",
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        FlutterI18n.translate(context, "app.signin.panel.title"),
                        style: const TextStyle(fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        FlutterI18n.translate(context, "app.signin.panel.label"),
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium!.color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 50),
                      MaterialButton(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        color: Theme.of(context).colorScheme.primary,
                        elevation: 2,
                        onPressed: () => _openSignin(),
                        child: Text(FlutterI18n.translate(context, "app.signin.panel.BfbanAccountButton")),
                      ),
                      const SizedBox(height: 20),
                      MaterialButton(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        color: Theme.of(context).colorScheme.secondary.withOpacity(.8),
                        elevation: 0,
                        onPressed: () => _pop(),
                        child: Text(FlutterI18n.translate(context, "app.signin.panel.cancelButton")),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        bottomSheet: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: GestureDetector(
            child: Opacity(
              opacity: .8,
              child: Wrap(
                spacing: 5,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    FlutterI18n.translate(context, "app.signin.panel.signupButton"),
                  ),
                  const Icon(
                    Icons.open_in_new,
                    size: 18,
                  ),
                ],
              ),
            ),
            onTap: () => _urlUtil.onPeUrl("https://bfban.com/#/signup"),
          ),
        ),
      ),
    );
  }
}
