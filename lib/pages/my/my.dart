/// 我

import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_elui_plugin/elui.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:bfban/constants/api.dart';
import 'package:bfban/router/router.dart';
import 'package:bfban/utils/index.dart';
import 'package:bfban/widgets/index.dart';
import 'package:provider/provider.dart';

import '../../provider/package_provider.dart';
import '../../provider/userinfo_provider.dart';

class UserCenterPage extends StatefulWidget {
  final int num;

  const UserCenterPage({
    Key? key,
    this.num = 0,
  }) : super(key: key);

  get getNum {
    return num;
  }

  @override
  _UserCenterPageState createState() => _UserCenterPageState();
}

class _UserCenterPageState extends State<UserCenterPage> {
  final UrlUtil _urlUtil = UrlUtil();

  /// 本地版本
  Map appInfo = Config.versionApp;

  @override
  void initState() {
    // getMyInfo();
    super.initState();
  }

  /// [Response]
  /// 获取个人信息
  Future<void> getMyInfo() async {
    setState(() {});

    Response result = await Http.request(
      Config.httpHost["user_me"],
      method: Http.GET,
    );

    if (result.data["success"] == 1) {
      setState(() {});
    }

    setState(() {});
  }

  /// [Event]
  /// 前往下载页面
  void _opEnVersionDowUrl() {
    _urlUtil.opEnPage(context, "/my/version");
    // if (versionInfo["is"]) {
    //   _urlUtil.onPeUrl(versionInfo["info"]["src"]);
    //   return;
    // }
  }

  /// [Response]
  /// 注销用户信息
  Future<void> removeUserInfo(token) async {
    Response result = await Http.request(
      Config.httpHost["account_signout"],
      headers: {
        "x-access-token": token,
      },
      method: Http.POST,
    );

    if (result.data["success"] == 1) {
      // 擦除持久数据
      await removeStorage();

      EluiMessageComponent.success(context)(
        child: const Text("\u6ce8\u9500\u6210\u529f"),
      );
    } else {
      EluiMessageComponent.error(context)(
        child: const Text(
            "\u6ce8\u518c\u9519\u8bef\u002c\u8bf7\u8054\u7cfb\u5f00\u53d1\u8005"),
      );
    }
  }

  /// [Event]
  /// 擦除
  Future removeStorage() async {
    List<Future> Futures = [
      Storage().remove("com.bfban.cookie"),
      Storage().remove("com.bfban.token"),
      Storage().remove("com.bfban.login"),
    ];

    await Future.wait(Futures);

    // 清空 用户状态管理机
    ProviderUtil().ofUser(context).clear();

    return true;
  }

  /// [Event]
  /// 打开权限中心
  void _opEnPermanently() async {
    try {
      if (!await openAppSettings()) {
        EluiMessageComponent.error(context)(
            child: const Text("该设备无法打开权限, 请尝试在设置>应用打开"));
      }
    } catch (E) {
      rethrow;
    }
  }

  /// [Event]
  /// 打开登录
  void _opEnLogin() {
    Routes.router!.navigateTo(context, '/login/panel',
        transition: TransitionType.cupertino);
  }

  /// [Event]
  /// 打开主题
  void _opEnTheme() {
    _urlUtil.opEnPage(context, '/my/theme').then((value) {
      // onReadyTheme();
    });
  }

  /// [Event]
  /// 前往空间
  _opEnSpace() {
    Map userdata = ProviderUtil().ofUser(context).userinfo;

    return () {
      _urlUtil.opEnPage(context, "/detail/user/${userdata["userId"]}");
    };
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserInfoProvider>(
      builder: (context, data, child) {
        return ListView(
          children: <Widget>[
            /// 用户信息板块
            !data.isLogin
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Card(
                          child: EluiButtonComponent(
                            type: ButtonType.none,
                            child: Wrap(
                              children: [
                                Text(
                                  "登录",
                                  style: Theme.of(context).textTheme.subtitle1,
                                ),
                              ],
                            ),
                            onTap: () {
                              _opEnLogin();
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 30),
                    child: Card(
                      elevation: 15,
                      borderOnForeground: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: Theme.of(context)
                              .backgroundColor
                              .withOpacity(.09),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: textLoad(
                                          value: data.userinfo["username"],
                                          fontSize: 20,
                                        ),
                                      ),
                                      Text(
                                        "id: ${data.userinfo["userId"]}",
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context)
                                                .textTheme
                                                .subtitle2!
                                                .color),
                                      ),
                                      const Icon(Icons.chevron_right),
                                    ],
                                  ),
                                  onTap: _opEnSpace(),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const <Widget>[
                                        Text(
                                          "0",
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        Text(
                                          "已举报",
                                          style: TextStyle(
                                            fontSize: 12,
                                          ),
                                        )
                                      ],
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      height: 30,
                                      width: 1,
                                      color: Theme.of(context).dividerColor,
                                    ),
                                    GestureDetector(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            ProviderUtil()
                                                .ofMessage(context)
                                                .total
                                                .toString(),
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          const Text(
                                            "消息",
                                            style: TextStyle(
                                              fontSize: 12,
                                            ),
                                          )
                                        ],
                                      ),
                                      onTap: () {
                                        _urlUtil.opEnPage(
                                            context, "/message/list");
                                      },
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      height: 30,
                                      width: 1,
                                      color: Theme.of(context).dividerColor,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Wrap(
                                          children: data.userinfo["privilege"]
                                              .map<Widget>((i) {
                                            return EluiTagComponent(
                                              color: EluiTagType.none,
                                              size: EluiTagSize.no2,
                                              theme: EluiTagTheme(
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .appBarTheme
                                                        .backgroundColor!
                                                        .withOpacity(.2),
                                              ),
                                              value: i.toString(),
                                            );
                                          }).toList(),
                                        ),
                                        const Text(
                                          "身份",
                                          style: TextStyle(
                                            fontSize: 12,
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

            const SizedBox(
              height: 20,
            ),
            EluiCellComponent(
              title: "\u7f51\u7ad9\u5730\u5740",
              label: "\u0042\u0046\u0042\u0041\u004e\u8054\u76df\u7f51\u7ad9",
              theme: EluiCellTheme(
                titleColor: Theme.of(context).textTheme.subtitle1?.color,
                labelColor: Theme.of(context).textTheme.subtitle2?.color,
                linkColor: Theme.of(context).textTheme.subtitle1?.color,
                backgroundColor: Theme.of(context).cardTheme.color,
              ),
              islink: true,
              onTap: () => _urlUtil.onPeUrl("https://bfban.com"),
            ),
            EluiCellComponent(
              title: "\u652f\u63f4",
              label:
                  "\u7a0b\u5e8f\u6570\u636e\u7531\u4e0d\u540c\u670d\u52a1\u5546\u63d0\u4f9b",
              theme: EluiCellTheme(
                titleColor: Theme.of(context).textTheme.subtitle1?.color,
                labelColor: Theme.of(context).textTheme.subtitle2?.color,
                linkColor: Theme.of(context).textTheme.subtitle1?.color,
                backgroundColor: Theme.of(context).cardTheme.color,
              ),
              islink: true,
              onTap: () => _urlUtil.opEnPage(context, '/my/support'),
            ),
            const SizedBox(
              height: 20,
            ),
            EluiCellComponent(
              title: "\u6743\u9650",
              theme: EluiCellTheme(
                titleColor: Theme.of(context).textTheme.subtitle1?.color,
                labelColor: Theme.of(context).textTheme.subtitle2?.color,
                linkColor: Theme.of(context).textTheme.subtitle1?.color,
                backgroundColor: Theme.of(context).cardTheme.color,
              ),
              islink: true,
              onTap: () => _opEnPermanently(),
            ),
            // EluiCellComponent(
            //   title: "主题",
            //   theme: EluiCellTheme(
            //     titleColor: Theme.of(context).textTheme.subtitle1?.color,
            //     labelColor: Theme.of(context).textTheme.subtitle2?.color,
            //     linkColor: Theme.of(context).textTheme.subtitle1?.color,
            //     backgroundColor: Theme.of(context).cardTheme.color,
            //   ),
            //   islink: true,
            //   cont: Container(
            //     height: 20,
            //     width: 20,
            //     decoration: BoxDecoration(
            //       // color: theme["nameColor"],
            //       border: Border.all(
            //         width: 1,
            //         color: Colors.white70,
            //       ),
            //     ),
            //   ),
            //   onTap: () => _opEnTheme(),
            // ),
            EluiCellComponent(
              title: "版本",
              islink: true,
              theme: EluiCellTheme(
                titleColor: Theme.of(context).textTheme.subtitle1?.color,
                labelColor: Theme.of(context).textTheme.subtitle1?.color,
                linkColor: Theme.of(context).textTheme.subtitle1?.color,
                backgroundColor: Theme.of(context).cardTheme.color,
              ),
              cont: Text(ProviderUtil().ofPackage(context).currentVersion.toString()),
              onTap: () => _opEnVersionDowUrl(),
            ),

            Offstage(
              offstage: !data.isLogin,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 30,
                  left: 20,
                  right: 20,
                  bottom: 20,
                ),
                child: EluiButtonComponent(
                  child: const Text(
                    "\u6ce8\u9500",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  radius: true,
                  size: ButtonSize.mini,
                  type: ButtonType.error,
                  onTap: () => removeUserInfo(data.getToken.toString()),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
