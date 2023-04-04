/// 主题管理

import 'package:flutter/material.dart';
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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "app.setting.theme.title")),
      ),
      body: Consumer<ThemeProvider>(
        builder: (BuildContext context, data, Widget? child) {
          return Column(
            children: [
              // 自动
              EluiCellComponent(
                title: FlutterI18n.translate(context, "app.basic.function.auto.title"),
                label: FlutterI18n.translate(context, "app.basic.function.auto.describe"),
                theme: EluiCellTheme(
                  titleColor: Theme.of(context).textTheme.subtitle1?.color,
                  labelColor: Theme.of(context).textTheme.subtitle2?.color,
                  linkColor: Theme.of(context).textTheme.subtitle1?.color,
                  backgroundColor: Theme.of(context).cardTheme.color,
                ),
                cont: Switch(
                  value: data.autoSwitchTheme!,
                  onChanged: (bool value) {
                    data.autoSwitchTheme = value;
                  },
                ),
              ),
              // 主题列表
              Expanded(
                flex: 1,
                child: Opacity(
                  opacity: data.autoSwitchTheme! ? .2 : 1,
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
                          color: _themedata.bottomAppBarTheme.color,
                          child: Stack(
                            children: [
                              Center(
                                child: Text(
                                  _i.name,
                                  style: TextStyle(
                                    color: _themedata.textTheme.titleMedium!.color,
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: _i.name == data.currentThemeName,
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
                        onTap: () => data.setTheme(_i.name),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
