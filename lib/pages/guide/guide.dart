/// 引导

import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

import 'package:bfban/utils/index.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'agreement.dart';
import 'explain.dart';
import 'login.dart';
import 'permission.dart';

class GuidePage extends StatefulWidget {
  const GuidePage({Key? key}) : super(key: key);

  @override
  _GuidePageState createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  final UrlUtil _urlUtil = UrlUtil();

  /// 引导下标
  int guideListPageIndex = 0;

  /// 是否同意条约
  bool guideAgreementIs = false;

  /// 引导页面列表
  late List<Widget> guideListPage = [];

  @override
  void initState() {
    super.initState();

    guideListPage = [
      GuideAgreementPage(
        onChanged: (checked) {
          setState(() {
            guideAgreementIs = checked;
          });
        },
      ),
      GuideLoginPage(),
      const GuidePermissionPage(
        onChange: null,
      ),
      const GuideExplainPage(),
    ];
  }

  /// [Event]
  /// 下一步
  _onNext() async {
    // 勾选
    if (!guideAgreementIs) return;

    // 完成离开
    if (guideListPageIndex == guideListPage.length - 1) {
      await Storage().set("com.bfban.guide", value: "1");

      _urlUtil.popPage(context);
      return;
    }

    setState(() {
      guideListPageIndex++;
    });
  }

  /// [Event]
  /// 上一步
  _onBacktrack() async {
    if (guideListPageIndex <= 0) return;
    setState(() {
      guideListPageIndex--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
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
        body: PageTransitionSwitcher(
          duration: Duration(milliseconds: 150),
          transitionBuilder: (Widget child, Animation<double> primaryAnimation, Animation<double> secondaryAnimation) {
            return SharedAxisTransition(
              fillColor: Theme.of(context).scaffoldBackgroundColor,
              animation: primaryAnimation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.horizontal,
              child: child,
            );
          },
          child: guideListPage[guideListPageIndex],
        ),
        bottomSheet: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AnimatedOpacity(
                opacity: guideListPageIndex == 0 ? 0 : 1,
                duration: Duration(milliseconds: 300),
                child: TextButton(
                  onPressed: _onBacktrack,
                  child: Text(translate("guide.back")),
                ),
              ),
              Text("${guideListPageIndex + 1} / ${guideListPage.length}"),
              ElevatedButton(
                onPressed: _onNext,
                child: guideListPageIndex + 1 < guideListPage.length ? Text(translate("guide.next")) : Text(translate("guide.endNext")),
              ),
            ],
          ),
        ),
      ),
      onWillPop: () async {
        return false;
      },
    );
  }
}
