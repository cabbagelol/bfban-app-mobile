import 'package:bfban/provider/appInfo_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

import '../_notNetwork/index.dart';

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppInfoProvider>(builder: (BuildContext context, AppInfoProvider appInfo, Widget? child) {
      if (!appInfo.connectivity.isNetwork) {
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
        child: I18nText("basic.tip.notContent"),
      );
    });
  }
}
