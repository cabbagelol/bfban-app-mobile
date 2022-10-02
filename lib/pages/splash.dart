import 'dart:async';
import 'dart:convert';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

import 'package:bfban/utils/index.dart';
import 'package:flutter_elui_plugin/_message/index.dart';
import 'package:flutter_elui_plugin/_tag/tag.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:uni_links/uni_links.dart';

import '../provider/package_provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final UrlUtil _urlUtil = UrlUtil();

  // 载入提示
  late String? loadTip = "";

  // unlink队列
  late Map unilink = {
    "list": [],
  };

  @override
  void initState() {
    super.initState();
    _onReady();
  }

  @override
  void activate() {
    super.activate();
  }

  /// [Event]
  /// 初始页面数据
  void _onReady() async {
    Future.wait([
      _initUniLinks(),
      _onToken(),
      _initNotice(),
      _initLang(),
      _initUserData(),
    ]).catchError((onError) {
      print("启动失败");
      print(onError);
    }).whenComplete(() async {
      if (!await _onGuide()) return;

      onMian();
    });
  }

  void onMian() {
    Future.delayed(Duration(seconds: 0)).then((value) {
      _urlUtil.opEnPage(
        context,
        "/",
        transition: TransitionType.none,
        clearStack: true,
        rootNavigator: true,
      );
    });
  }

  /// [Event]
  /// 国际化
  Future _initLang () async {
    await ProviderUtil().ofLang(context).init();

    return true;
  }

  /// [Event]
  /// 通知初始
  Future _initNotice () async {
    await ProviderUtil().ofMessage(context).init();

    return true;
  }

  /// [Event]
  /// 初始用户数据
  Future _initUserData() async {
    dynamic user = await Storage().get("com.bfban.login");

    if (user != null) {
      // 数据 更新到状态机内
      setState(() {
        loadTip = "加载账户信息";
      });
      ProviderUtil().ofUser(context).setData(jsonDecode(user));
      // sleep(Duration(seconds: 1));

      // 消息 更新状态机
      setState(() {
        loadTip = "更新消息";
      });
      await ProviderUtil().ofMessage(context).onUpDate();
      // sleep(Duration(seconds: 1));
    }

    // 包 更新状态机
    setState(() {
      loadTip = "验证版本服务";
    });
    await ProviderUtil().ofPackage(context).init();

    // 主题初始
    setState(() {
      loadTip = "初始化主题";
    });
    await ProviderUtil().ofTheme(context).init();

    // 配置初始
    setState(() {
      loadTip = "初始化程序应用";
    });
    await ProviderUtil().ofApp(context).conf!.init();

    return true;
  }

  /// [Event]
  /// 处理token
  Future _onToken() async {
    setState(() {
      loadTip = "用户身份配置";
    });

    // 初始用户数据
    await ProviderUtil().ofUser(context).init();

    String token = ProviderUtil().ofUser(context).getToken;

    if (token != null) {
      Http.setToken(token);
    }

    return true;
  }

  /// [Event]
  /// 引导
  Future<bool> _onGuide() async {
    Storage storage = Storage();
    String guideName = "com.bfban.guide";

    setState(() {
      loadTip = "初始引导";
    });

    dynamic guide = await storage.get(guideName);

    if (guide == null) {
      _urlUtil.opEnPage(context, "/guide", transition: TransitionType.fadeIn).then((value) async {
        onMian();
        await storage.set(guideName, value: 1);
      });
      return false;
    }

    return true;
  }

  /// [Event]
  /// unlink
  Future _initUniLinks() async {
    StreamSubscription? _sub;

    final initialLink = await getInitialLink();
    if (initialLink != null) {
      _onUnilink(_unilinkQueryParameters(initialLink));
    }

    _sub = linkStream.listen((String? link) {
      _onUnilink(_unilinkQueryParameters(link));
    }, onError: (err) {
      EluiMessageComponent.warning(context)(
        child: Text(err.toString()),
      );
    });

    return _sub;
  }

  /// [Event]
  /// 处理地址
  void _onUnilink(Uri uri) {
    if (!uri.isScheme("bfban") || !uri.isScheme("https")) return;

    switch (uri.host) {
      case "app":
      case "bfban-app.cabbagelol.com":
      case "bfban.cabbagelol.com":
      case "bfban.com":
        switch (uri.queryParameters["open_app_type"]) {
          // 打开玩家详情
          case "player":
            _urlUtil.opEnPage(context, "/detail/player/${uri.queryParameters["id"]}");
            break;
          // 打开用户空间
          case "account":
            _urlUtil.opEnPage(context, '/account/${uri.queryParameters["id"]}');
        }
        break;
    }
  }

  /// [Event]
  /// 分析地址
  Uri _unilinkQueryParameters(String? link) {
    final decoded = Uri.decodeFull(link!).replaceAll('#', '?');
    final Uri uri = Uri.parse(decoded);

    return uri;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/splash/splash_center_logo.png",
                      width: 50,
                      height: 50,
                    ),
                  ],
                ),
              ),
            ),
            Text(
              loadTip.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                // fontSize: FontSize.rem(.8).size,
                color: Theme.of(context).textTheme.subtitle2!.color,
              ),
            ),
            SizedBox(height: 10),
            LinearProgressIndicator(
              minHeight: 1,
              color: Theme.of(context).textTheme.subtitle2!.color,
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 38),
              color: Theme.of(context).backgroundColor,
              child: Center(
                child: Consumer<PackageProvider>(
                  builder: (BuildContext context, data, child) {
                    return Column(
                      children: [
                        Text(data.package!.appName.toString()),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          runAlignment: WrapAlignment.center,
                          children: [
                            Text("@"),
                            Text(data.package!.packageName.toString()),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
