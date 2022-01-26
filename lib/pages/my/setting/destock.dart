/// 清理数据

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

  @override
  void initState() {
    super.initState();

    _getLoaclAll();
  }

  /// [Event]
  /// 获取所有持久数据
  Future _getLoaclAll() async {
    List list = [];
    Storage().getAll().then((value) {
      value.forEach((i)  {
        list.add({
          "name": i,
        });
      });

      setState(() {
        destockList = list;
      });
    });
  }

  /// [Event]
  /// 删除记录
  _removeLoacl (e) async {
    await Storage().remove(e["name"]);
    _getLoaclAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: destockList.map((e) {
          return EluiCellComponent(
            title: e["name"].toString(),
            cont: TextButton(
              onPressed: () => _removeLoacl(e),
              child: Icon(Icons.delete),
            ),
          );
        }).toList(),
      ),
    );
  }
}
