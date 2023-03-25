import 'package:bfban/provider/userinfo_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

import '../../utils/provider.dart';
import '../../utils/url.dart';
import '../../widgets/wave_border.dart';

class GuideLoginPage extends StatefulWidget {
  const GuideLoginPage({Key? key}) : super(key: key);

  @override
  _GuideLoginPageState createState() => _GuideLoginPageState();
}

class _GuideLoginPageState extends State<GuideLoginPage> with AutomaticKeepAliveClientMixin {
  final UrlUtil _urlUtil = UrlUtil();

  late String username = "";

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      ProviderUtil().ofUser(context).userinfo["username"];
    });

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
                      FlutterI18n.translate(context, "app.guide.login.label"),
                      style: TextStyle(
                        color: Theme.of(context).textTheme.subtitle2!.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
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
                            Visibility(
                              visible: true,
                              child: Text(
                                !data.isLogin ? FlutterI18n.translate(context, "signin.title") : data.userinfo["username"].toString(),
                                style: const TextStyle(fontSize: 20),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          onTap: () {
            if (data.isLogin) return;

            // 检查登录状态
            _urlUtil.opEnPage(context, '/login/panel');
          },
        );
      },
    );
  }
}
