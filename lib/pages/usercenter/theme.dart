import 'package:flutter/cupertino.dart';

/// 主题管理

import 'package:flutter/material.dart';
import 'package:flutter_plugin_elui/_button/index.dart';
import 'package:provider/provider.dart';

import 'package:bfban/utils/index.dart';
import '../../constants/theme.dart';

class ThemePage extends StatefulWidget {
  @override
  _ThemePageState createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  String _colorKey;

  @override
  void initState() {
    super.initState();
//    _initAsync();
  }

//  Future<void> _initAsync() async {
//    await SpUtil.getInstance();
//    _colorKey = SpUtil.getString('key_theme_color',
//        defValue: 'blue',
//    ); // 设置初始化主题颜色  Provider.of<AppInfoProvider>(context, listen: false).setTheme(_colorKey);
//  }

  /// 确认主题
  void onTheme() {
    Provider.of<AppInfoProvider>(context, listen: false).setTheme(_colorKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text("主题"),
      ),
      body: ListView(
        children: THEMELIST.keys.map((key) {
          return InkWell(
            onTap: () {
              setState(() {
                _colorKey = key;
              });
            },
            child: Container(
              height: 100,
              margin: EdgeInsets.only(left: 10, right: 10, top: 10),
              color: THEMELIST[key]["nameColor"],
              child: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Text(THEMELIST[key]["name"]),
                    ),
                  ),
                  Center(
                    child: _colorKey == key
                        ? Icon(
                      Icons.done,
                      color: Colors.white,
                    )
                        : null,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
      bottomSheet: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: EluiButtonComponent(
          child: Text(
            "确认",
            style: TextStyle(
              color: THEMELIST[context.watch<AppInfoProvider>().themeColor]["button"]["textColor"],
            ),
          ),
          theme: EluiButtonTheme(
            backgroundColor: THEMELIST[context.watch<AppInfoProvider>().themeColor]["button"]["backgroundColor"],
          ),
          onTap: () => onTheme(),
        ),
      ),
    );
  }
}
