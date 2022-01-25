/// 版本

import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/_cell/cell.dart';
import 'package:flutter_elui_plugin/_tag/tag.dart';
import 'package:flutter_elui_plugin/_tip/index.dart';
import 'package:provider/provider.dart';

import '../../constants/api.dart';
import '../../provider/package_provider.dart';
import '../../utils/index.dart';

class AppPackagePage extends StatefulWidget {
  const AppPackagePage({Key? key}) : super(key: key);

  @override
  _AppPackagePageState createState() => _AppPackagePageState();
}

class _AppPackagePageState extends State<AppPackagePage> {
  final UrlUtil _urlUtil = UrlUtil();

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              _urlUtil.opEnPage(context, "/network");
            },
            icon: Icon(Icons.electrical_services),
          ),
        ],
      ),
      body: Consumer<PackageProvider>(
        builder: (BuildContext context, data, child) {
          return RefreshIndicator(
            onRefresh: data.getOnlinePackage,
            color: Theme.of(context).floatingActionButtonTheme.focusColor,
            backgroundColor:
                Theme.of(context).floatingActionButtonTheme.backgroundColor,
            child: Column(
              children: [
                Card(
                  child: EluiCellComponent(
                    title: "当前版本",
                    cont: Text(data.currentVersion.toString()),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                ),
                Card(
                  child: EluiCellComponent(
                    title: "最新版本",
                    label: data.isNewVersion ? "最新" : "需更新",
                    theme: EluiCellTheme(
                        labelColor:
                            Theme.of(context).textTheme.subtitle2!.color),
                    islink: true,
                    cont: data.onlineVersion.isNotEmpty
                        ? Text(data.onlineVersion.toString())
                        : CircularProgressIndicator(strokeWidth: 2),
                    onTap: () {
                      _urlUtil.onPeUrl(Config.apiHost["app"]);
                    },
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                ),
                SizedBox(height: 10),
                data.list
                            .where((i) {
                              return data.setIssue(i["version"], i["stage"]) ==
                                  data.currentVersion;
                            })
                            .toList()
                            .length <=
                        0
                    ? SizedBox(
                        height: 50,
                        child: EluiTipComponent(
                          type: EluiTip.warning,
                          child: Text("未找到对应版本，您当前版本可能是超发版本"),
                        ),
                      )
                    : Container(),
                SizedBox(height: 10),
                Expanded(
                  flex: 1,
                  child: ListView(
                    children: data.list.map((e) {
                      return ListTile(
                        title: Wrap(
                          runAlignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(e["version"].toString()),
                            SizedBox(width: 10),
                            EluiTagComponent(
                              value: "类型: ${e["stage"].toUpperCase()}",
                              color: EluiTagType.none,
                              size: EluiTagSize.no2,
                              theme: EluiTagTheme(
                                backgroundColor:
                                    Theme.of(context).backgroundColor,
                                borderColor: Theme.of(context).backgroundColor,
                              ),
                            ),
                            SizedBox(width: 10),
                            data.setIssue(e["version"], e["stage"]) ==
                                    data.currentVersion
                                ? EluiTagComponent(
                                    value: "当前版本",
                                    color: EluiTagType.none,
                                    size: EluiTagSize.no2,
                                    theme: EluiTagTheme(
                                      backgroundColor: Theme.of(context)
                                          .appBarTheme
                                          .backgroundColor!,
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                        subtitle: Text(e["describe"].toString()),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () {
                          _urlUtil.onPeUrl(e["src"]);
                        },
                      );
                    }).toList(),
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
