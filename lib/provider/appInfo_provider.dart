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
    try {
      final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
      _connectivityResult = connectivityResult.isNotEmpty ? connectivityResult.first : ConnectivityResult.none;
    } catch (_) {
      _connectivityResult = ConnectivityResult.none;
    }
    if (!isNetwork) eventUtil.emit("not-network");
    notifyListeners();
    return _connectivityResult!;
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

  /**
   * 初始化配置，并发获取远程配置并设置超时保护
   */
  Future init() async {
    try {
      final List confList = data.confList ?? [];
      await Future.wait(
        confList.map((fileName) => getRemoteConfiguration(fileName.toString())),
      ).timeout(const Duration(seconds: 4));
    } catch (_) {
      // 网络超时或失败时保持默认配置
    }

    // 更新类，带安全兜底，防止远程配置失败时出现 null unwrap 崩溃
    Config.game = (data.gameName != null && data.gameName!["child"] is List && (data.gameName!["child"] as List).isNotEmpty)
        ? data.gameName!
        : {
            "defaultIndex": 0,
            "default": "bf1",
            "child": [
              {"value": "bf1", "full_name": "bf1"},
              {"value": "bfv", "full_name": "bfv"},
              {"value": "bf6", "full_name": "bf2042"},
            ]
          };
    Config.achievements = (data.achievements != null && data.achievements!["child"] != null) ? data.achievements! : {"child": []};
    Config.privilege = data.privilege ?? {};
    Config.cheatMethodsGlossary = (data.cheatMethodsGlossary != null && data.cheatMethodsGlossary!["child"] != null) ? data.cheatMethodsGlossary! : {"child": []};
    Config.cheaterStatus = data.cheaterStatus ?? {};
    Config.action = (data.action != null && data.action!["child"] != null) ? data.action! : {"child": []};
    Config.recordLink = data.recordLink ?? {};

    notifyListeners();
    return Config;
  }

  /**
   * 获取单项远程配置
   */
  Future getRemoteConfiguration(String fileName) async {
    try {
      Response result = await Http.fetchJsonPData(
        "config/$fileName.json",
        httpDioValue: "web_site",
      );

      if (result.statusCode == 200 && result.data != null && result.data is Map) {
        final Map mapData = result.data as Map;
        switch (fileName) {
          case "gameName":
            data.gameName = mapData;
            break;
          case "achievements":
            data.achievements = mapData;
            break;
          case "action":
            data.action = mapData;
            break;
          case "cheatMethodsGlossary":
            data.cheatMethodsGlossary = mapData;
            break;
          case "cheaterStatus":
            data.cheaterStatus = mapData;
            break;
          case "privilege":
            data.privilege = mapData;
            break;
          case "recordLink":
            data.recordLink = mapData;
            break;
        }
      }

      return result;
    } catch (_) {
      return null;
    }
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
            case "/space":
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