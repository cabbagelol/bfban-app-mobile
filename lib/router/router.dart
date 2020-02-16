import 'package:bfban/pages/index/home.dart';

/**
 * 应用路由
 */
import 'package:fluro/fluro.dart';

// pages
import 'package:bfban/pages/detail/cheaters.dart';
import 'package:bfban/pages/edit/index.dart';
import 'package:bfban/pages/login/index.dart';
import 'package:bfban/pages/login/record/index.dart';

class Routes {
  static Router router;
  static List routerList;

  static void configureRoutes(Router router) {
    routerList = [
      {
        'url': '/',
        'item': (context, params) {
          return homePage();
        }
      },
      {
        "url": "/detail/cheaters/:id",
        'item': (context, params) {
          return cheatersPage(id: params["id"][0]);
        }
      },
      {
        "url": "/edit",
        'item': (context, params) {
          return editPage();
        }
      },
      {
        "url": "/login",
        'item': (context, params) {
          return loginPage();
        }
      },
      {
        "url": "/record",
        'item': (context, params) {
          return recordPage();
        }
      },

    ];

    routerList.forEach((i) {
      router.define(i['url'],
          handler: Handler(handlerFunc: (context, Map<String, dynamic> params) {
            return i['item'](context, params);
          })
      );
    });

    Routes.router = router;
  }
}
