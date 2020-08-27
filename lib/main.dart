/// 程序入口

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:bfban/utils/index.dart';
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
        ChangeNotifierProvider.value(
          value: AppInfoProvider(),
        ),
      ],
      child: Consumer<AppInfoProvider>(
          builder: (context, appInfo, _) {
            String colorKey = appInfo.themeColor;
            if (THEMELIST[colorKey] != null) {
              _theme = THEMELIST[colorKey]["data"];
            }

            return MaterialApp(
              theme: _theme,
              initialRoute: '/',
              onGenerateRoute: Routes.router.generator,
              routes: {
                '/': (context) =>
                    DefaultTextStyle(
                      child: IndexPage(),
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                      ),
                    ),
              },
              debugShowCheckedModeBanner: false,
            );
          }),
    );
  }
}

//class MyApp extends StatelessWidget {
//  Color _themeColor;
//
//  @override
//  Widget build(BuildContext context) {
//    return MultiProvider(
//      child: Consumer<AppInfoProvider>(
//        builder: (context, appInfo, _) {
//          String colorKey = appInfo.themeColor;
//          if (themeColorMap[colorKey] != null) {
//            _themeColor = themeColorMap[colorKey];
//          }
//          return MaterialApp(
//            title: 'Flutter Demo',
//            theme: ThemeData(
//              primaryColor: _themeColor,
//              floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: _themeColor),
//            ),
//            home: MyHomePage(title: 'Flutter Theme Change demo'),
//          );
//        },
//      ),
//    );
//  }
//}
