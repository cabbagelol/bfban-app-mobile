import 'package:bfban/provider/appInfo_provider.dart';
import 'package:bfban/provider/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../_notNetwork/index.dart';

class EmptyWidget extends StatelessWidget {
  final bool isChenkNetork;

  const EmptyWidget({
    Key? key,
    this.isChenkNetork = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppInfoProvider, ThemeProvider>(
      builder: (BuildContext context, AppInfoProvider appInfo, ThemeProvider themeInfo, Widget? child) {
        if (isChenkNetork && !appInfo.connectivity.isNetwork) {
          return Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(vertical: 20),
            child: const Center(
              child: notNetworkWidget(),
            ),
          );
        }

        return Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.symmetric(vertical: 20),
          child: Opacity(
            opacity: .6,
            child: Column(
              children: [
                SvgPicture.asset("assets/images/empty_${themeInfo.currentThemeData.brightness.name}.svg"),
                SizedBox(height: 8),
                Text(FlutterI18n.translate(context, "basic.tip.notContent")),
              ],
            ),
          ),
        );
      },
    );
  }
}
