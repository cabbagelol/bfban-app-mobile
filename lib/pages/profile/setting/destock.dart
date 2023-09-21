/// 清理数据
import 'package:bfban/component/_empty/index.dart';
import 'package:bfban/constants/api.dart';
import 'package:flutter/material.dart';

import 'package:bfban/utils/index.dart';

import 'package:flutter_elui_plugin/_cell/cell.dart';
import 'package:flutter_elui_plugin/_input/index.dart';
import 'package:flutter_elui_plugin/_tag/tag.dart';
import 'package:flutter_html/flutter_html.dart';

class DestockPage extends StatefulWidget {
  const DestockPage({Key? key}) : super(key: key);

  @override
  _DestockPageState createState() => _DestockPageState();
}

class _DestockPageState extends State<DestockPage> {
  FileManagement _fileManagement = FileManagement();

  String destockEnvValue = "all";

  String destockByteValue = "0";

  String destockKeyValue = "";

  DestockStatus _destockStatus = DestockStatus(list: []);

  Storage storage = Storage();

  bool selectAll = false;

  @override
  void initState() {
    super.initState();

    _getLocalAll();
  }

  /// [Event]
  /// 获取所有持久数据
  Future _getLocalAll() async {
    List<DestockItemData> list = [];

    storage.getAll().then((storageAll) {
      storageAll.forEach((i) {
        DestockItemData destockItemData = DestockItemData();
        destockItemData.setName(i["key"]);
        destockItemData.setValue(i["value"]);
        list.add(destockItemData);
      });

      setState(() {
        _destockStatus.list = list;
      });
    });
  }

  /// [Event]
  /// 删除记录
  _removeLocal(DestockItemData e) async {
    String key = e.fullName.split(":")[1];
    await storage.remove(key);
    _getLocalAll();
  }

  /// [Event]
  /// 删除勾选记录
  _removeSelectLocal() {
    // 全选
    if (_destockStatus.list!.length == _destockStatus.list!.where((element) => element.check).length) _removeAllLocal();

    // 单独
    for (var i in _destockStatus.list!) {
      setState(() {
        if (i.check) _removeLocal(i);
      });
    }

    _getLocalAll();
  }

  /// [Event]
  /// 删除所有
  _removeAllLocal() {
    storage.removeAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt_outlined),
            onPressed: () => _getLocalAll(),
          ),
          if (_destockStatus.list!.where((i) => i.check).isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _removeSelectLocal(),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Row(
              children: [
                Checkbox(
                  value: selectAll,
                  onChanged: (value) {
                    setState(() {
                      selectAll = value!;
                      for (var i in _destockStatus.list!) {
                        i.check = value;
                      }
                    });
                  },
                ),
                const SizedBox(width: 5, child: VerticalDivider()),
                Flexible(
                  flex: 1,
                  child: DropdownButton(
                    underline: Text(
                      "= ${Config.env.name}",
                      style: TextStyle(fontSize: FontSize.xxSmall.value),
                    ),
                    isExpanded: true,
                    dropdownColor: Theme.of(context).bottomAppBarTheme.color,
                    style: Theme.of(context).dropdownMenuTheme.textStyle,
                    onChanged: (value) {
                      setState(() {
                        destockEnvValue = value.toString();
                      });
                    },
                    value: destockEnvValue,
                    items: ['all', 'development', 'production'].map<DropdownMenuItem<String>>((i) {
                      return DropdownMenuItem(
                        value: i.toString(),
                        child: Text(i.toString()),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 10, child: VerticalDivider()),
                Flexible(
                  flex: 1,
                  child: DropdownButton(
                    underline: Text(
                      "> (k)",
                      style: TextStyle(fontSize: FontSize.xxSmall.value),
                    ),
                    isExpanded: true,
                    dropdownColor: Theme.of(context).bottomAppBarTheme.color,
                    style: Theme.of(context).dropdownMenuTheme.textStyle,
                    onChanged: (value) {
                      setState(() {
                        destockByteValue = value.toString();
                      });
                    },
                    value: destockByteValue,
                    items: [0, 10.0, 600.0, 1000.0].map<DropdownMenuItem<String>>((i) {
                      return DropdownMenuItem(
                        value: i.toString(),
                        child: Text(_fileManagement.onUnitConversion(i).toString()),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 10, child: VerticalDivider()),
                Flexible(
                  flex: 2,
                  child: EluiInputComponent(
                    value: "",
                    internalstyle: true,
                    placeholder: "input key",
                    theme: EluiInputTheme(textStyle: Theme.of(context).textTheme.bodyMedium),
                    onChange: (data) {
                      setState(() {
                        destockKeyValue = data["value"].toString();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            flex: 1,
            child: ListView(
              children: _destockStatus.list!.isNotEmpty
                  ? _destockStatus.list!
                      .where((element) {
                        if (destockByteValue == '0') return true;
                        return destockByteValue.isNotEmpty && double.parse(destockByteValue) > element.value.toString().length;
                      })
                      .where((element) {
                        if (destockKeyValue.isEmpty) return true;
                        return destockKeyValue.isNotEmpty && element.key!.contains(destockKeyValue);
                      })
                      .where((element) => destockEnvValue == 'all' ? true : destockEnvValue.isNotEmpty && element.env!.contains(destockEnvValue))
                      .map((e) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: e.check,
                                  onChanged: (value) {
                                    setState(() {
                                      e.check = value!;
                                    });
                                  },
                                ),
                                Expanded(
                                  flex: 1,
                                  child: SelectionArea(
                                    child: EluiCellComponent(
                                      title: "${e.key}",
                                      label: e.fullName,
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(vertical: 5),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Wrap(
                                        spacing: 5,
                                        children: [
                                          EluiTagComponent(
                                            size: EluiTagSize.no2,
                                            color: EluiTagType.primary,
                                            value: "${e.byes}",
                                            onTap: null,
                                          ),
                                          EluiTagComponent(
                                            size: EluiTagSize.no2,
                                            color: EluiTagType.primary,
                                            value: e.appName,
                                            onTap: () {},
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      EluiTagComponent(
                                        size: EluiTagSize.no2,
                                        color: EluiTagType.succeed,
                                        value: e.env,
                                        onTap: () {},
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 5),
                                TextButton(
                                  onPressed: () => _removeLocal(e),
                                  child: const Icon(Icons.delete),
                                ),
                                const SizedBox(width: 5),
                              ],
                            ),
                            const Divider(height: 1),
                          ],
                        );
                      })
                      .toList()
                  : [const EmptyWidget()],
            ),
          ),
        ],
      ),
    );
  }
}

class DestockStatus {
  List<DestockItemData>? list;

  DestockStatus({this.list});
}

class DestockItemData {
  FileManagement _fileManagement = FileManagement();

  bool check;
  String? env;
  String? appName;
  String? key;
  dynamic value;
  String byes;
  String fullName = "";

  DestockItemData({
    this.check = false,
    this.env,
    this.appName,
    this.key,
    this.value,
    this.byes = "-",
  });

  setName(String value) {
    List<String> a = value.split(":");
    List envAndAppName = a[0].split(".");
    String key = a[1];

    this.fullName = value;
    this.env = envAndAppName[1];
    this.appName = envAndAppName[0];
    this.key = key.replaceAll(".", " ").toUpperCase();
  }

  setValue(dynamic value) {
    this.value = value;
    this.byes = _fileManagement.onUnitConversion(this.value.toString().length);
  }
}
