import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_elui_plugin/elui.dart';

import 'package:bfban/constants/api.dart';
import 'package:bfban/utils/index.dart';
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

  bool accountLoading = false;

  /// [Response]
  /// 注销用户信息
  Future<void> removeUserInfo(UserInfoProvider userProvider) async {
    if (accountLoading) return;

    setState(() => accountLoading = true);
    await userProvider.accountQuit(context);
    setState(() => accountLoading = false);
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

    _urlUtil.opEnPage(context, "/chat/list");
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
      builder: (context, UserInfoProvider data, child) {
        return ListView(
          children: <Widget>[
            /// 用户信息板块
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Card(
                borderOnForeground: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                  side: BorderSide(
                    color: Theme.of(context).dividerTheme.color!,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: GestureDetector(
                        onTap: _opEnSpace(),
                        child: Row(
                          children: [
                            if (data.userinfo["userAvatar"] != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(60),
                                child: EluiImgComponent(
                                  width: 60,
                                  height: 60,
                                  src: data.userinfo["userAvatar"] ?? "",
                                ),
                              ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 1,
                              child: Wrap(
                                spacing: 5,
                                runSpacing: 5,
                                children: [
                                  Text(
                                    data.userinfo["username"] ?? FlutterI18n.translate(context, "signin.title"),
                                    style: TextStyle(
                                      fontSize: FontSize.xLarge.value,
                                    ),
                                  ),
                                  if (data.userinfo["userAvatar"] != null)
                                    const Card(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                                        child: Wrap(
                                          spacing: 5,
                                          children: [Icon(Icons.ads_click, size: 15), Text("Mobile device client")],
                                        ),
                                      ),
                                    ),
                                  if (data.userinfo["userAvatar"] != null) PrivilegesTagWidget(data: data.userinfo["privilege"]),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Visibility(
              visible: data.isLogin,
              child: EluiCellComponent(
                title: FlutterI18n.translate(context, "app.setting.cell.media.title"),
                label: FlutterI18n.translate(context, "app.setting.cell.media.describe"),
                theme: EluiCellTheme(
                  titleColor: Theme.of(context).textTheme.titleMedium?.color,
                  labelColor: Theme.of(context).textTheme.displayMedium?.color,
                  linkColor: Theme.of(context).textTheme.titleMedium?.color,
                  backgroundColor: Theme.of(context).cardTheme.color,
                ),
                islink: true,
                onTap: () => _urlUtil.opEnPage(context, "/account/media/"),
              ),
            ),
            Visibility(
              visible: data.isLogin,
              child: EluiCellComponent(
                title: FlutterI18n.translate(context, "app.setting.cell.customReply.title"),
                label: FlutterI18n.translate(context, "app.setting.cell.customReply.describe"),
                theme: EluiCellTheme(
                  titleColor: Theme.of(context).textTheme.titleMedium?.color,
                  labelColor: Theme.of(context).textTheme.displayMedium?.color,
                  linkColor: Theme.of(context).textTheme.titleMedium?.color,
                  backgroundColor: Theme.of(context).cardTheme.color,
                ),
                islink: true,
                onTap: () => _urlUtil.opEnPage(context, "/report/customReply/page"),
              ),
            ),
            EluiCellComponent(
              title: FlutterI18n.translate(context, "app.setting.cell.website.title"),
              label: FlutterI18n.translate(context, "app.setting.cell.website.describe"),
              theme: EluiCellTheme(
                titleColor: Theme.of(context).textTheme.titleMedium?.color,
                labelColor: Theme.of(context).textTheme.displayMedium?.color,
                linkColor: Theme.of(context).textTheme.titleMedium?.color,
                backgroundColor: Theme.of(context).cardTheme.color,
              ),
              islink: true,
              onTap: () => _urlUtil.onPeUrl(
                Config.apiHost["web_site"]!.url,
                mode: LaunchMode.externalApplication,
              ),
            ),
            EluiCellComponent(
              title: FlutterI18n.translate(context, "app.setting.cell.resources.title"),
              label: FlutterI18n.translate(context, "app.setting.cell.resources.describe"),
              theme: EluiCellTheme(
                titleColor: Theme.of(context).textTheme.titleMedium?.color,
                labelColor: Theme.of(context).textTheme.displayMedium?.color,
                linkColor: Theme.of(context).textTheme.titleMedium?.color,
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
                titleColor: Theme.of(context).textTheme.titleMedium?.color,
                labelColor: Theme.of(context).textTheme.displayMedium?.color,
                linkColor: Theme.of(context).textTheme.titleMedium?.color,
                backgroundColor: Theme.of(context).cardTheme.color,
              ),
              islink: true,
              onTap: () => _opEnSetting(),
            ),

            Offstage(
              offstage: !data.isLogin,
              child: Container(
                height: 90,
                padding: const EdgeInsets.only(
                  top: 20,
                  left: 20,
                  right: 20,
                  bottom: 30,
                ),
                child: ElevatedButton(
                  style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                        padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 10, horizontal: 20)),
                        backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.error),
                      ),
                  onPressed: () => removeUserInfo(data),
                  child: accountLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Wrap(
                          spacing: 5,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Icon(Icons.output),
                            Text(
                              FlutterI18n.translate(context, "header.signout"),
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),

            const SizedBox(height: 80),
          ],
        );
      },
    );
  }
}
