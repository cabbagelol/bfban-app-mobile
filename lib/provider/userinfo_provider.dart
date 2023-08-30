
import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/elui.dart';

import '../constants/api.dart';
import '../utils/index.dart';

class UserInfoProvider with ChangeNotifier {
  final UrlUtil _urlUtil = UrlUtil();

  final StorageAccount _storageAccount = StorageAccount();

  final Storage _storage = Storage();

  String packageName = "login";

  BuildContext? context;

  /// 用户数据
  Map _userdata = {
    "userinfo": {},
    "token": "",
  };

  // 是否已登录
  bool get isLogin {
    return userinfo.isNotEmpty && getToken.isNotEmpty;
  }

  // 是否管理员
  bool get isAdmin {
    return isLogin && userinfo["privilege"].any((i) => ["admin", "super"].contains(i));
  }

  // 获取用户信息
  Map get userinfo {
    return _userdata["userinfo"] ?? {};
  }

  // 获取token
  String get getToken {
    return _userdata["token"] ?? "";
  }

  /// [Event]
  /// 初始
  Future init() async {
    StorageData loginData = await _storage.get(packageName);
    dynamic userinfo = loginData.value;

    if (userinfo != null) {
      _userdata = userinfo;
    }

    return _userdata;
  }

  /// [Event]
  /// 检查登录状态，否则调起登录
  bool checkLogin() {
    if (!isLogin) _urlUtil.opEnPage(context!, "login/panel");

    return isLogin;
  }

  /// [Event]
  /// 设置用户数据
  void setData(Map? value) {
    _userdata = value!;
    notifyListeners();
  }

  /// [Response]
  /// 账户信息
  Future<Response> getUserInfo() async {
    Response result = await Http.request(
      Config.httpHost["user_me"],
      method: Http.GET,
    );

    return result;
  }

  /// [Response]
  /// 账户注销
  Future accountQuit(BuildContext context) async {
    Response result = await Http.request(
      Config.httpHost["account_signout"],
      headers: {
        "x-access-token": Http.TOKEN,
      },
      method: Http.POST,
    );

    _storageAccount.clearAll(context); // 擦除持久数据账户相关key
    clear(); // 擦除状态机的账户信息

    notifyListeners();

    if (result.data["success"] == 1) {
      EluiMessageComponent.success(context)(
        child: Text(result.data!["message"]),
      );
      return result;
    }

    EluiMessageComponent.error(context)(
      child: Text(result.data!["code"]),
    );

    return result;
  }

  /// [Event]
  /// 擦除
  void clear() {
    _userdata.clear();
    notifyListeners();
  }
}
