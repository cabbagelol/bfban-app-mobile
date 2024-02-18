import 'dart:async';
import 'dart:convert';

import 'package:app_links/app_links.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

import 'package:bfban/utils/index.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

import '../provider/appBuildContent.dart';
import '../provider/package_provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  final UrlUtil _urlUtil = UrlUtil();

  final Storage storage = Storage();

  final _appLinks = AppLinks();

  // 状态机
  ProviderUtil providerUtil = ProviderUtil();

  // 载入提示
  late String? loadTip = "";

  // unlink队列
  late Map unlLink = {
    "list": [],
  };

  late double _size = 1;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _onReady();
    });
    super.initState();
  }

  /// [Event]
  /// 初始页面数据
  void _onReady() async {
    AppStatus.context = context;

    Future.delayed(const Duration(seconds: 1)).then((value) => {
          if (mounted)
            setState(() {
              _size = 1.5;
            })
        });

    Future.wait([
      _onToken(),
      _initLang(),
      _initUserData(),
      _initChat(),
    ]).catchError((onError) => []).whenComplete(() async {
      if (!await _onGuide()) return;

      onMain();
    });
  }

  /// [Event]
  /// 进入主程序
  void onMain() async {
    AppStatus.context = context;

    AppInfoProvider app = providerUtil.ofApp(context);
    await app.uniLinks.init(context);

    // ignore: use_build_context_synchronously
    _urlUtil.opEnPage(
      context,
      "/",
      transition: TransitionType.none,
      clearStack: false,
      rootNavigator: true,
    );
  }

  /// [Event]
  /// 国际化
  Future _initLang() async {
    await providerUtil.ofLang(context).init();
    await providerUtil.ofPublicApiTranslation(context).init();

    return true;
  }

  /// [Event]
  /// 通知初始
  Future _initChat() async {
    await providerUtil.ofChat(context).init();

    return true;
  }

  /// [Event]
  /// 初始与用户相关数据
  Future _initUserData() async {
    StorageData loginData = await storage.get("login");
    dynamic user = loginData.value;

    if (loginData.code == 0) {
      // 数据 更新到状态机内
      setState(() {
        loadTip = "app.splash.account";
      });
      providerUtil.ofUser(context).setData(user);
      // sleep(Duration(seconds: 1));

      // 消息 更新状态机
      setState(() {
        loadTip = "app.splash.message";
      });
      await providerUtil.ofChat(context).onUpDate();
      // sleep(Duration(seconds: 1));
    }

    // 包 更新状态机
    setState(() {
      loadTip = "app.splash.version";
    });
    await providerUtil.ofPackage(context).init();

    // 主题初始
    setState(() {
      loadTip = "app.splash.theme";
    });
    await providerUtil.ofTheme(context).init();

    // 文件
    setState(() {
      loadTip = "app.splash.dir";
    });
    await providerUtil.ofDir(context).init();

    // 配置初始
    setState(() {
      loadTip = "app.splash.appInitial";
    });
    AppInfoProvider app = providerUtil.ofApp(context);
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
    await providerUtil.ofUser(context).init();

    String token = providerUtil.ofUser(context).getToken;

    HttpToken.setToken(token);

    return true;
  }

  /// [Event]
  /// 引导
  Future<bool> _onGuide() async {
    String guideName = "guide";

    setState(() {
      loadTip = "app.splash.guide";
    });

    StorageData guideData = await storage.get(guideName);
    dynamic guide = guideData.value;

    if (guideData.code != 0 && guide == null) {
      await _urlUtil.opEnPage(context, "/guide", transition: TransitionType.fadeIn).then((value) async {
        onMain();
        await storage.set(guideName, value: 1);
      });
      return false;
    }

    return true;
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
                    if (!appInfo.connectivity.isNetwork && appInfo.connectivity.isInit)
                      const Wrap(
                        runAlignment: WrapAlignment.center,
                        children: [
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
                  color: Theme.of(context).colorScheme.primary,
                  backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
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
                                "community products",
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
