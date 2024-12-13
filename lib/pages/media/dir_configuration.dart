import 'package:bfban/provider/dir_provider.dart';
import 'package:bfban/utils/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/_cell/cell.dart';
import 'package:flutter_elui_plugin/_message/index.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

class DirectoryConfigurationPage extends StatefulWidget {
  const DirectoryConfigurationPage({super.key});

  @override
  State<DirectoryConfigurationPage> createState() => DirectoryConfigurationPageState();
}

class DirectoryConfigurationPageState extends State<DirectoryConfigurationPage> {
  final StorageAccount _storageAccount = StorageAccount();

  List<DirItemStorePath> paths = [];

  Map configuration = {};

  DirProvider? dirProvider;

  bool logShow = false;

  @override
  void initState() {
    onReady();
    super.initState();
  }

  onReady() async {
    dirProvider = Provider.of<DirProvider>(context, listen: false);
    bool logShowData = await _storageAccount.getConfiguration("logShowFile", logShow);

    // 当可选的存储位置丢失（SD拔出），将代替原来
    if (paths.isNotEmpty && paths.where((element) => element.dirName == dirProvider!.defaultSavePathValue).isEmpty) {
      dirProvider!.defaultSavePathValue = paths.first.dirName;
      // dirProvider!.notifyListeners();
    }

    setState(() {
      logShow = logShowData;
      paths = dirProvider!.paths;
    });
  }

  /// [Event]
  /// 保存Dir配置
  onSave(DirProvider dirData) {
    try {
      dirData.setSaveDirPath(paths);

      EluiMessageComponent.success(context)(
        child: const Icon(Icons.done),
      );
    } catch (E) {
      EluiMessageComponent.error(context)(
        child: Text(E.toString()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DirProvider>(
      builder: (BuildContext? dirContext, DirProvider dirData, Widget? child) {
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
              ListTile(
                title: Text(FlutterI18n.translate(context, "app.setting.cell.dirConfiguration.defaultSavePathTitle")),
                subtitle: Text(FlutterI18n.translate(context, "app.setting.cell.dirConfiguration.defaultSavePathDirectory")),
                trailing: Column(
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
              Divider(indent: 8),
              ListTile(
                title: Text("log show"),
                subtitle: Text("Scan the.log file, which will allow users to view the stored error log"),
                trailing: Switch(
                  value: logShow,
                  onChanged: (value) {
                    setState(() {
                      logShow = !logShow;
                    });
                    _storageAccount.updateConfiguration("logShowFile", logShow);
                  },
                ),
              ),
              Divider(),
              ListTile(
                trailing: Icon(Icons.content_paste_search),
                title: Text(FlutterI18n.translate(context, "app.setting.cell.dirConfiguration.scanDirectoryTitle")),
                subtitle: Text(FlutterI18n.translate(context, "app.setting.cell.dirConfiguration.scanDirectoryDescription")),
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
