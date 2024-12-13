/// 版本
library;

import 'package:bfban/widgets/red_dot.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

import '/component/_html/htmlLink.dart';
import '/component/_loading/index.dart';
import '/component/_refresh/index.dart';
import '/constants/api.dart';
import '/provider/package_provider.dart';
import '/utils/index.dart';

class AppVersionPackagePage extends StatefulWidget {
  const AppVersionPackagePage({super.key});

  @override
  AppVersionPackagePageState createState() => AppVersionPackagePageState();
}

class AppVersionPackagePageState extends State<AppVersionPackagePage> {
  final UrlUtil _urlUtil = UrlUtil();

  final PackageProvider _providerUtil = PackageProvider();

  /// 列表
  final GlobalKey<RefreshState> _refreshKey = GlobalKey<RefreshState>();

  final StorageAccount _storageAccount = StorageAccount();

  // 是否全局忽略
  late bool _isGloballyIgnoredVersion = false;

  @override
  initState() {
    super.initState();
    onReady();
  }

  onReady() async {
    _isGloballyIgnoredVersion = await _storageAccount.getConfiguration("globallyIgnoredVersion", _isGloballyIgnoredVersion);
    setState(() {});
  }

  Future _onRefresh() async {
    _providerUtil.getOnlinePackage();

    _refreshKey.currentState?.controller.finishRefresh();
    _refreshKey.currentState?.controller.resetFooter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "app.setting.versions.title")),
        actions: [
          IconButton(
            padding: const EdgeInsets.all(16),
            onPressed: () {
              _urlUtil.opEnPage(context, "/network");
            },
            icon: const Icon(Icons.electrical_services),
          ),
        ],
      ),
      body: Consumer<PackageProvider>(
        builder: (BuildContext context, data, child) {
          return Refresh(
            key: _refreshKey,
            onRefresh: _onRefresh,
            child: ListView(
              children: [
                /// hint
                if (data.isNewVersion)
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 0),
                    child: Dialog.fullscreen(
                      backgroundColor: Color.lerp(Theme.of(context).colorScheme.primary, Color(0xffc59b0b), .6),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 35),
                        child: Column(
                          children: [
                            Icon(Icons.tips_and_updates, size: 40),
                            SizedBox(height: 5),
                            Text(
                              FlutterI18n.translate(context, "app.setting.versions.newVersionTip"),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                /// version info
                ListBody(
                  children: [
                    ListTile(
                      title: Text(FlutterI18n.translate(context, "app.setting.versions.currentVersion")),
                      trailing: Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontSize: Theme.of(context).textTheme.titleMedium!.fontSize!,
                          ),
                          children: [
                            TextSpan(text: data.currentVersion.toString()),
                            TextSpan(text: "\t(${data.currentVersion}${data.info!.buildNumber})".replaceAll('.', '')),
                          ],
                        ),
                      ),
                      onLongPress: () => Clipboard.setData(ClipboardData(text: data.info.toString())),
                    ),
                    Divider(indent: 8, height: 1),
                    ListTile(
                      title: Text(FlutterI18n.translate(context, "app.setting.versions.newVersion")),
                      trailing: data.onlineVersion.isNotEmpty
                          ? Text.rich(
                              WidgetSpan(
                                child: RedDotWidget(
                                  show: data.isNewVersion,
                                  child: HtmlLink(
                                    url: Config.apiHost["app_web_site"]!.url,
                                    text: data.onlineVersion.toString(),
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                              ),
                            )
                          : const LoadingWidget(strokeWidth: 2),
                    ),
                    Divider(indent: 8, height: 1),
                    ListTile(
                      title: Text(FlutterI18n.translate(context, "app.setting.versions.buildNumber")),
                      subtitle: Text.rich(
                        style: TextStyle(
                          fontSize: Theme.of(context).textTheme.titleMedium!.fontSize!,
                        ),
                        TextSpan(text: "${data.info!.buildNumber}\t·\t${data.currentVersion}${data.info!.buildNumber}".replaceAll('.', '')),
                      ),
                    ),
                    Divider(indent: 8, height: 1),
                    ListTile(
                      title: Text(FlutterI18n.translate(context, "app.setting.versions.buildSignature")),
                      subtitle: Text.rich(
                        style: TextStyle(
                          fontSize: Theme.of(context).textTheme.titleMedium!.fontSize!,
                        ),
                        TextSpan(text: data.info!.buildSignature.isNotEmpty ? data.info!.buildSignature : 'N/A'),
                      ),
                    ),
                    Divider(indent: 8, height: 1),
                    ListTile(
                      title: Text(FlutterI18n.translate(context, "app.setting.versions.installerStore")),
                      subtitle: Text.rich(
                        style: TextStyle(
                          fontSize: Theme.of(context).textTheme.titleMedium!.fontSize!,
                        ),
                        TextSpan(text: data.info!.installerStore ?? 'N/A'),
                      ),
                    ),
                    Divider(indent: 8, height: 1),
                    ListTile(
                      title: Text(FlutterI18n.translate(context, "app.setting.versions.appName")),
                      subtitle: Text.rich(
                        style: TextStyle(
                          fontSize: Theme.of(context).textTheme.titleMedium!.fontSize!,
                        ),
                        TextSpan(text: data.info!.appName ?? 'N/A'),
                      ),
                    ),
                    Divider(indent: 8, height: 1),
                    ListTile(
                      title: Text(FlutterI18n.translate(context, "app.setting.versions.packageName")),
                      subtitle: Text.rich(
                        style: TextStyle(
                          fontSize: Theme.of(context).textTheme.titleMedium!.fontSize!,
                        ),
                        TextSpan(text: data.info!.packageName ?? 'N/A'),
                      ),
                    ),
                    Divider(indent: 8, height: 1),
                    ListTile(
                      title: Text(FlutterI18n.translate(context, "app.setting.versions.ignoredGloballyVersionTitle")),
                      subtitle: Text(FlutterI18n.translate(context, "app.setting.versions.ignoredGloballyVersionSubtitle")),
                      style: ListTileStyle.drawer,
                      tileColor: _isGloballyIgnoredVersion ? Theme.of(context).colorScheme.error.withOpacity(.2) : null,
                      trailing: Switch(
                        value: _isGloballyIgnoredVersion,
                        onChanged: (value) {
                          setState(() {
                            _isGloballyIgnoredVersion = !_isGloballyIgnoredVersion;
                          });
                          _storageAccount.updateConfiguration("globallyIgnoredVersion", _isGloballyIgnoredVersion);
                        },
                      ),
                    ),
                    Divider(indent: 8, height: 1),
                    ListTile(
                      title: Text(FlutterI18n.translate(context, "app.setting.versions.showVersionsTitle")),
                      subtitle: Text(FlutterI18n.translate(context, "app.setting.versions.showVersionsSubtitle")),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () {
                        _urlUtil.opEnPage(context, "/profile/version/list");
                      },
                    ),
                    Divider(),
                    ListTile(
                      subtitle: SelectionArea(
                        child: Text.rich(
                          style: TextStyle(
                            fontSize: Theme.of(context).textTheme.titleMedium!.fontSize!,
                          ),
                          TextSpan(text: data.info!.toString() ?? 'N/A'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
