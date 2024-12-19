/// 设置中心
library;

import 'package:bfban/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/_cell/cell.dart';
import 'package:flutter_elui_plugin/_message/index.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../index.dart';
import '/provider/translation_provider.dart';
import '/utils/index.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  SettingPageState createState() => SettingPageState();
}

class SettingPageState extends State<SettingPage> {
  final UrlUtil _urlUtil = UrlUtil();

  final StorageAccount _storageAccount = StorageAccount();

  int currNavIndex = 0;

  @override
  void initState() {
    _getHomeNav();
    super.initState();
  }

  /// [Event]
  /// 读取首页加载模块配置
  void _getHomeNav() async {
    dynamic localNavIndex = await _storageAccount.getConfiguration("userHomeNavPageIndex", 1); // type int or bool
    setState(() {
      currNavIndex = localNavIndex ?? 0;
    });
  }

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
  /// 打开翻译器配置
  _opEnPublicTranslator() {
    _urlUtil.opEnPage(context, "/profile/translator");
  }

  /// [Event]
  /// 前往版本
  void _opEnVersionDowUrl() {
    _urlUtil.opEnPage(context, "/profile/version/info");
  }

  /// [Event]
  /// 打开主题
  void _opEnTheme() {
    _urlUtil.opEnPage(context, '/profile/theme');
  }

  /// [Event]
  /// div
  void _opEnDir() {
    _urlUtil.opEnPage(context, '/profile/dir/configuration');
  }

  /// [Event]
  /// 擦除
  void _opEnDestock() {
    _urlUtil.opEnPage(context, '/profile/destock');
  }

  /// [Event]
  /// 语言
  void _opEnLanguage() {
    _urlUtil.opEnPage(context, '/profile/language');
  }

  /// [Event]
  /// 通知
  void _opEnNotice() {
    _urlUtil.opEnPage(context, '/profile/notice');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "app.setting.title")),
      ),
      body: ListView(
        children: [
          EluiCellComponent(
            title: FlutterI18n.translate(context, "app.setting.versions.title"),
            label: FlutterI18n.translate(context, "app.setting.versions.describe"),
            islink: true,
            theme: EluiCellTheme(
              titleColor: Theme.of(context).textTheme.titleMedium?.color,
              labelColor: Theme.of(context).textTheme.displayMedium?.color,
              linkColor: Theme.of(context).textTheme.titleMedium?.color,
              backgroundColor: Theme.of(context).cardTheme.color,
            ),
            cont: Text(ProviderUtil().ofPackage(context).currentVersion.toString()),
            onTap: () => _opEnVersionDowUrl(),
          ),
          const SizedBox(
            height: 10,
          ),
          EluiCellComponent(
            title: FlutterI18n.translate(context, "app.setting.language.title"),
            theme: EluiCellTheme(
              titleColor: Theme.of(context).textTheme.titleMedium?.color,
              labelColor: Theme.of(context).textTheme.displayMedium?.color,
              linkColor: Theme.of(context).textTheme.titleMedium?.color,
              backgroundColor: Theme.of(context).cardTheme.color,
            ),
            cont: Consumer<TranslationProvider>(
              builder: (context, data, child) {
                return Text(data.currentToLocalLangName);
              },
            ),
            islink: true,
            onTap: () => _opEnLanguage(),
          ),
          EluiCellComponent(
            title: FlutterI18n.translate(context, "app.setting.theme.title"),
            label: FlutterI18n.translate(context, "app.setting.theme.describe"),
            theme: EluiCellTheme(
              titleColor: Theme.of(context).textTheme.titleMedium?.color,
              labelColor: Theme.of(context).textTheme.displayMedium?.color,
              linkColor: Theme.of(context).textTheme.titleMedium?.color,
              backgroundColor: Theme.of(context).cardTheme.color,
            ),
            cont: Consumer<ThemeProvider>(
              builder: (context, data, child) {
                return Row(
                  children: [
                    Card(
                      color: data.currentThemeData.scaffoldBackgroundColor,
                      child: const SizedBox(width: 20, height: 20),
                    ),
                    const SizedBox(width: 5),
                    Text(data.currentThemeName.toUpperCase()),
                  ],
                );
              },
            ),
            islink: true,
            onTap: () => _opEnTheme(),
          ),
          EluiCellComponent(
            title: FlutterI18n.translate(context, "app.setting.firstPage.title"),
            label: FlutterI18n.translate(context, "app.setting.firstPage.describe"),
            theme: EluiCellTheme(
              titleColor: Theme.of(context).textTheme.titleMedium?.color,
              labelColor: Theme.of(context).textTheme.displayMedium?.color,
              linkColor: Theme.of(context).textTheme.titleMedium?.color,
              backgroundColor: Theme.of(context).cardTheme.color,
            ),
            cont: Consumer<ThemeProvider>(
              builder: (context, data, child) {
                return Row(
                  children: [
                    DropdownButton(
                      dropdownColor: Theme.of(context).bottomAppBarTheme.color,
                      style: Theme.of(context).dropdownMenuTheme.textStyle,
                      underline: SizedBox(),
                      onChanged: (value) {
                        setState(() {
                          currNavIndex = value as int;
                          _storageAccount.updateConfiguration("userHomeNavPageIndex", currNavIndex);
                        });
                      },
                      value: currNavIndex,
                      items: navs.asMap().entries.map<DropdownMenuItem<int>>((i) {
                        return DropdownMenuItem(
                          value: i.key,
                          child: Text(
                            FlutterI18n.translate(context, "${i.value['name']}.title"),
                            style: TextStyle(fontSize: FontSize.large.value),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          EluiCellComponent(
            title: FlutterI18n.translate(context, "app.setting.notice.title"),
            label: FlutterI18n.translate(context, "app.setting.notice.describe"),
            theme: EluiCellTheme(
              titleColor: Theme.of(context).textTheme.titleMedium?.color,
              labelColor: Theme.of(context).textTheme.displayMedium?.color,
              linkColor: Theme.of(context).textTheme.titleMedium?.color,
              backgroundColor: Theme.of(context).cardTheme.color,
            ),
            islink: true,
            onTap: () => _opEnNotice(),
          ),
          EluiCellComponent(
            title: FlutterI18n.translate(context, "app.setting.publicTranslator.title"),
            label: FlutterI18n.translate(context, "app.setting.publicTranslator.describe"),
            theme: EluiCellTheme(
              titleColor: Theme.of(context).textTheme.titleMedium?.color,
              labelColor: Theme.of(context).textTheme.displayMedium?.color,
              linkColor: Theme.of(context).textTheme.titleMedium?.color,
              backgroundColor: Theme.of(context).cardTheme.color,
            ),
            islink: true,
            onTap: () => _opEnPublicTranslator(),
          ),
          EluiCellComponent(
            title: FlutterI18n.translate(context, "app.setting.cell.dirConfiguration.title"),
            label: FlutterI18n.translate(context, "app.setting.cell.dirConfiguration.describe"),
            theme: EluiCellTheme(
              titleColor: Theme.of(context).textTheme.titleMedium?.color,
              labelColor: Theme.of(context).textTheme.displayMedium?.color,
              linkColor: Theme.of(context).textTheme.titleMedium?.color,
              backgroundColor: Theme.of(context).cardTheme.color,
            ),
            islink: true,
            onTap: () => _opEnDir(),
          ),
          EluiCellComponent(
            title: FlutterI18n.translate(context, "app.setting.cleanManagement.title"),
            label: FlutterI18n.translate(context, "app.setting.cleanManagement.describe"),
            theme: EluiCellTheme(
              titleColor: Theme.of(context).textTheme.titleMedium?.color,
              labelColor: Theme.of(context).textTheme.displayMedium?.color,
              linkColor: Theme.of(context).textTheme.titleMedium?.color,
              backgroundColor: Theme.of(context).cardTheme.color,
            ),
            islink: true,
            onTap: () => _opEnDestock(),
          ),
          EluiCellComponent(
            title: FlutterI18n.translate(context, "app.setting.appInfo.title"),
            label: FlutterI18n.translate(context, "app.setting.appInfo.describe"),
            theme: EluiCellTheme(
              titleColor: Theme.of(context).textTheme.titleMedium?.color,
              labelColor: Theme.of(context).textTheme.displayMedium?.color,
              linkColor: Theme.of(context).textTheme.titleMedium?.color,
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
