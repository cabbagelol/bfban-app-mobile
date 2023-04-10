/// 清理数据

import 'package:bfban/component/_empty/index.dart';
import 'package:flutter/material.dart';

import 'package:bfban/utils/index.dart';

import 'package:flutter_elui_plugin/_cell/cell.dart';

class DestockPage extends StatefulWidget {
  const DestockPage({Key? key}) : super(key: key);

  @override
  _DestockPageState createState() => _DestockPageState();
}

class _DestockPageState extends State<DestockPage> {
  /// 清单列表
  List destockList = [
    {"name": "1", "data": 1}
  ];

  Storage storage = Storage();

  @override
  void initState() {
    super.initState();

    _getLoaclAll();
  }

  /// [Event]
  /// 获取所有持久数据
  Future _getLoaclAll() async {
    List list = [];

    storage.getAll().then((storageAll) {
      storageAll.forEach((i) async {
        list.add(i);
      });

      setState(() {
        destockList = list;
      });
    });
  }

  /// [Event]
  /// 删除记录
  _removeLocal(e) async {
    String key = e["key"].toString().split(":")[1];
    await storage.remove(key);
    _getLoaclAll();
  }

  /// [Event]
  /// 删除所有记录
  _removeAllLocal() {
    storage.removeAll();

    _getLoaclAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _removeAllLocal(),
          )
        ],
      ),
      body: ListView(
        children: destockList.isNotEmpty
            ? destockList.map((e) {
                return Column(
                  children: [
                    EluiCellComponent(
                      title: e["key"].toString(),
                      label: "${e["value"].toString().length} k",
                      cont: TextButton(
                        onPressed: () => _removeLocal(e),
                        child: const Icon(Icons.delete),
                      ),
                    ),
                    const Divider(height: 1),
                  ],
                );
              }).toList()
            : [const EmptyWidget()],
      ),
    );
  }
}
