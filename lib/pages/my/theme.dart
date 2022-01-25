
/// 主题管理

import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/_button/index.dart';
import 'package:flutter_elui_plugin/_load/index.dart';

import 'package:bfban/utils/index.dart';
import '../../constants/theme.dart';

class ThemePage extends StatefulWidget {
  const ThemePage({Key? key}) : super(key: key);

  @override
  _ThemePageState createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  late String _colorKey;

  bool _themeLoad = false;

  @override
  void initState() {
    super.initState();
    _initTheme();
  }

  /// 初始主题
  Future<void> _initTheme() async {
    String res = await Storage().get("com.bfban.theme");
    if (res != null) {
      setState(() {
        _colorKey = res;

      });
    } else {
      // Provider.of<AppInfoProvider>(context, listen: false).setTheme('none');
    }
  }

  /// 确认主题
  void onTheme() async {
    setState(() {
      _themeLoad = true;
    });

    // await Provider.of<AppInfoProvider>(context, listen: false).setTheme(_colorKey);
    await Storage().set("com.bfban.theme", value: _colorKey);

    setState(() {
      _themeLoad = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("主题"),
      ),
      body: GridView(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 20.0,
          crossAxisSpacing: 10.0,
          childAspectRatio: 1.0,
        ),
        padding: const EdgeInsets.all(10),
        children: THEMELIST.keys.map((key) {
          return InkWell(
            onTap: () {
              setState(() {
                _colorKey = key;
              });
            },
            child: Container(
              color: THEMELIST[key]["nameColor"],
              child: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Text(THEMELIST[key]["name"]),
                    ),
                  ),
                  Container(
                    color: _colorKey == key ? Colors.black12 : null,
                    child: Center(
                      child: _colorKey == key
                          ? const Icon(
                              Icons.done,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  )
                ],
              ),
            ),
          );
        }).toList(),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: EluiButtonComponent(
          disabled: _themeLoad,
          child: _themeLoad
              ? const ELuiLoadComponent(
                  type: "line",
                  lineWidth: 2,
                  size: 18,
                )
              : const Text(
                  "确认",
                ),
          theme: EluiButtonTheme(
            backgroundColor: Theme.of(context).buttonColor,
          ),
          onTap: () => onTheme(),
        ),
      ),
    );
  }
}
