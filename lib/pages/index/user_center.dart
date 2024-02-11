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

  @override
  Widget build(BuildContext context) {
    return Consumer<UserInfoProvider>(
      builder: (context, UserInfoProvider data, child) {
        return CustomScrollView(
          slivers: [
            SliverAppBar(
              stretch: true,
              pinned: true,
              primary: true,
              automaticallyImplyLeading: false,
              toolbarHeight: 0,
              centerTitle: true,
              backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
              expandedHeight: MediaQuery.of(context).systemGestureInsets.top + kBottomNavigationBarHeight + 50,
              flexibleSpace: FlexibleSpaceBar(
                expandedTitleScale: 1.5,
                stretchModes: const [StretchMode.fadeTitle],
                centerTitle: true,
                title: Wrap(
                  children: [
                    if (data.userinfo["username"] != null)
                      Text(
                        data.userinfo["username"],
                        style: TextStyle(fontSize: FontSize.xLarge.value),
                        overflow: TextOverflow.ellipsis,
                        textWidthBasis: TextWidthBasis.longestLine,
                        maxLines: 1,
                      )
                    else
                      Text(
                        FlutterI18n.translate(context, "profile.title"),
                      )
                  ],
                ),
              ),
            ),
            SliverFillRemaining(
              fillOverscroll: false,
              hasScrollBody: false,
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: Column(
                  children: [
                    ClipPath(
                      clipBehavior: Clip.hardEdge,
                      child: InkWell(
                        onTap: _opEnSpace(),
                        child: Container(
                          color: Theme.of(context).appBarTheme.backgroundColor!.withOpacity(.4),

                          /// 用户信息板块
                          child: Container(
                            color: Theme.of(context).appBarTheme.backgroundColor,
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
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Wrap(
                                      spacing: 35,
                                      runSpacing: 5,
                                      children: [
                                        if (data.userinfo["username"] != null)
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                FlutterI18n.translate(context, "profile.meet", translationParams: {"name": data.userinfo["username"]}),
                                                style: TextStyle(
                                                  fontSize: FontSize.medium.value,
                                                  color: Theme.of(context).textTheme.titleMedium?.color,
                                                ),
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
                                  const Icon(Icons.chevron_right),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    if (data.isLogin)
                      EluiCellComponent(
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
                    if (data.isLogin)
                      EluiCellComponent(
                        title: FlutterI18n.translate(context, "app.setting.cell.achievement.title"),
                        label: FlutterI18n.translate(context, "app.setting.cell.achievement.describe"),
                        theme: EluiCellTheme(
                          titleColor: Theme.of(context).textTheme.titleMedium?.color,
                          labelColor: Theme.of(context).textTheme.displayMedium?.color,
                          linkColor: Theme.of(context).textTheme.titleMedium?.color,
                          backgroundColor: Theme.of(context).cardTheme.color,
                        ),
                        islink: true,
                        onTap: () => _urlUtil.opEnPage(context, "/account/achievements/"),
                      ),
                    EluiCellComponent(
                      title: FlutterI18n.translate(context, "app.setting.cell.history.title"),
                      label: FlutterI18n.translate(context, "app.setting.cell.history.describe"),
                      theme: EluiCellTheme(
                        titleColor: Theme.of(context).textTheme.titleMedium?.color,
                        labelColor: Theme.of(context).textTheme.displayMedium?.color,
                        linkColor: Theme.of(context).textTheme.titleMedium?.color,
                        backgroundColor: Theme.of(context).cardTheme.color,
                      ),
                      islink: true,
                      onTap: () => _urlUtil.opEnPage(context, "/account/history/"),
                    ),
                    if (data.isLogin)
                      EluiCellComponent(
                        title: FlutterI18n.translate(context, "app.setting.cell.subscribes.title"),
                        label: FlutterI18n.translate(context, "app.setting.cell.subscribes.describe"),
                        theme: EluiCellTheme(
                          titleColor: Theme.of(context).textTheme.titleMedium?.color,
                          labelColor: Theme.of(context).textTheme.displayMedium?.color,
                          linkColor: Theme.of(context).textTheme.titleMedium?.color,
                          backgroundColor: Theme.of(context).cardTheme.color,
                        ),
                        islink: true,
                        onTap: () => _urlUtil.opEnPage(context, "/account/subscribes/"),
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
                    if (data.isLogin)
                      EluiCellComponent(
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
                    const SizedBox(
                      height: 20,
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
                    const SizedBox(height: 20),
                    if (data.isLogin)
                      EluiCellComponent(
                        title: FlutterI18n.translate(context, "header.signout"),
                        icons: const Icon(Icons.exit_to_app),
                        theme: EluiCellTheme(
                          titleColor: Theme.of(context).textTheme.titleMedium?.color,
                          labelColor: Theme.of(context).textTheme.displayMedium?.color,
                          linkColor: Theme.of(context).textTheme.titleMedium?.color,
                          backgroundColor: Theme.of(context).cardTheme.color,
                        ),
                        onTap: () => removeUserInfo(data),
                      ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: kBottomNavigationBarHeight + 20)),
          ],
        );
      },
    );
  }
}
