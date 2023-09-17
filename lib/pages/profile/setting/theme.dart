/// 主题管理

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:flutter_elui_plugin/elui.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import 'package:bfban/provider/theme_provider.dart';

import '../../../data/index.dart';

class ThemePage extends StatefulWidget {
  const ThemePage({Key? key}) : super(key: key);

  @override
  _ThemePageState createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  Map fromData = {"textScaleFactor": 1.0, "selectThemeName": "dark"};
  Map themeDiffFromData = {"textScaleFactor": 1.0, "selectThemeName": "dark"};

  ThemeProvider? themeProvider;

  @override
  void initState() {
    themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    setState(() {
      Map d = {
        "selectThemeName": themeProvider!.theme.current,
        "autoSwitchTheme": themeProvider!.theme.autoSwitchTheme,
        "textScaleFactor": themeProvider!.theme.textScaleFactor,
        "autoSwitchTheme.morning": themeProvider!.theme.morning,
        "autoSwitchTheme.evening": themeProvider!.theme.evening,
      };
      themeDiffFromData = Map.from(d);
      fromData = d;
    });

    super.initState();
  }

  /// [Event]
  /// 对比内容是否修改
  bool _contrastModification(Map a, Map b) {
    int l = 0;
    a.forEach((key, value) {
      if (b[key] != value) l += 1;
    });
    return l == 0;
  }

  /// [Event]
  /// 保存主题
  _onSave(ThemeProvider data) {
    // 1
    data.setTheme(fromData["selectThemeName"]);

    // 2
    data.setTextScaleFactor(fromData["textScaleFactor"]);
    data.autoSwitchTheme = fromData["autoSwitchTheme"];
    if (fromData["autoSwitchTheme.morning"] != null) data.theme.morning = fromData["autoSwitchTheme.morning"];
    if (fromData["autoSwitchTheme.evening"] != null) data.theme.evening = fromData["autoSwitchTheme.evening"];

    // 3
    setState(() {
      themeDiffFromData = Map.from(fromData);
    });

    EluiMessageComponent.success(context)(child: const Icon(Icons.done));
  }

  /// [Event]
  /// 颠倒自动切换主题
  _onReverseTheme() {
    String evening = fromData["autoSwitchTheme.evening"];
    String morning = fromData["autoSwitchTheme.morning"];

    setState(() {
      fromData["autoSwitchTheme.evening"] = morning;
      fromData["autoSwitchTheme.morning"] = evening;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (BuildContext context, data, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(FlutterI18n.translate(context, "app.setting.theme.title")),
            actions: [
              if (!_contrastModification(themeDiffFromData, fromData))
                IconButton(
                  onPressed: () {
                    _onSave(data);
                  },
                  icon: const Icon(Icons.done),
                )
            ],
          ),
          body: Column(
            children: [
              // 自动
              EluiCellComponent(
                title: FlutterI18n.translate(context, "app.basic.function.auto.title"),
                label: FlutterI18n.translate(context, "app.basic.function.auto.describe"),
                theme: EluiCellTheme(
                  titleColor: Theme.of(context).textTheme.titleMedium?.color,
                  labelColor: Theme.of(context).textTheme.displayMedium?.color,
                  linkColor: Theme.of(context).textTheme.titleMedium?.color,
                  backgroundColor: Theme.of(context).cardTheme.color,
                ),
                cont: Switch(
                  value: fromData["autoSwitchTheme"],
                  onChanged: (bool value) {
                    setState(() {
                      fromData["autoSwitchTheme"] = value;
                    });
                  },
                ),
              ),
              if (fromData["autoSwitchTheme"])
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  color: Theme.of(context).cardTheme.color,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Wrap(
                          children: [
                            const Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.sunny),
                              ],
                            ),
                            DropdownButton<String>(
                              isExpanded: true,
                              dropdownColor: Theme.of(context).bottomAppBarTheme.color,
                              style: Theme.of(context).dropdownMenuTheme.textStyle,
                              onChanged: (value) {
                                setState(() {
                                  fromData["autoSwitchTheme.morning"] = value;
                                });
                              },
                              value: fromData["autoSwitchTheme.morning"] ?? data.theme.defaultName,
                              items: data.getList!
                                  .map((i) => DropdownMenuItem(
                                      value: i.name,
                                      child: Wrap(
                                        spacing: 5,
                                        children: [
                                          Card(
                                            child: Container(
                                              width: 20,
                                              height: 20,
                                              color: i.themeData!.scaffoldBackgroundColor,
                                            ),
                                          ),
                                          Text(i.name),
                                        ],
                                      )))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        constraints: const BoxConstraints(
                          maxWidth: 110,
                          minWidth: 80,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          children: [
                            Text(
                              "${data.timeInterval.hour}:${data.timeInterval.month}",
                              textAlign: TextAlign.center,
                            ),
                            IconButton(
                              enableFeedback: false,
                              icon: const Icon(Icons.compare_arrows_sharp),
                              color: Theme.of(context).iconTheme.color!.withOpacity(.2),
                              onPressed: () {
                                _onReverseTheme();
                              },
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Wrap(
                          children: [
                            const Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.dark_mode),
                              ],
                            ),
                            DropdownButton<String>(
                              isExpanded: true,
                              dropdownColor: Theme.of(context).bottomAppBarTheme.color,
                              style: Theme.of(context).dropdownMenuTheme.textStyle,
                              onChanged: (value) {
                                setState(() {
                                  fromData["autoSwitchTheme.evening"] = value;
                                });
                              },
                              value: fromData["autoSwitchTheme.evening"] ?? data.theme.defaultName,
                              items: data.getList!
                                  .map((i) => DropdownMenuItem(
                                      value: i.name,
                                      child: Wrap(
                                        spacing: 5,
                                        children: [
                                          Card(
                                            child: Container(
                                              width: 20,
                                              height: 20,
                                              color: i.themeData!.scaffoldBackgroundColor,
                                            ),
                                          ),
                                          Text(i.name),
                                        ],
                                      )))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 5),

              // 字体
              Container(
                color: Theme.of(context).cardTheme.color,
                child: Column(
                  children: [
                    EluiCellComponent(
                      title: FlutterI18n.translate(context, "app.setting.theme.textScaleFactor"),
                      label: fromData["textScaleFactor"].toString(),
                      cont: Slider(
                        value: (fromData["textScaleFactor"] as double),
                        min: 0.8,
                        max: 1.2,
                        divisions: 2,
                        label: data.theme.textScaleFactor!.toStringAsFixed(1),
                        onChanged: (value) {
                          setState(() {
                            fromData["textScaleFactor"] = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // 主题列表
              Expanded(
                flex: 1,
                child: Opacity(
                  opacity: fromData["autoSwitchTheme"]! ? .2 : 1,
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 20.0,
                      crossAxisSpacing: 10.0,
                      childAspectRatio: 1.0,
                    ),
                    padding: const EdgeInsets.all(10),
                    itemCount: data.getList!.length,
                    itemBuilder: (BuildContext context, int index) {
                      AppThemeItem _i = data.getList![index];
                      ThemeData _themedata = _i.themeData!;

                      return GestureDetector(
                        child: Card(
                          clipBehavior: Clip.hardEdge,
                          color: _themedata.scaffoldBackgroundColor,
                          shape: _themedata.cardTheme.shape,
                          child: Stack(
                            children: [
                              Positioned(
                                top: 10,
                                left: 10,
                                right: 10,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _i.name,
                                      style: TextStyle(
                                        fontSize: FontSize.xxLarge.value,
                                        color: _themedata.textTheme.titleMedium!.color,
                                      ),
                                    ),
                                    Text(
                                      "test".toString(),
                                      style: TextStyle(
                                        fontSize: FontSize.large.value,
                                        color: _themedata.textTheme.displayMedium!.color,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Positioned(
                                bottom: 1,
                                left: 1,
                                child: Wrap(
                                  spacing: 1,
                                  runSpacing: 1,
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      color: _themedata.bottomAppBarTheme.color,
                                    ),
                                    Container(
                                      width: 10,
                                      height: 10,
                                      color: _themedata.colorScheme.primary,
                                    ),
                                    Container(
                                      width: 10,
                                      height: 10,
                                      color: _themedata.colorScheme.error,
                                    ),
                                    Container(
                                      width: 10,
                                      height: 10,
                                      color: _themedata.colorScheme.outline,
                                    ),
                                    Container(
                                      width: 10,
                                      height: 10,
                                      color: _themedata.colorScheme.surface,
                                    ),
                                    Container(
                                      width: 10,
                                      height: 10,
                                      color: _themedata.colorScheme.background,
                                    ),
                                    Container(
                                      width: 10,
                                      height: 10,
                                      color: _themedata.bottomNavigationBarTheme.backgroundColor,
                                    ),
                                    Container(
                                      width: 10,
                                      height: 10,
                                      color: _themedata.scaffoldBackgroundColor,
                                    ),
                                  ],
                                ),
                              ),
                              Visibility(
                                visible: _i.name == (fromData["autoSwitchTheme"]! ? fromData["autoSwitchTheme.morning"] : fromData["selectThemeName"]),
                                child: const Positioned(
                                  top: 5,
                                  right: 5,
                                  child: CircleAvatar(
                                    radius: 15,
                                    child: Icon(Icons.done),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          if (fromData["autoSwitchTheme"]) return;
                          setState(() {
                            fromData["selectThemeName"] = _i.name;
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
