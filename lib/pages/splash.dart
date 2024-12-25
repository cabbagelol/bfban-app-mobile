import 'dart:async';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

import 'package:bfban/utils/index.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import '../provider/appBuildContent.dart';
import '../provider/package_provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  final UrlUtil _urlUtil = UrlUtil();

  final Storage _storage = Storage();

  // 状态机
  final ProviderUtil _providerUtil = ProviderUtil();

  // 载入提示
  late String _loadTip = "";

  late double _animationIconSize = 1;

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

    // Icon 动画
    Future.delayed(const Duration(seconds: 1)).then((value) => {
          if (mounted)
            setState(() {
              _animationIconSize = 1.5;
            })
        });

    Future.wait([
      _onToken(),
      _initLang(),
      _initUserData(),
      _initChat(),
      _initLog(),
      _initLink(),
    ]).catchError((onError) => []).whenComplete(() async {
      if (!await _onGuide()) return;

      onMain();
    });
  }

  /// [Event]
  /// 进入主程序
  void onMain() async {
    AppStatus.context = context;

    _urlUtil.opEnPage(
      context,
      "/",
      transition: TransitionType.none,
      clearStack: false,
      rootNavigator: true,
    );
  }

  /// [Event]
  /// AppUniLink
  Future _initLog() async {
    return await _providerUtil.ofLog(context).init();
  }

  /// [Event]
  /// AppUniLink
  Future _initLink() async {
    AppInfoProvider app = _providerUtil.ofApp(context);
    return await app.uniLinks.init(context);
  }

  /// [Event]
  /// 国际化
  Future _initLang() async {
    return await Future.wait([
      _providerUtil.ofLang(context).init(),
      _providerUtil.ofPublicApiTranslation(context).init(),
    ]);
  }

  /// [Event]
  /// 通知初始
  Future _initChat() async {
    await _providerUtil.ofChat(context).init();

    return true;
  }

  /// [Event]
  /// 初始与用户相关数据
  Future _initUserData() async {
    StorageData loginData = await _storage.get("login");
    dynamic user = loginData.value;

    if (loginData.code == 0) {
      // 数据 更新到状态机内
      setState(() {
        _loadTip = "app.splash.account";
      });
      _providerUtil.ofUser(context).setData(user);

      // 消息 更新状态机
      setState(() {
        _loadTip = "app.splash.message";
      });
      await _providerUtil.ofChat(context).onUpDate();
    }

    // 包 更新状态机
    setState(() {
      _loadTip = "app.splash.version";
    });
    await _providerUtil.ofPackage(context).init();

    // 主题初始
    setState(() {
      _loadTip = "app.splash.theme";
    });
    await _providerUtil.ofTheme(context).init();

    // 文件
    setState(() {
      _loadTip = "app.splash.dir";
    });
    await _providerUtil.ofDir(context).init();

    // 配置初始
    setState(() {
      _loadTip = "app.splash.appInitial";
    });
    AppInfoProvider app = _providerUtil.ofApp(context);
    await Future.wait([
      app.conf.init(),
      app.connectivity.init(context),
    ]);

    return true;
  }

  /// [Event]
  /// 处理token
  Future _onToken() async {
    setState(() {
      _loadTip = "app.splash.token";
    });

    // 初始用户数据
    await _providerUtil.ofUser(context).init();

    HttpToken.setToken(_providerUtil.ofUser(context).getToken);

    return true;
  }

  /// [Event]
  /// 引导
  Future<bool> _onGuide() async {
    String guideName = "guide";

    setState(() {
      _loadTip = "app.splash.guide";
    });

    StorageData guideData = await _storage.get(guideName);
    dynamic guide = guideData.value;

    if (guideData.code != 0 && guide == null) {
      await _urlUtil.opEnPage(context, "/guide", transition: TransitionType.fadeIn).then((value) async {
        onMain();
        await _storage.set(guideName, value: 1);
      });
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Consumer<AppInfoProvider>(
        builder: (BuildContext context, AppInfoProvider appInfo, Widget? child) {
          return Scaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedScale(
                          scale: _animationIconSize,
                          curve: Curves.easeOutBack,
                          duration: const Duration(milliseconds: 300),
                          child: const CircleAvatar(
                            radius: 50,
                            foregroundImage: AssetImage("assets/splash/splash_center_logo.png"),
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
                      FlutterI18n.translate(context, _loadTip.toString()),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.labelLarge!.color,
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
                Container(
                  child: LoadingAnimationWidget.progressiveDots(
                    size: 28,
                    color: Color.lerp(Theme.of(context).colorScheme.primaryContainer, Theme.of(context).colorScheme.primary, .5)!,
                  ),
                ),
                Divider(height: 1),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 38),
                  color: Theme.of(context).bottomAppBarTheme.color,
                  child: Center(
                    child: Consumer<PackageProvider>(
                      builder: (BuildContext context, data, child) {
                        return Column(
                          children: [
                            if (data.info != null)
                              AnimatedOpacity(
                                opacity: data.info!.appName.isEmpty ? 0 : 1,
                                duration: const Duration(milliseconds: 300),
                                child: Text(data.info!.appName.toString()),
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
