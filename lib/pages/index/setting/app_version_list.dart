import 'package:bfban/component/_empty/index.dart';
import 'package:bfban/utils/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/_tag/tag.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../component/_refresh/index.dart';
import '../../../provider/package_provider.dart';
import '../../../utils/url.dart';
import '../../../utils/version.dart';

class AppVersionList extends StatefulWidget {
  const AppVersionList({super.key});

  @override
  State<AppVersionList> createState() => _AppVersionListState();
}

class _AppVersionListState extends State<AppVersionList> {
  late final TextEditingController _searchController = TextEditingController(text: "");

  final Version _version = Version();

  final UrlUtil _urlUtil = UrlUtil();

  final PackageProvider _providerUtil = PackageProvider();

  /// 列表
  final GlobalKey<RefreshState> _refreshKey = GlobalKey<RefreshState>();

  // 忽略列表
  Map _ignoredVersions = {};

  @override
  void initState() {
    onReady();
    super.initState();
  }

  void onReady() async {
    _ignoredVersions = await _version.getIgnoredVersions();

    _searchController.addListener(() {
      setState(() {});
    });

    setState(() {});
  }

  /// [Event]
  /// 查询符合版本
  List inquireVersion(PackageProvider data) {
    return data.list.where((i) => _searchController.text.isEmpty || i["version"].indexOf(_searchController.text) >= 0).toList();
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
              /// appbar
              Row(
                children: [
                  Text(
                    "${i["version"]}",
                    style: const TextStyle(fontSize: 20),
                  ),
                  Spacer(),
                  IconButton(onPressed: () => _onDisabledVisibleVersion(i), icon: Icon(Icons.disabled_visible))
                ],
              ),

              /// data
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
                                    child: const Icon(Icons.open_in_new),
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
  }

  /// [Event]
  /// 忽略此版本
  void _onDisabledVisibleVersion(Map i) {
    _version.onIgnoredVersionItemAsName(i);
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
        title: Text(FlutterI18n.translate(context, "app.setting.versions.showVersionsTitle")),
      ),
      body: Consumer<PackageProvider>(
        builder: (BuildContext context, data, child) {
          return Refresh(
            key: _refreshKey,
            onRefresh: _onRefresh,
            child: ListView.separated(
              itemCount: data.list.where((i) => i["version"] == data.currentVersion).toList().length,
              padding: EdgeInsets.symmetric(vertical: 10),
              separatorBuilder: (BuildContext context, int index) => const Divider(),
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: [
                    /// search box
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),

                    /// hint
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

                    /// list
                    if (inquireVersion(data).isEmpty) EmptyWidget(),
                    ...inquireVersion(data).map((e) {
                      return ListTile(
                        title: Text(
                          "${e["version"]}",
                          style: TextStyle(fontSize: Theme.of(context).textTheme.titleLarge!.fontSize),
                        ),
                        subtitle: Wrap(
                          spacing: 10,
                          runSpacing: 3,
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
                            if (e["version"] == data.currentVersion)
                              EluiTagComponent(
                                value: FlutterI18n.translate(context, "app.setting.versions.currentVersion"),
                                color: EluiTagType.none,
                                size: EluiTagSize.no2,
                                theme: EluiTagTheme(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  borderColor: Theme.of(context).bottomAppBarTheme.color!,
                                ),
                                onTap: () {},
                              ),
                            if (_ignoredVersions.entries.toList().map((i) => i.key).contains(e['version']))
                              EluiTagComponent(
                                value: FlutterI18n.translate(context, "app.setting.versions.ignoredCurrentVersionItem"),
                                color: EluiTagType.none,
                                size: EluiTagSize.no2,
                                theme: EluiTagTheme(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  borderColor: Theme.of(context).bottomAppBarTheme.color!,
                                ),
                                onTap: () {},
                              )
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _openAppDown(e),
                      );
                    })
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
