import 'package:flutter/cupertino.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../constants/api.dart';
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

  dynamic buildSignature;
  dynamic buildNumber;

  PackageStatus({
    this.currentVersion,
    this.loadCurrent,
    this.onlineVersion,
    this.loadOnline,
    this.list,
    this.buildNumber,
    this.buildSignature,
  });
}

class PackageProvider with ChangeNotifier {
  // 包状态
  PackageStatus? package = PackageStatus(
    currentVersion: "0.0.0",
    loadCurrent: false,
    onlineVersion: "",
    loadOnline: false,
    list: [],
  );

  // 版本
  Version _version = Version();

  /// [Event]
  /// 初始
  init () async {
    await getPackage();
    await getOnlinePackage();
    notifyListeners();
  }

  /// [Event]
  /// 获取包信息
  getPackage() async {
    package!.loadCurrent = true;
    notifyListeners();

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

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
      "json/version.json",
      typeUrl: "web_site",
      method: Http.GET,
    );

    if (result.data.toString().length >= 0) {
      package!.list = result.data["list"];
      package!.onlineVersion = setIssue(package!.list![0]["version"], package!.list![0]["stage"]);
    }
    package!.loadOnline = false;
    notifyListeners();

    return result;
  }

  /// [Event]
  /// 装载发行号
  String setIssue (String version, issue) {
    return "${version}-${issue}";
  }

  /// 检查是否空，如果空者触发更新
  String isNull (value) => value; // value.isEmpty ? init() : value;

  /// 获取所有版本
  List get list => package!.list!;

  /// 当前版本
  String get currentVersion => isNull(package!.currentVersion!);
  bool get loadCurrent => package!.loadCurrent!;

  /// 线上版本
  String get onlineVersion => isNull(package!.onlineVersion!);
  bool get loadOnline => package!.loadOnline!;

  /// 是否最新版本
  bool get isNewVersion =>
      _version.getContrast(package!.currentVersion!, package!.onlineVersion!);
}
