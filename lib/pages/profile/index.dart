import 'package:bfban/component/_userAvatar/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_elui_plugin/elui.dart';

import 'package:bfban/utils/index.dart';
import 'package:provider/provider.dart';

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
  /// 前往空间
  _opEnSpace() {
    return () {
      // 检查登录状态
      if (!ProviderUtil().ofUser(context).checkLogin()) return;

      Map userdata = ProviderUtil().ofUser(context).userinfo;

      _urlUtil.opEnPage(context, "/account/${userdata["userId"]}");
    };
  }

  /// [Event]
  /// 刷新
  Future _onRefresh(UserInfoProvider userProvider) async {
    userProvider.checkLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserInfoProvider>(
      builder: (context, UserInfoProvider data, child) {
        return RefreshIndicator(
          displacement: 120,
          edgeOffset: MediaQuery.of(context).viewInsets.top,
          onRefresh: () => _onRefresh(data),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipPath(
                clipBehavior: Clip.hardEdge,
                child: InkWell(
                  onTap: _opEnSpace(),
                  child: Container(
                    color: Theme.of(context).appBarTheme.backgroundColor!.withOpacity(.4),
                    child: Stack(
                      children: [

                        /// 用户信息板块
                        Container(
                          margin: EdgeInsets.only(
                            top: MediaQuery.of(context).viewInsets.top + 120,
                            left: 15,
                            right: 15,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardTheme.color,
                              boxShadow: [
                                BoxShadow(
                                  blurStyle: BlurStyle.solid,
                                  spreadRadius: 0,
                                  blurRadius: 20,
                                  color: Theme.of(context).shadowColor.withOpacity(.1),
                                ),
                              ],
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(9),
                                topRight: Radius.circular(9),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Wrap(
                                    spacing: 5,
                                    runSpacing: 5,
                                    children: [
                                      if (data.userinfo["username"] != null)
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              data.userinfo["username"],
                                              style: TextStyle(
                                                fontSize: FontSize.xLarge.value,
                                              ),
                                            ),
                                            Text(
                                              FlutterI18n.translate(context, "profile.meet", translationParams: {"name": data.userinfo["username"]}),
                                              style: TextStyle(fontSize: FontSize.small.value, color: Theme.of(context).textTheme.displayMedium?.color),
                                            )
                                          ],
                                        )
                                      else
                                        Text(
                                          FlutterI18n.translate(context, "signin.title"),
                                          style: TextStyle(
                                            fontSize: FontSize.xLarge.value,
                                          ),
                                        ),
                                      if (data.userinfo["userAvatar"] != null) PrivilegesTagWidget(data: data.userinfo["privilege"]),
                                    ],
                                  ),
                                ),
                                if (data.userinfo["userAvatar"] != null)
                                  UserAvatar(
                                    src: data.userinfo["userAvatar"],
                                    size: 60,
                                  ),
                                const SizedBox(width: 10),
                                const Icon(Icons.chevron_right),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Divider(
                height: .2,
                thickness: .2,
                color: Theme.of(context).dividerColor.withOpacity(.1),
              ),
              Expanded(
                flex: 1,
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ListView(
                    children: [
                      Visibility(
                        visible: data.isLogin,
                        child: EluiCellComponent(
                          title: FlutterI18n.translate(context, "app.setting.cell.information.title"),
                          label: FlutterI18n.translate(context, "app.setting.cell.information.describe"),
                          theme: EluiCellTheme(
                            titleColor: Theme.of(context).textTheme.titleMedium?.color,
                            labelColor: Theme.of(context).textTheme.displayMedium?.color,
                            linkColor: Theme.of(context).textTheme.titleMedium?.color,
                            backgroundColor: Theme.of(context).cardTheme.color,
                          ),
                          islink: true,
                          onTap: () => _urlUtil.opEnPage(context, "/account/information/"),
                        ),
                      ),
                      EluiCellComponent(
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
                              elevation: MaterialStateProperty.all(0),
                              padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 20)),
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
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
