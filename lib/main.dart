/// 程序入口

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:bfban/router/router.dart';
import 'package:bfban/pages/index/index.dart';
import 'package:bfban/constants/theme.dart';
import 'package:bfban/utils/provider.dart';

class MyApp extends StatelessWidget {
  ThemeData _theme;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: AppInfoProvider()),
      ],
      child: Consumer<AppInfoProvider>(
        builder: (context, appInfo, child) {
          String colorKey = appInfo.themeColor;

          if (THEMELIST[colorKey] != null) {
            _theme = THEMELIST[colorKey]["data"];
          }

          return MaterialApp(
            theme: _theme ?? THEMELIST["none"]["data"],
            initialRoute: '/',
            onGenerateRoute: Routes.router.generator,
            routes: {
              '/': (context) => child,
            },
            debugShowCheckedModeBanner: false,
          );
        },
        child: IndexPage(),
      ),
    );
  }
}