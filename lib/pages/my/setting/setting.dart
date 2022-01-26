/// 设置中心

import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/_cell/cell.dart';
import 'package:flutter_elui_plugin/_message/index.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../utils/index.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final UrlUtil _urlUtil = UrlUtil();

  /// [Event]
  /// 打开权限中心
  void _opEnPermanently() async {
    try {
      if (!await openAppSettings()) {
        EluiMessageComponent.error(context)(child: const Text("该设备无法打开权限, 请尝试在设置>应用打开"));
      }
    } catch (E) {
      rethrow;
    }
  }

  /// [Event]
  /// 前往下载页面
  void _opEnVersionDowUrl() {
    _urlUtil.opEnPage(context, "/my/version");
  }

  /// [Event]
  /// 打开主题
  void _opEnTheme() {
    _urlUtil.opEnPage(context, '/my/theme').then((value) {});
  }

  /// [Event]
  /// 清洁
  void _opEnDestock() {
    _urlUtil.opEnPage(context, '/my/destock').then((value) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          EluiCellComponent(
            title: "版本",
            label: "程序版本",
            islink: true,
            theme: EluiCellTheme(
              titleColor: Theme.of(context).textTheme.subtitle1?.color,
              labelColor: Theme.of(context).textTheme.subtitle2?.color,
              linkColor: Theme.of(context).textTheme.subtitle1?.color,
              backgroundColor: Theme.of(context).cardTheme.color,
            ),
            cont: Text(ProviderUtil().ofPackage(context).currentVersion.toString()),
            onTap: () => _opEnVersionDowUrl(),
          ),
          SizedBox(height: 10),
          EluiCellComponent(
            title: "主题",
            label: "程序主题",
            theme: EluiCellTheme(
              titleColor: Theme.of(context).textTheme.subtitle1?.color,
              labelColor: Theme.of(context).textTheme.subtitle2?.color,
              linkColor: Theme.of(context).textTheme.subtitle1?.color,
              backgroundColor: Theme.of(context).cardTheme.color,
            ),
            islink: true,
            onTap: () => _opEnTheme(),
          ),
          EluiCellComponent(
            title: "清理",
            label: "清理程序缓存文件",
            theme: EluiCellTheme(
              titleColor: Theme.of(context).textTheme.subtitle1?.color,
              labelColor: Theme.of(context).textTheme.subtitle2?.color,
              linkColor: Theme.of(context).textTheme.subtitle1?.color,
              backgroundColor: Theme.of(context).cardTheme.color,
            ),
            islink: true,
            onTap: () => _opEnDestock(),
          ),
          EluiCellComponent(
            title: "应用信息",
            label: "打开程序应用信息",
            theme: EluiCellTheme(
              titleColor: Theme.of(context).textTheme.subtitle1?.color,
              labelColor: Theme.of(context).textTheme.subtitle2?.color,
              linkColor: Theme.of(context).textTheme.subtitle1?.color,
              backgroundColor: Theme.of(context).cardTheme.color,
            ),
            islink: true,
            onTap: () => _opEnPermanently(),
          ),
        ],
      ),
    );
  }
}
