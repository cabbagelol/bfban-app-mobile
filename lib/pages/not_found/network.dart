import 'package:bfban/component/_notNetwork/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/index.dart';

class notNetworkPage extends StatefulWidget {
  const notNetworkPage();

  @override
  State<notNetworkPage> createState() => _notNetworkPageState();
}

class _notNetworkPageState extends State<notNetworkPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppInfoProvider>(
      builder: (context, appData, child) {
        return Scaffold(
          appBar: AppBar(),
          body: const Center(
            child: notNetworkWidget(),
          ),
        );
      },
    );
  }
}
