/// 引导
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:flutter_plugin_elui/elui.dart';

import 'package:bfban/utils/index.dart';
import 'package:provider/provider.dart';

import 'agreement.dart';
import 'explain.dart';
import 'permission.dart';

class guidePage extends StatefulWidget {
  @override
  _guidePageState createState() => _guidePageState();
}

class _guidePageState extends State<guidePage> {
  bool guideAgreementIs = false;

  num guideListPageIndex = 0;

  List<Widget> guideListPage;

  @override
  void initState() {
    super.initState();

    guideListPage = [
      agreementPage(
        onChanged: (s) {
          setState(() {
            this.guideAgreementIs = s;
          });
        },
      ),
      permissionPage(),
      explainPage(),
    ];
  }

  /// 动作
  void _onConfirm() {
    if (guideListPageIndex == guideListPage.length - 1) {
      Storage.set("com.bfban.guide", value: "0");

      Provider.of<AppInfoProvider>(context, listen: false).setGuideNumberState(1);
      return;
    }

    setState(() {
      guideListPageIndex++;
    });
  }

  /// 判决禁用状态
  bool _isState() {
    if (guideListPageIndex == 0 && guideAgreementIs) {
      return false;
    } else if (guideListPageIndex >= 1) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: Color(0xff111b2b),
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomRight,
                colors: [Colors.transparent, Colors.black38],
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            // Opacity(
            //   opacity: 0.5,
            //   child: Image.asset(
            //     "assets/images/bk-companion-1.jpg",
            //     fit: BoxFit.cover,
            //   ),
            // ),
            BackdropFilter(
              child: IndexedStack(
                index: guideListPageIndex,
                children: guideListPage,
              ),
              filter: ui.ImageFilter.blur(
                sigmaX: 0.0,
                sigmaY: 0.0,
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          color: Colors.yellow,
          height: 50,
          child: EluiButtonComponent(
            disabled: _isState(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "${guideListPageIndex == guideListPage.length - 1 ? "确认" : "下一步"} (${guideListPageIndex + 1}/${guideListPage.length})",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                  ),
                ),
                Offstage(
                  offstage: !_isState(),
                  child: Text(
                    "请勾选必要条件",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),
            onTap: () => _onConfirm(),
          ),
        ),
      ),
      onWillPop: () async {
        return false;
      },
    );
  }
}
