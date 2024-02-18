import 'package:bfban/provider/dir_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/_cell/cell.dart';
import 'package:flutter_elui_plugin/_message/index.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

class directoryConfigurationPage extends StatefulWidget {
  const directoryConfigurationPage();

  @override
  State<directoryConfigurationPage> createState() => _directoryConfigurationPageState();
}

class _directoryConfigurationPageState extends State<directoryConfigurationPage> {
  List<DirItemStorePath> paths = [];

  Map configuration = {};

  DirProvider? dirProvider;

  @override
  void initState() {
    ready();
    super.initState();
  }

  ready() async {
    dirProvider = Provider.of<DirProvider>(context, listen: false);

    // 当可选的存储位置丢失（SD拔出），将代替原来
    if (paths.isNotEmpty && paths.where((element) => element.dirName == dirProvider!.defaultSavePathValue).isEmpty) {
      dirProvider!.defaultSavePathValue = paths.first.dirName;
      dirProvider!.notifyListeners();
    }

    setState(() {
      paths = dirProvider!.paths;
    });
  }

  /// [Event]
  /// 保存Dir配置
  onSave(dirData) {
    dirData.setSaveDirPath(paths);

    EluiMessageComponent.success(context)(
      child: const Icon(Icons.done),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DirProvider>(
      builder: (BuildContext? dirContext, dirData, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(FlutterI18n.translate(context, "app.setting.cell.dirConfiguration.title")),
            actions: [
              IconButton(
                padding: const EdgeInsets.all(16),
                onPressed: () => onSave(dirData),
                icon: const Icon(Icons.done),
              )
            ],
          ),
          body: ListView(
            children: [
              EluiCellComponent(
                title: FlutterI18n.translate(context, "app.setting.cell.dirConfiguration.defaultSavePathTitle"),
                label: FlutterI18n.translate(context, "app.setting.cell.dirConfiguration.defaultSavePathDirectory"),
                theme: EluiCellTheme(
                  titleColor: Theme.of(context).textTheme.titleMedium?.color,
                  labelColor: Theme.of(context).textTheme.displayMedium?.color,
                  linkColor: Theme.of(context).textTheme.titleMedium?.color,
                  backgroundColor: Theme.of(context).cardTheme.color,
                ),
                cont: Column(
                  children: [
                    if (!dirData.isSupportDirectory())
                      const Center(
                        child: Icon(Icons.error),
                      )
                    else
                      DropdownButton(
                        isDense: false,
                        dropdownColor: Theme.of(context).bottomAppBarTheme.color,
                        style: Theme.of(context).dropdownMenuTheme.textStyle,
                        onChanged: (value) {
                          setState(() {
                            dirData.defaultSavePathValue = value.toString();
                          });
                        },
                        value: dirData.defaultSavePathValue,
                        items: paths.map((i) {
                          return DropdownMenuItem(
                            value: i.dirName,
                            child: Text(FlutterI18n.translate(context, "app.media.directory.${i.translate!.key!}", translationParams: i.translate!.param)),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              EluiCellComponent(
                title: FlutterI18n.translate(context, "app.setting.cell.dirConfiguration.scanDirectoryTitle"),
                label: FlutterI18n.translate(context, "app.setting.cell.dirConfiguration.scanDirectoryDescription"),
              ),
              Column(
                children: paths.map((e) {
                  return ListTile(
                    leading: Checkbox(
                      value: e.check,
                      onChanged: (value) {
                        if (!value! && paths.where((o) => o.check!).length == 1) {
                          EluiMessageComponent.warning(context)(
                            child: Text(FlutterI18n.translate(context, "app.setting.cell.dirConfiguration.leastOneHint")),
                          );
                          return;
                        }

                        setState(() {
                          e.check = value;
                        });

                        if (!value && paths.where((o) => o.check!).length <= 1) {
                          dirData.defaultSavePathValue = e.dirName;
                        }
                      },
                    ),
                    title: Text(FlutterI18n.translate(context, "app.media.directory.${e.translate!.key!}", translationParams: e.translate!.param)),
                    subtitle: Text(e.basicPath),
                  );
                }).toList(),
              )
            ],
          ),
        );
      },
    );
  }
}
