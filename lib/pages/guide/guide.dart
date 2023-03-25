/// 引导

import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

import 'package:bfban/utils/index.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'agreement.dart';
import 'language.dart';
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

  /// 引导页面列表
  late List<Widget> guideListPage = [
    GuideLanguagePage(
      onChanged: () {
        setState(() {
          // Update Widget, Run setState
        });
      },
    ),
    GuideAgreementPage(key: _agreementPageKey),
    const GuidePermissionPage(
      onChange: null,
    ),
    const GuideExplainPage(),
    const GuideLoginPage(),
  ];

  late final GlobalKey<AgreementPageState> _agreementPageKey = GlobalKey<AgreementPageState>();

  @override
  void initState() {
    super.initState();
  }

  /// [Event]
  /// 下一步
  _onNext() async {
    // 勾选
    bool isAgreement = _agreementPageKey.currentState?.checked ?? false;
    if (!isAgreement && guideListPageIndex == 1) return;

    // 完成离开
    if (guideListPageIndex == guideListPage.length - 1) {
      await Storage().set("guide", value: "1");

      _urlUtil.popPage(context);
      return;
    }

    setState(() {
      if (guideListPageIndex <= guideListPage.length - 1)
        guideListPageIndex+=1;
    });
  }

  /// [Event]
  /// 上一步
  _onBacktrack() async {
    if (guideListPageIndex <= 0) return;
    setState(() {
      guideListPageIndex-=1;
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
          duration: const Duration(milliseconds: 150),
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AnimatedOpacity(
                opacity: guideListPageIndex == 0 ? 0 : 1,
                duration: const Duration(milliseconds: 300),
                child: TextButton(
                  onPressed: _onBacktrack,
                  child: Text(FlutterI18n.translate(context, "basic.button.prev")),
                ),
              ),
              Text("${guideListPageIndex + 1} / ${guideListPage.length}"),
              ElevatedButton(
                onPressed: _onNext,
                child: guideListPageIndex + 1 < guideListPage.length ? Text(FlutterI18n.translate(context, "basic.button.next")) : Text(FlutterI18n.translate(context, "app.guide.endNext")),
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
