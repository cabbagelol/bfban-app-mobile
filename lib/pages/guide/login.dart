import 'package:bfban/provider/userinfo_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

import '../../utils/url.dart';
import '../../widgets/wave_border.dart';

class GuideLoginPage extends StatefulWidget {
  const GuideLoginPage({super.key});

  @override
  GuideLoginPageState createState() => GuideLoginPageState();
}

class GuideLoginPageState extends State<GuideLoginPage> {
  final UrlUtil _urlUtil = UrlUtil();

  late String username = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserInfoProvider>(
      builder: (BuildContext context, data, Widget? child) {
        return GestureDetector(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              WaveBorder(
                width: 200,
                maxWidth: 600,
                count: 6,
                borderColor: Theme.of(context).appBarTheme.backgroundColor!.withOpacity(.4),
                borderWidth: 2,
                duration: const Duration(seconds: 5),
                child: Column(
                  children: [
                    Text(
                      FlutterI18n.translate(context, "app.guide.login.title"),
                      style: const TextStyle(fontSize: 30),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      FlutterI18n.translate(context, "app.guide.login.${data.isLogin ? 'welcomeBack' : 'label'}"),
                      style: TextStyle(
                        color: Theme.of(context).textTheme.labelLarge!.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Card(
                color: Theme.of(context).cardTheme.color!.withOpacity(.9),
                margin: const EdgeInsets.symmetric(horizontal: 30),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        child: Text(
                          data.isLogin ? data.userinfo["username"][0].toString() : FlutterI18n.translate(context, "signin.title")[0],
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: Text(
                          !data.isLogin ? FlutterI18n.translate(context, "signin.title") : data.userinfo["username"].toString(),
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      if (data.isLogin)
                        TextButton(
                          onPressed: () => data.accountQuit(context),
                          child: Text(FlutterI18n.translate(context, "header.signout")),
                        )
                    ],
                  ),
                ),
              ),
            ],
          ),
          onTap: () {
            if (data.isLogin) return;

            // 检查登录状态
            _urlUtil.opEnPage(context, '/login/panel').then((value) {
              // update state
              setState(() {});
            });
          },
        );
      },
    );
  }
}
