/// 应用路由

import 'package:fluro/fluro.dart';

// S Pages
import 'package:bfban/pages/network-result.dart';
import 'package:bfban/pages/guide/guide.dart';
import 'package:bfban/pages/detail/cheaters.dart';
import 'package:bfban/pages/edit/index.dart';
import 'package:bfban/pages/edit/publish-results.dart';
import 'package:bfban/pages/edit/reply.dart';
import 'package:bfban/pages/index/index.dart';
import 'package:bfban/pages/edit/drafts.dart';
import 'package:bfban/pages/edit/manage.dart';
import 'package:bfban/pages/login/index.dart';
import 'package:bfban/pages/login/record/index.dart';
import 'package:bfban/pages/search/searchList.dart';
import 'package:bfban/pages/usercenter/support.dart';
import 'package:bfban/pages/usercenter/theme.dart';
import 'package:bfban/pages/richEdit/index.dart';
// E Pages

class Routes {
  static FluroRouter router;
  static List routerList;

  static void configureRoutes(FluroRouter router) {
    routerList = [
      {
        'url': '/',
        'item': (context, params) {
          return IndexPage();
        }
      },
      {
        "url": "/detail/cheaters/:id",
        'item': (context, params) {
          return CheatersPage(id: params["id"][0]);
        }
      },
      {
        "url": "/edit/:data",
        'item': (context, params) {
          return editPage(
            data: params["data"][0],
          );
        }
      },
      {
        "url": "/edit/publishResultsPage",
        'item': (context, params) {
          return PublishResultsPage();
        }
      },
      {
        "url": "/edit/manage/:id",
        'item': (context, params) {
          return ManagePage(
            id: params["id"][0],
          );
        }
      },
      {
        "url": "/drafts",
        'item': (context, params) {
          return draftsPage();
        }
      },
      {
        "url": "/reply/:id",
        'item': (context, params) {
          return replyPage(
            data: params["id"][0],
          );
        }
      },
      {
        "url": "/login",
        'item': (context, params) {
          return loginPage();
        }
      },
      {
        "url": "/record/:data",
        'item': (context, params) {
          return recordPage(
            data: params["data"][0],
          );
        }
      },
      {
        "url": "/search/:data",
        'item': (context, params) {
          return SearchPage(
            data: params["data"][0],
          );
        }
      },
      {
        "url": "/usercenter/support",
        'item': (context, params) {
          return SupportPage();
        },
      },
      {
        "url": "/usercenter/theme",
        'item': (context, params) {
          return ThemePage();
        },
      },
      {
        "url": "/guide",
        'item': (context, params) {
          return guidePage();
        },
      },
      {
        "url": "/richedit/:data",
        'item': (context, params) {
          return richEditPage(
            data: params["data"][0],
          );
        },
      },
      {
        "url": "/network/:data",
        'item': (context, params) {
          return NetworkResultPage(
            data: params["data"][0],
          );
        },
      }
    ];

    routerList.forEach((i) {
      router.define(i['url'], handler: Handler(handlerFunc: (context, Map<String, dynamic> params) {
        return i['item'](context, params);
      }));
    });

    Routes.router = router;
  }
}
