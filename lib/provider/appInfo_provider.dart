/// 全局状态管理
library;

import 'dart:convert' show jsonEncode;

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../constants/api.dart';
import '../utils/index.dart';

class AppInfoProvider with ChangeNotifier {
  NetworkConf conf = NetworkConf();
  AppInfoNetworkStatus connectivity = AppInfoNetworkStatus();
  AppUniLinks uniLinks = AppUniLinks();
  AppRoute appRoute = AppRoute();
}

// 应用网络状态
class AppInfoNetworkStatus with ChangeNotifier {
  final Connectivity _connectivity = Connectivity();

  ConnectivityResult? _connectivityResult;

  bool isInit = false;

  final List _network = [
    ConnectivityResult.wifi,
    ConnectivityResult.ethernet,
    ConnectivityResult.mobile,
    ConnectivityResult.vpn,
    ConnectivityResult.other,
  ];

  final List _bluetooth = [
    ConnectivityResult.bluetooth,
  ];

  Future init(context) async {
    await getConnectivityResult();
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> result) {
      if (result.isEmpty) return;
      _connectivityResult = result.first;
      if (!isNetwork) eventUtil.emit("not-network");
      notifyListeners();
    });
    isInit = true;
    notifyListeners();
    return true;
  }

  ConnectivityResult? get currentAppNetwork => _connectivityResult;

  // 是否有网络
  bool get isNetwork {
    if (_connectivityResult == null) return false;
    return _network.contains(_connectivityResult);
  }

  // 蓝牙
  bool get isBluetooth {
    return _bluetooth.contains(_connectivityResult);
  }

  /// ConnectivityResult.none
  /// 获取连接的网络类型
  Future<ConnectivityResult> getConnectivityResult() async {
    final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
    _connectivityResult = connectivityResult.first;
    if (!isNetwork) eventUtil.emit("not-network");
    notifyListeners();
    return connectivityResult.first;
  }
}

class NetworkConf with ChangeNotifier {
  String? packageName = "netwrok_conf";

  // 从远程服务获取配置
  NetworkConfData data = NetworkConfData(
    confList: ["privilege", "achievements", "gameName", "cheatMethodsGlossary", "cheaterStatus", "action", "recordLink"],
    privilege: {},
    achievements: {},
    gameName: {},
    cheatMethodsGlossary: {},
    cheaterStatus: {},
    action: {},
    recordLink: {},
  );

  /// [Event]
  /// 初始化
  Future init() async {
    for (int index = 0; index < data.confList!.length; index++) {
      await getRemoteConfiguration(data.confList![index]);
    }

    // 更新类
    Config.game = data.gameName!;
    Config.achievements = data.achievements!;
    Config.privilege = data.privilege!;
    Config.cheatMethodsGlossary = data.cheatMethodsGlossary!;
    Config.cheaterStatus = data.cheaterStatus!;
    Config.action = data.action!;
    Config.recordLink = data.recordLink!;

    notifyListeners();
    return Config;
  }

  /// [Response]
  /// 获取远程配置
  Future getRemoteConfiguration(String fileName) async {
    Response result = await Http.fetchJsonPData(
      "config/$fileName.json",
      httpDioValue: "web_site",
    );

    switch (fileName) {
      case "gameName":
        data.gameName = result.data;
        break;
      case "achievements":
        data.achievements = result.data;
        break;
      case "action":
        data.action = result.data;
        break;
      case "cheatMethodsGlossary":
        data.cheatMethodsGlossary = result.data;
        break;
      case "cheaterStatus":
        data.cheaterStatus = result.data;
        break;
      case "privilege":
        data.privilege = result.data;
        break;
      case "recordLink":
        data.recordLink = result.data;
        break;
    }

    return result;
  }
}

// 网络配置
class NetworkConfData {
  List? confList;

  // 身份配置
  Map? privilege;

  // 游戏类型配置
  Map? gameName;

  // 成就配置
  Map? achievements;

  // 作弊行为配置
  Map? cheatMethodsGlossary;

  Map? cheaterStatus;

  // 判决类型配置
  Map? action;

  Map? recordLink;

  NetworkConfData({
    this.confList,
    this.privilege,
    this.achievements,
    this.gameName,
    this.cheatMethodsGlossary,
    this.cheaterStatus,
    this.action,
    this.recordLink,
  });
}

// 应用链接
class AppUniLinks with ChangeNotifier {
  final UrlUtil _urlUtil = UrlUtil();

  final _appLinks = AppLinks();

  BuildContext? appLinksContext;

  Future init(BuildContext context) async {
    appLinksContext = context;
    final uri = await _appLinks.getInitialLink();
    if (uri != null) _onUnlLink(uri);

    _appLinks.uriLinkStream.listen((Uri uri) {
      _onUnlLink(uri);
    });

    return _appLinks;
  }

  /// [Event]
  /// 处理地址
  void _onUnlLink(Uri uri) {
    if (uri.isScheme("bfban") || uri.isScheme("https")) {
      switch (uri.host) {
        case "app":
        case "bfban-app.cabbagelol.net":
        case "bfban.com":
          switch (uri.path.toString()) {
            case "/page":
              _urlUtil.opEnPage(appLinksContext!, "${uri.queryParameters["path"]}");
              break;
            case "/player":
              if (uri.queryParameters["id"] == null) return;
              _urlUtil.opEnPage(appLinksContext!, "/player/personaId/${uri.queryParameters["id"]}");
              break;
            case "/account":
              if (uri.queryParameters["id"] == null) return;
              _urlUtil.opEnPage(appLinksContext!, '/account/${uri.queryParameters["id"]}');
              break;
            case "/report":
              String data = jsonEncode({
                "originName": uri.queryParameters["value"] ?? "",
              });
              _urlUtil.opEnPage(appLinksContext!, '/report/$data');
              break;
            case "/search":
              if (uri.queryParameters["text"] == null) return;
              String data = jsonEncode({
                "text": uri.queryParameters["text"],
                "type": uri.queryParameters["type"],
              });
              _urlUtil.opEnPage(appLinksContext!, '/search/$data');
              break;
          }
          break;
      }
    }
  }
}

// 应用路由
class AppRoute extends ChangeNotifier {
  String? _currentRoute;

  String get currentRoute => _currentRoute!;

  void setCurrentRoute(String route) {
    _currentRoute = route;
    notifyListeners();
  }
}