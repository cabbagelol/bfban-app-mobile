/// 全局状态管理

import 'dart:convert';

import 'package:flutter/material.dart';

import '../constants/api.dart';
import '../utils/http.dart';

class AppInfoProvider with ChangeNotifier {
  NetwrokConf? conf = NetwrokConf();
}

class NetwrokConf {
  // 从远程服务获取配置
  NetworkConfData data = NetworkConfData(
    confList: ["privilege", "gameName", "cheatMethodsGlossary", "action"],
    privilege: {},
    gameName: {},
    cheatMethodsGlossary: {},
    action: {},
  );

  /// [Event]
  /// 初始化
  init() async {
    List<Future> reqlist = [];

    for (var i = 0; i < data.confList!.length; i++) {
      reqlist.add(getConf(data.confList![i]));
    }

    await Future.any(reqlist);
    return true;
  }

  /// [Response]
  /// 请求获取
  getConf(String fileName) async {
    Response result = await Http.request(
      Config.apiHost["web_site"] + "/conf/$fileName.json",
      typeUrl: "web_site",
      method: Http.GET,
    );

    switch (fileName) {
      case "gameName":
        data.gameName = jsonDecode(result.data);
        break;
      case "action":
        data.action = jsonDecode(result.data);
        break;
      case "cheatMethodsGlossary":
        data.cheatMethodsGlossary = jsonDecode(result.data);
        break;
      case "privilege":
        data.privilege = jsonDecode(result.data);
        break;
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

  // 作弊行为配置
  Map? cheatMethodsGlossary;

  // 判决类型配置
  Map? action;

  NetworkConfData({
    this.confList,
    this.privilege,
    this.gameName,
    this.cheatMethodsGlossary,
    this.action,
  });
}
