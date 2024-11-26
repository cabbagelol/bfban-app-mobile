/// 包

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../utils/http.dart';
import '../utils/version.dart';

class PackageStatus {
  // 当前版本
  String? currentVersion;

  bool? loadCurrent;

  // 线上新版本
  String? onlineVersion;

  bool? loadOnline;

  List? list;

  String? appName;
  String? packageName;

  dynamic buildSignature;
  dynamic buildNumber;

  PackageStatus({
    this.currentVersion,
    this.loadCurrent,
    this.onlineVersion,
    this.loadOnline,
    this.list,
    this.appName,
    this.packageName,
    this.buildNumber,
    this.buildSignature,
  });
}

class PackageProvider with ChangeNotifier {
  BuildContext? context;

  // 包状态
  PackageStatus? package = PackageStatus(
    appName: "",
    packageName: "",
    currentVersion: "0.0.0-beta",
    loadCurrent: false,
    onlineVersion: "",
    loadOnline: false,
    list: [],
  );

  // 版本
  final Version _version = Version();

  /// [Event]
  /// 初始
  Future init() async {
    // info: 由于getOnlinePackage在初始消耗大量时间，修改为Future.any 时代任意完成既可
    await Future.any([getPackage(), getOnlinePackage()]);

    notifyListeners();
    return true;
  }

  /// [Event]
  /// 获取包信息
  Future getPackage() async {
    package!.loadCurrent = true;
    notifyListeners();

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    package!.appName = packageInfo.appName;
    package!.packageName = packageInfo.packageName;
    package!.buildNumber = packageInfo.buildNumber;
    package!.currentVersion = packageInfo.version.toString();
    package!.loadCurrent = false;
    notifyListeners();

    return packageInfo.version.toString();
  }

  /// [Event]
  /// 获取线上版本
  Future getOnlinePackage() async {
    package!.loadOnline = true;
    notifyListeners();
    Response result = await Http.request(
      "config/version.json",
      httpDioValue: "app_web_site",
      method: Http.GET,
    );

    if (result.data.toString().length >= 0) {
      package!.list = result.data["list"];
      package!.onlineVersion = package!.list![0]["version"];
    }
    package!.loadOnline = false;
    notifyListeners();

    return result;
  }

  /// 检查是否空，如果空者触发更新
  String isNull(value) => value; // value.isEmpty ? init() : value;

  /// 获取所有版本
  List get list => package!.list!;

  /// 当前版本
  String get currentVersion => isNull(package!.currentVersion!);

  String get buildNumber => package!.buildNumber;

  bool get loadCurrent => package!.loadCurrent!;

  /// 线上版本
  String get onlineVersion => isNull(package!.onlineVersion!);

  bool get loadOnline => package!.loadOnline!;

  /// 是否最新版本
  bool get isNewVersion => _version.compareVersions(currentVersion, package!.onlineVersion!);
}
