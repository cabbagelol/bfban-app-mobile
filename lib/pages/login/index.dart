import 'package:bfban/pages/login/signin.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bfban/utils/index.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../../provider/userinfo_provider.dart';
import '../../widgets/wave_border.dart';

class LoginPanelPage extends StatefulWidget {
  const LoginPanelPage({super.key});

  @override
  LoginPanelState createState() => LoginPanelState();
}

class LoginPanelState extends State<LoginPanelPage> {
  final UrlUtil _urlUtil = UrlUtil();

  final ProviderUtil _providerUtil = ProviderUtil();

  bool isShowWaveBorder = true;

  /// [Event]
  /// 取消
  _pop() {
    _urlUtil.popPage(context);
  }

  /// [Event]
  /// 登录
  dynamic _openSignin() {
    setState(() {
      isShowWaveBorder = true;
    });

    var filterModal = showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      showDragHandle: true,
      scrollControlDisabledMaxHeightRatio: .8,
      builder: (context) {
        return SigninPage();
      },
    );

    filterModal.then((fileName) {
      if (_providerUtil.ofUser(context).isLogin) {
        setState(() {
          _urlUtil.popPage(context);
          isShowWaveBorder = true;
        });
      }
      return fileName;
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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              padding: const EdgeInsets.all(16),
              onPressed: () {
                _urlUtil.opEnPage(context, "/network");
              },
              icon: const Icon(Icons.electrical_services),
            ),
          ],
        ),
        body: ClipPath(
          child: Consumer<UserInfoProvider>(
            builder: (BuildContext context, data, Widget? child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isShowWaveBorder)
                    WaveBorderWidget(
                      width: 80,
                      maxWidth: MediaQuery.of(context).size.width,
                      count: 5,
                      borderColor: Theme.of(context).appBarTheme.backgroundColor!.withOpacity(.2),
                      borderWidth: 5,
                      duration: const Duration(seconds: 10),
                      child: CircleAvatar(
                        radius: 39,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.asset(
                            "assets/splash/splash_center_logo.png",
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.high,
                          ),
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
                        FilledButton(
                          style: ButtonStyle(
                            padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 15)),
                          ),
                          onPressed: () => _openSignin(),
                          child: Text(FlutterI18n.translate(context, "app.signin.panel.BfbanAccountButton")),
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          style: ButtonStyle(padding: WidgetStatePropertyAll(const EdgeInsets.symmetric(vertical: 15)), backgroundColor: WidgetStatePropertyAll(Color.lerp(Theme.of(context).colorScheme.secondary, Theme.of(context).colorScheme.primaryContainer, .8)), foregroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.primary)),
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
        ),
        bottomNavigationBar: Container(
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
