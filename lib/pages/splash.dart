import 'dart:async';
import 'dart:convert';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

import 'package:bfban/utils/index.dart';
import 'package:flutter_elui_plugin/_message/index.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';
import 'package:uni_links/uni_links.dart';

import '../provider/package_provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  final UrlUtil _urlUtil = UrlUtil();

  // 载入提示
  late String? loadTip = "";

  // unlink队列
  late Map unlLink = {
    "list": [],
  };

  late double _size = 1;

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
    Future.delayed(const Duration(seconds: 1)).then((value) => {
          setState(() {
            _size = 1.5;
          })
        });

    Future.wait([
      _initUniLinks(),
      _onToken(),
      _initNotice(),
      _initLang(),
      _initUserData(),
    ]).catchError((onError) {}).whenComplete(() async {
      if (!await _onGuide()) return;

      onMain();
    });
  }

  void onMain() {
    Future.delayed(const Duration(seconds: 0)).then((value) {
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
  Future _initLang() async {
    await ProviderUtil().ofLang(context).init();

    return true;
  }

  /// [Event]
  /// 通知初始
  Future _initNotice() async {
    await ProviderUtil().ofMessage(context).init();

    return true;
  }

  /// [Event]
  /// 初始用户数据
  Future _initUserData() async {
    dynamic user = await Storage().get("login");

    if (user != null) {
      // 数据 更新到状态机内
      setState(() {
        loadTip = "app.splash.account";
      });
      ProviderUtil().ofUser(context).setData(jsonDecode(user));
      // sleep(Duration(seconds: 1));

      // 消息 更新状态机
      setState(() {
        loadTip = "app.splash.message";
      });
      await ProviderUtil().ofMessage(context).onUpDate();
      // sleep(Duration(seconds: 1));
    }

    // 包 更新状态机
    setState(() {
      loadTip = "app.splash.version";
    });
    await ProviderUtil().ofPackage(context).init();

    // 主题初始
    setState(() {
      loadTip = "app.splash.theme";
    });
    await ProviderUtil().ofTheme(context).init();

    // 配置初始
    setState(() {
      loadTip = "app.splash.appInitial";
    });
    AppInfoProvider app = ProviderUtil().ofApp(context);
    await app.conf.init();
    await app.connectivity.init(context);
    return true;
  }

  /// [Event]
  /// 处理token
  Future _onToken() async {
    setState(() {
      loadTip = "app.splash.token";
    });

    // 初始用户数据
    await ProviderUtil().ofUser(context).init();

    String token = ProviderUtil().ofUser(context).getToken;

    Http.setToken(token);

    return true;
  }

  /// [Event]
  /// 引导
  Future<bool> _onGuide() async {
    Storage storage = Storage();
    String guideName = "guide";

    setState(() {
      loadTip = "app.splash.guide";
    });

    dynamic guide = await storage.get(guideName);

    if (guide == null) {
      _urlUtil.opEnPage(context, "/guide", transition: TransitionType.fadeIn).then((value) async {
        onMain();
        await storage.set(guideName, value: 1);
      });
      return false;
    }

    return true;
  }

  /// [Event]
  /// unlink
  Future _initUniLinks() async {
    StreamSubscription? sub;

    final initialLink = await getInitialLink();
    if (initialLink != null) {
      _onUnlLink(_unlLinkQueryParameters(initialLink));
    }

    sub = linkStream.listen((String? link) {
      _onUnlLink(_unlLinkQueryParameters(link));
    }, onError: (err) {
      EluiMessageComponent.warning(context)(
        child: Text(err.toString()),
      );
    });

    return sub;
  }

  /// [Event]
  /// 处理地址
  void _onUnlLink(Uri uri) {
    if (!uri.isScheme("bfban") || !uri.isScheme("https")) return;

    switch (uri.host) {
      case "app":
      case "bfban.gametools.network":
      case "bfban.cabbagelol.net":
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
  Uri _unlLinkQueryParameters(String? link) {
    final decoded = Uri.decodeFull(link!).replaceAll('#', '?');
    final Uri uri = Uri.parse(decoded);

    return uri;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Consumer<AppInfoProvider>(
        builder: (BuildContext context, AppInfoProvider appInfo, Widget? child) {
          return Scaffold(
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
                        AnimatedScale(
                          scale: _size,
                          curve: Curves.easeOutBack,
                          duration: const Duration(milliseconds: 300),
                          child: const CircleAvatar(
                            radius: 30,
                            backgroundImage: AssetImage("assets/splash/splash_center_logo.png"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    Text(
                      FlutterI18n.translate(context, loadTip.toString()),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.subtitle2!.color,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    if (!appInfo.connectivity.isConnectivity())
                      Wrap(
                        runAlignment: WrapAlignment.center,
                        children: const [
                          SizedBox(width: 10),
                          Icon(Icons.error, size: 18),
                          Icon(Icons.network_locked, size: 18),
                        ],
                      )
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  minHeight: 1,
                  color: Theme.of(context).primaryColorDark,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 38),
                  color: Theme.of(context).bottomAppBarTheme.color,
                  child: Center(
                    child: Consumer<PackageProvider>(
                      builder: (BuildContext context, data, child) {
                        return Column(
                          children: [
                            AnimatedOpacity(
                              opacity: data.package!.appName!.toString().isEmpty ? 0 : 1,
                              duration: const Duration(milliseconds: 300),
                              child: Text(data.package!.appName.toString()),
                            ),
                            const Opacity(
                              opacity: .6,
                              child: Text(
                                "Unofficial, community products",
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
