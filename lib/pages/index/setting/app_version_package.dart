/// 版本

import 'package:bfban/component/_loading/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/_cell/cell.dart';
import 'package:flutter_elui_plugin/_popup/index.dart';
import 'package:flutter_elui_plugin/_tag/tag.dart';
import 'package:flutter_elui_plugin/_tip/index.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../component/_refresh/index.dart';
import '/constants/api.dart';
import '/provider/package_provider.dart';
import '/utils/index.dart';

class AppVersionPackagePage extends StatefulWidget {
  const AppVersionPackagePage({Key? key}) : super(key: key);

  @override
  _AppVersionPackagePageState createState() => _AppVersionPackagePageState();
}

class _AppVersionPackagePageState extends State<AppVersionPackagePage> {
  final UrlUtil _urlUtil = UrlUtil();

  PackageProvider _providerUtil = PackageProvider();

  /// 列表
  final GlobalKey<RefreshState> _refreshKey = GlobalKey<RefreshState>();

  @override
  initState() {
    super.initState();
  }

  /// [Event]
  /// 打开下载链接
  void _openAppDown(i) {
    List platform = [];
    if (i["platform"] == null) return;
    i["platform"].keys.toList().forEach((i) {
      platform.add(i);
    });

    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isDismissible: true,
      isScrollControlled: false,
      showDragHandle: true,
      clipBehavior: Clip.hardEdge,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${i["version"]}",
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(
                height: 30,
                child: Divider(height: 1),
              ),
              Expanded(
                flex: 1,
                child: ListView(
                  children: [
                    ...platform.map((item) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 10),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Wrap(
                                    children: [
                                      const Icon(Icons.link_outlined),
                                      const SizedBox(width: 5),
                                      Text(item.toString()),
                                    ],
                                  ),
                                ),
                                if (i["platform"][item]["url"] != null || i["platform"][item]["url"] != "")
                                  GestureDetector(
                                    onTap: () {
                                      _urlUtil.onPeUrl(
                                        i["platform"][item]["url"],
                                        mode: LaunchMode.externalApplication,
                                      );
                                    },
                                    child: const Icon(Icons.download_for_offline),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    })
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
    // EluiPopupComponent(context)(
    //   placement: EluiPopupPlacement.bottom,
    //   theme: EluiPopupTheme(
    //     popupBackgroundColor: Theme.of(context).bottomAppBarTheme.color!,
    //   ),
    //   child: Container(
    //     padding: const EdgeInsets.all(20),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         Text(
    //           "${i["version"]}",
    //           style: const TextStyle(fontSize: 20),
    //         ),
    //         const SizedBox(
    //           height: 30,
    //           child: Divider(height: 1),
    //         ),
    //         Wrap(
    //           children: platform.map((item) {
    //             return Row(
    //               children: [
    //                 Expanded(
    //                   flex: 1,
    //                   child: Wrap(
    //                     children: [
    //                       const Icon(Icons.link_outlined),
    //                       const SizedBox(width: 5),
    //                       Text(item.toString()),
    //                     ],
    //                   ),
    //                 ),
    //                 if (i["platform"][item]["url"] != null || i["platform"][item]["url"] != "")
    //                   GestureDetector(
    //                     onTap: () {
    //                       _urlUtil.onPeUrl(
    //                         i["platform"][item]["url"],
    //                         mode: LaunchMode.externalApplication,
    //                       );
    //                     },
    //                     child: const Icon(Icons.download_for_offline),
    //                   ),
    //               ],
    //             );
    //           }).toList(),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
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
            child: Column(
              children: [
                const SizedBox(height: 10),
                Card(
                  elevation: 0,
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: EluiCellComponent(
                    title: FlutterI18n.translate(context, "app.setting.versions.currentVersion"),
                    cont: Text.rich(
                      TextSpan(
                        style: TextStyle(
                          fontSize: Theme.of(context).textTheme.titleMedium!.fontSize!,
                        ),
                        children: [
                          TextSpan(text: data.currentVersion.toString()),
                          TextSpan(text: "\t(${data.buildNumber.toString()})"),
                        ],
                      ),
                    ),
                  ),
                ),
                Card(
                  elevation: 0,
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: EluiCellComponent(
                    title: FlutterI18n.translate(context, "app.setting.versions.newVersion"),
                    label: data.isNewVersion ? FlutterI18n.translate(context, "app.setting.versions.newVersionDescribe_new") : FlutterI18n.translate(context, "app.setting.versions.newVersionDescribe_old"),
                    theme: EluiCellTheme(labelColor: Theme.of(context).textTheme.displayMedium!.color),
                    islink: true,
                    cont: data.onlineVersion.isNotEmpty
                        ? Text.rich(
                            style: TextStyle(
                              fontSize: Theme.of(context).textTheme.titleMedium!.fontSize!,
                            ),
                            TextSpan(text: data.onlineVersion.toString()),
                          )
                        : const LoadingWidget(strokeWidth: 2),
                    onTap: () => _urlUtil.onPeUrl(Config.apiHost["app_web_site"]!.url),
                  ),
                ),
                SizedBox(height: 15),
                Divider(height: 1),
                Expanded(
                  flex: 1,
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    children: [
                      data.list.where((i) => i["version"] == data.currentVersion).toList().isEmpty
                          ? SizedBox(
                              height: 50,
                              child: RawChip(
                                backgroundColor: Color.lerp(Theme.of(context).colorScheme.primary, Color(0xffc59b0b), .6),
                                avatar: Icon(Icons.info_outline),
                                label: Text(FlutterI18n.translate(context, "app.setting.versions.superHairVersionTip")),
                              ),
                            )
                          : Container(),
                      const SizedBox(height: 10),
                      ...data.list.map((e) {
                        return ListTile(
                          title: Text(
                            e["version"].toString(),
                            style: TextStyle(fontSize: Theme.of(context).textTheme.titleLarge!.fontSize),
                          ),
                          subtitle: Wrap(
                            children: [
                              EluiTagComponent(
                                value: "${FlutterI18n.translate(context, "app.setting.versions.type")}: ${e["stage"].toUpperCase()}",
                                color: EluiTagType.none,
                                size: EluiTagSize.no2,
                                theme: EluiTagTheme(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  borderColor: Theme.of(context).bottomAppBarTheme.color!,
                                ),
                                onTap: () {},
                              ),
                              const SizedBox(width: 10),
                              e["version"] == data.currentVersion
                                  ? EluiTagComponent(
                                      value: "Current Version",
                                      color: EluiTagType.none,
                                      size: EluiTagSize.no2,
                                      theme: EluiTagTheme(
                                        backgroundColor: Theme.of(context).colorScheme.primary,
                                        borderColor: Theme.of(context).bottomAppBarTheme.color!,
                                      ),
                                      onTap: () {},
                                    )
                                  : Container(),
                            ],
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _openAppDown(e),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
