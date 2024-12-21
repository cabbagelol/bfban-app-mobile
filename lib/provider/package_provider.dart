/// 包
library;

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../utils/http.dart';
import '../utils/version.dart';

class PackageStatus {
  // 当前版本
  String? currentVersion;

  bool? loadCurrentVersion;

  // 线上新版本
  String? onlineVersion;

  bool? loadOnline;

  // 发现版本列表
  List? versionLists;

  PackageStatus({
    this.currentVersion,
    this.loadCurrentVersion,
    this.onlineVersion,
    this.loadOnline,
    this.versionLists,
  });
}

class PackageProvider with ChangeNotifier {
  BuildContext? context;

  // 包状态
  PackageStatus package = PackageStatus(
    currentVersion: "0.0.0",
    onlineVersion: "0.0.0",
    loadCurrentVersion: false,
    loadOnline: false,
    versionLists: [],
  );

  PackageInfo? info;

  // 版本
  final Version _version = Version();

  /// [Event]
  /// 初始
  Future init() async {
    // info: 由于getOnlinePackage在初始消耗大量时间，修改为Future.any 时代任意完成既可
    await Future.any([getPackage(), getOnlinePackage()]).timeout(Duration(seconds: 4));

    notifyListeners();
    return true;
  }

  /// [Event]
  /// 获取包信息
  Future getPackage() async {
    package.loadCurrentVersion = true;
    notifyListeners();

    info = await PackageInfo.fromPlatform();

    package.currentVersion = info!.version;
    package.loadCurrentVersion = false;
    notifyListeners();

    return info;
  }

  /// [Event]
  /// 获取线上版本
  Future getOnlinePackage() async {
    Response result;
    try {
      package.loadOnline = true;
      notifyListeners();

      result = await Http.fetchJsonPData(
        "config/version.json",
        httpDioValue: "app_web_site",
      );

      if (result.data.toString().length >= 0) {
        package.versionLists = result.data["list"];
        package.onlineVersion = package.versionLists!.first["version"];
      }

      package.loadOnline = false;
      notifyListeners();

      return result;
    } catch (e) {
      package.versionLists = [];
    }
  }

  /// 检查是否空，如果空者触发更新
  String isNull(value) => value; // value.isEmpty ? init() : value;

  /// 获取所有版本
  List get list => package.versionLists!;

  /// 当前版本
  String get currentVersion => isNull(package.currentVersion!);

  bool get loadCurrent => package.loadCurrentVersion!;

  /// 线上版本
  String get onlineVersion => isNull(package.onlineVersion!);

  bool get loadOnline => package.loadOnline!;

  /// 是否超发版本
  bool get isSuperHairVersion {
    return list.where((i) => i["version"] == currentVersion).toList().isEmpty;
  }

  /// 是否最新版本
  bool get isNewVersion => _version.compareVersions(currentVersion, package.onlineVersion!);
}
