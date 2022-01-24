/// 协议内容

import 'package:flutter/material.dart';

import 'package:flutter_elui_plugin/elui.dart';

class agreementPage extends StatefulWidget {
  final Function onChanged;

  agreementPage({
    required this.onChanged,
  });

  @override
  _agreementPageState createState() => _agreementPageState();
}

class _agreementPageState extends State<agreementPage> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Image.asset(
          "assets/images/bfban-logo.png",
          width: 60,
          height: 60,
        ),
        SizedBox(
          height: 40,
        ),
        EluiCellComponent(
          theme: EluiCellTheme(
            backgroundColor: Colors.black12,
            titleColor: Colors.white,
          ),
          title: "\u4f7f\u7528\u7ea6\u5b9a",
          cont: Container(
            width: MediaQuery.of(context).size.width * .7,
            child: Text(
              "使用约定是开源库所有参与者对使用者约定, 它不具有法律有效性，但声明表示着您已知该情况，了解程序无法提供任何责任，由使用承担；" +
                  "程序并非BFBAN官方程序所开发，由Github用户参与，整合不同功能，因此涉及不同第三方服务商信息交换（仅与列出通信名单交换信息，可" +
                  "在我的中心 > 支援查看），程序无法控制服务提供商，可能收集用户信息作其他用途。\t该程序账户引用'bfban.com'正常途径接口。所有代码" +
                  "都可在github/BFBAN地址上，任何人都可以查阅是否存在恶意行为。",
              style: TextStyle(
                color: Colors.white54,
              ),
            ),
          ),
        ),
        EluiCellComponent(
          theme: EluiCellTheme(
            backgroundColor: Colors.black12,
            titleColor: Colors.white,
          ),
          title: "\u6ce8\u518c\u65b9\u5f0f",
          cont: Container(
            width: MediaQuery.of(context).size.width * .7,
            child: Text(
              "程序不提供注册，请用户到bfban.com上自行注册",
              style: TextStyle(
                color: Colors.white54,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 50,
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
          ),
          child: EluiCheckboxComponent(
            color: Colors.yellow,
            child: Text(
              "\u5df2\u9605\u8bfb\u4e0a\u65b9\u5185\u5bb9",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onChanged: (s) => widget.onChanged(s),
          ),
        ),
      ],
    );
  }
}
