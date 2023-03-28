import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_elui_plugin/elui.dart';

import 'package:bfban/constants/api.dart';
import 'package:bfban/utils/index.dart';
import 'package:bfban/widgets/index.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../component/_privilegesTag/index.dart';
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

    // 擦除持久数据
    StorageAccount().clearAll(context);

    if (result.data["success"] == 1) {
      EluiMessageComponent.success(context)(
        child: Text(result.data!["message"]),
      );
    } else {
      EluiMessageComponent.error(context)(
        child: Text(result.data!["code"]),
      );
    }
  }

  /// [Event]
  /// 应用设置
  void _opEnSetting() {
    _urlUtil.opEnPage(context, '/profile/setting');
  }

  /// [Event]
  /// 前往消息列表
  void _opEnMessage() {
    // 检查登录状态
    if (!ProviderUtil().ofUser(context).checkLogin()) return;

    _urlUtil.opEnPage(context, "/message/list");
  }

  /// [Event]
  /// 前往空间
  _opEnSpace() {
    return () {
      // 检查登录状态
      if (!ProviderUtil().ofUser(context).checkLogin()) return;

      Map userdata = ProviderUtil().ofUser(context).userinfo;

      _urlUtil.opEnPage(context, "/account/${userdata["userId"]}");
    };
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserInfoProvider>(
      builder: (context, data, child) {
        return ListView(
          children: <Widget>[
            /// 用户信息板块
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Card(
                elevation: 0,
                borderOnForeground: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                  side: BorderSide(
                    color: Theme.of(context).dividerTheme.color!.withOpacity(.1),
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
                            onTap: _opEnSpace(),
                            child: Row(
                              children: [
                                if (data.userinfo["userAvatar"] != null)
                                  EluiImgComponent(
                                    width: 40,
                                    height: 40,
                                    src: data.userinfo["userAvatar"] ?? "",
                                  ),
                                  const SizedBox(width: 10),
                                Expanded(
                                  flex: 1,
                                  child: textLoad(
                                    value: data.userinfo["username"] ?? FlutterI18n.translate(context, "signin.title"),
                                    fontSize: 20,
                                  ),
                                ),
                                Visibility(
                                  visible: data.isLogin,
                                  child: Text(
                                    "id: ${data.userinfo["userId"]}",
                                    style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.subtitle2!.color),
                                  ),
                                ),
                                const Icon(Icons.chevron_right),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),
                          AnimatedOpacity(
                            opacity: data.isLogin ? 1 : .3,
                            duration: const Duration(seconds: 1),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        data.isLogin ? ProviderUtil().ofMessage(context).total.toString() : "-",
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        FlutterI18n.translate(context, "profile.chat.title"),
                                        style: const TextStyle(
                                          fontSize: 12,
                                        ),
                                      )
                                    ],
                                  ),
                                  onTap: () => _opEnMessage(),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 20),
                                  height: 30,
                                  width: 1,
                                  color: Theme.of(context).dividerTheme.color,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      constraints: const BoxConstraints(
                                        maxWidth: 200,
                                      ),
                                      child: Wrap(
                                        spacing: 5,
                                        children: !data.isLogin
                                            ? [
                                                EluiTagComponent(
                                                  color: EluiTagType.none,
                                                  size: EluiTagSize.no2,
                                                  theme: EluiTagTheme(
                                                    backgroundColor: Theme.of(context).appBarTheme.backgroundColor!.withOpacity(.2),
                                                  ),
                                                  value: "-",
                                                )
                                              ]
                                            : [PrivilegesTagWidget(data: data.userinfo["privilege"])],
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      FlutterI18n.translate(context, "account.role"),
                                      style: const TextStyle(
                                        fontSize: 12,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Visibility(
              visible: data.isLogin,
              child: EluiCellComponent(
                title: FlutterI18n.translate(context, "app.setting.cell.account.title"),
                label: FlutterI18n.translate(context, "app.setting.cell.account.describe"),
                theme: EluiCellTheme(
                  titleColor: Theme.of(context).textTheme.subtitle1?.color,
                  labelColor: Theme.of(context).textTheme.subtitle2?.color,
                  linkColor: Theme.of(context).textTheme.subtitle1?.color,
                  backgroundColor: Theme.of(context).cardTheme.color,
                ),
                islink: true,
                onTap: () => _urlUtil.onPeUrl(Config.apiHost["web_site"] + "/profile/account", mode: LaunchMode.externalApplication),
              ),
            ),
            EluiCellComponent(
              title: FlutterI18n.translate(context, "app.setting.cell.website.title"),
              label: FlutterI18n.translate(context, "app.setting.cell.website.describe"),
              theme: EluiCellTheme(
                titleColor: Theme.of(context).textTheme.subtitle1?.color,
                labelColor: Theme.of(context).textTheme.subtitle2?.color,
                linkColor: Theme.of(context).textTheme.subtitle1?.color,
                backgroundColor: Theme.of(context).cardTheme.color,
              ),
              islink: true,
              onTap: () => _urlUtil.onPeUrl(
                Config.apiHost["web_site"],
                mode: LaunchMode.externalApplication,
              ),
            ),
            EluiCellComponent(
              title: FlutterI18n.translate(context, "app.setting.cell.resources.title"),
              label: FlutterI18n.translate(context, "app.setting.cell.resources.describe"),
              theme: EluiCellTheme(
                titleColor: Theme.of(context).textTheme.subtitle1?.color,
                labelColor: Theme.of(context).textTheme.subtitle2?.color,
                linkColor: Theme.of(context).textTheme.subtitle1?.color,
                backgroundColor: Theme.of(context).cardTheme.color,
              ),
              islink: true,
              onTap: () => _urlUtil.opEnPage(context, '/profile/support'),
            ),
            const SizedBox(
              height: 20,
            ),
            EluiCellComponent(
              title: FlutterI18n.translate(context, "app.setting.title"),
              theme: EluiCellTheme(
                titleColor: Theme.of(context).textTheme.subtitle1?.color,
                labelColor: Theme.of(context).textTheme.subtitle2?.color,
                linkColor: Theme.of(context).textTheme.subtitle1?.color,
                backgroundColor: Theme.of(context).cardTheme.color,
              ),
              islink: true,
              onTap: () => _opEnSetting(),
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
                  child: Text(
                    FlutterI18n.translate(context, "header.signout"),
                    style: const TextStyle(
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