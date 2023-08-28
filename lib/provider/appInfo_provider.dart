/// 全局状态管理
import 'dart:convert';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../constants/api.dart';
import '../utils/index.dart';

class AppInfoProvider with ChangeNotifier {
  NetwrokConf conf = NetwrokConf();
  AppInfoNetwrokStatus connectivity = AppInfoNetwrokStatus();
  AppUniLinks uniLinks = AppUniLinks();
}

class AppInfoNetwrokStatus with ChangeNotifier {
  var _connectivity;

  Future init(context) async {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      _connectivity = result;
      notifyListeners();
    });
  }

  get CurrentAppNetwrok => _connectivity;

  /// ConnectivityResult.none
  /// 获取连接的网络类型
  Future<ConnectivityResult> getConnectivity() async {
    notifyListeners();
    return _connectivity;
  }

  /// 是否已连接有效网络
  bool isConnectivity() {
    if (_connectivity == null) return true;
    notifyListeners();
    return !(_connectivity == ConnectivityResult.none);
  }
}

class NetwrokConf with ChangeNotifier {
  String? packageName = "netwrok_conf";

  // 从远程服务获取配置
  NetworkConfData data = NetworkConfData(
    confList: ["privilege", "gameName", "cheatMethodsGlossary", "cheaterStatus", "action", "recordLink"],
    privilege: {},
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
    Response result = await Http.request(
      "config/$fileName.json",
      httpDioValue: "web_site",
      method: Http.GET,
    );

    switch (fileName) {
      case "gameName":
        data.gameName = result.data;
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

  // 作弊行为配置
  Map? cheatMethodsGlossary;

  Map? cheaterStatus;

  // 判决类型配置
  Map? action;

  Map? recordLink;

  NetworkConfData({
    this.confList,
    this.privilege,
    this.gameName,
    this.cheatMethodsGlossary,
    this.cheaterStatus,
    this.action,
    this.recordLink,
  });
}

class AppUniLinks with ChangeNotifier {
  final UrlUtil _urlUtil = UrlUtil();

  final _appLinks = AppLinks();

  static late BuildContext? appLinksContext;

  Future init(BuildContext context) async {
    AppUniLinks.appLinksContext = context;

    final uri = await _appLinks.getInitialAppLink();
    if (uri != null) _onUnlLink(uri);

    _appLinks.allUriLinkStream.listen((Uri uri) {
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
            case "/player":
              _urlUtil.opEnPage(AppUniLinks.appLinksContext!, "/player/personaId/${uri.queryParameters["id"]}");
              break;
            case "/account":
              _urlUtil.opEnPage(AppUniLinks.appLinksContext!, '/account/${uri.queryParameters["id"]}');
              break;
            case "/report":
              String data = jsonEncode({
                "originName": uri.queryParameters["value"] ?? "",
              });
              _urlUtil.opEnPage(AppUniLinks.appLinksContext!, '/report/$data');
              break;
            case "/search":
              String data = jsonEncode({
                "id": uri.queryParameters["id"],
              });
              _urlUtil.opEnPage(AppUniLinks.appLinksContext!, '/search/$data');
              break;
          }
          break;
      }
    }
  }
}
