import 'package:bfban/provider/dir_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/_cell/cell.dart';
import 'package:flutter_elui_plugin/_message/index.dart';
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

    setState(() {
      paths = dirProvider!.paths;
    });
  }

  /// [Event]
  /// 保存Dir配置
  onSave(dirData) {
    dirData.setSaveDirPath(paths);

    EluiMessageComponent.success(context)(
      child: const Text("ok"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DirProvider>(
      builder: (BuildContext? dirContext, dirData, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                onPressed: () => onSave(dirData),
                icon: const Icon(Icons.done),
              )
            ],
          ),
          body: ListView(
            children: [
              EluiCellComponent(
                title: "默认下载位置",
                label: "程序内下载首选储存位置",
                theme: EluiCellTheme(
                  titleColor: Theme.of(context).textTheme.titleMedium?.color,
                  labelColor: Theme.of(context).textTheme.displayMedium?.color,
                  linkColor: Theme.of(context).textTheme.titleMedium?.color,
                  backgroundColor: Theme.of(context).cardTheme.color,
                ),
                cont: DropdownButton(
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
                      child: Text(i.dirName.toUpperCase()),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 5),
              EluiCellComponent(
                title: FlutterI18n.translate(context, "扫描位置"),
                label: "选择扫描文件目录(多选)",
              ),
              Column(
                children: paths.map((e) {
                  return ListTile(
                    leading: Radio(
                      value: e.dirName,
                      groupValue: dirData.defaultSavePathValue,
                      onChanged: (value) {
                        setState(() {
                          dirData.defaultSavePathValue = value.toString();
                        });
                      },
                    ),
                    title: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.dirName),
                      ],
                    ),
                    subtitle: Text(e.basicPath),
                    trailing: Checkbox(
                      value: e.check,
                      onChanged: (value) {
                        if (!value! && paths.where((o) => o.check!).length == 1) {
                          EluiMessageComponent.warning(context)(child: const Text("至少选择一个"));
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
