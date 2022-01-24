/// 引导
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:flutter_elui_plugin/elui.dart';

import 'package:bfban/utils/index.dart';

import 'agreement.dart';
import 'explain.dart';
import 'permission.dart';

class GuidePage extends StatefulWidget {
  @override
  _GuidePageState createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  final UrlUtil _urlUtil = UrlUtil();

  /// 是否同意条约
  bool guideAgreementIs = false;

  /// 引导下标
  int? guideListPageIndex = 0;

  /// 引导页面列表
  late List<Widget> guideListPage;

  @override
  void initState() {
    super.initState();

    guideListPage = [
      agreementPage(
        onChanged: (s) {
          setState(() {
            guideAgreementIs = s;
          });
        },
      ),
      const permissionPage(onChange: null,),
      explainPage(),
    ];
  }

  /// 动作
  void _onConfirm() async {
    if (guideListPageIndex == guideListPage.length - 1) {
      // 完成离开
      await Storage().set("com.bfban.guide", value: "1");

      _urlUtil.popPage(context);
      return;
    }

    setState(() {
      guideListPageIndex = (guideListPageIndex! + 1);
    });
  }

  /// 判决禁用状态
  bool _isState() {
    if (guideListPageIndex == 0 && guideAgreementIs) {
      return false;
    } else if (guideListPageIndex! >= 1) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: const Color(0xff111b2b),
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
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
                  "${guideListPageIndex == guideListPage.length - 1 ? "确认" : "下一步"} (${guideListPageIndex! + 1}/${guideListPage.length})",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                  ),
                ),
                Offstage(
                  offstage: !_isState(),
                  child: const Text(
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
