/**
 * 程序入口
 */

import 'package:flutter/material.dart';

import 'package:bfban/utils/index.dart';
import 'package:bfban/router/router.dart';
import 'package:bfban/constants/index.dart';
import 'package:bfban/pages/index/index.dart';
import 'package:bfban/constants/config.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var config = AppConfig.of(context);

    CountModel countModel = CountModel();

    return ScopedModel<CountModel>(
        model: countModel,
        child: MaterialApp(
            theme: ThemeData(
                primaryColor: Colors.blueGrey,
                accentColor: Color(0xfff2f2f2)
            ),
            initialRoute: '/',
            onGenerateRoute: Routes.router.generator,
            routes: {
              '/': (context) => DefaultTextStyle(
                  child: HomePage(), style: KfontConstant.defaultStyle),
            },
            debugShowCheckedModeBanner: config.debug??false
        )
    );
  }
}