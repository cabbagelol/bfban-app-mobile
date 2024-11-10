import 'package:bfban/component/_html/htmlLink.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';

import '../../provider/appInfo_provider.dart';

class notNetworkWidget extends StatelessWidget {
  const notNetworkWidget();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppInfoProvider>(builder: (context, appData, child) {
      return Column(
        children: [
          Icon(Icons.error, size: FontSize.xxLarge.value),
          const SizedBox(height: 15),
          Text(appData.connectivity.currentAppNetwork.toString()),
          HtmlLink(url: "https://cabbagelol.github.io/bfban-app-mobile-docs/"),
        ],
      );
    });
  }
}
