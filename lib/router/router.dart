/// 应用路由

import 'package:bfban/pages/detail/user_space.dart';
import 'package:fluro/fluro.dart';

// S Pages
import 'package:bfban/pages/network-result.dart';
import 'package:bfban/pages/guide/guide.dart';
import 'package:bfban/pages/detail/index.dart';
import 'package:bfban/pages/report/report.dart';
import 'package:bfban/pages/report/publish_results.dart';
import 'package:bfban/pages/report/reply.dart';
import 'package:bfban/pages/index/index.dart';
import 'package:bfban/pages/report/drafts.dart';
import 'package:bfban/pages/report/manage.dart';
import 'package:bfban/pages/login/signin.dart';
import 'package:bfban/pages/login/record/index.dart';
import 'package:bfban/pages/search/index.dart';
import 'package:bfban/pages/my/support.dart';
import 'package:bfban/pages/my/theme.dart';
import 'package:bfban/pages/rich_edit/index.dart';
import 'package:bfban/pages/message/message_list.dart';
import 'package:bfban/pages/message/message_detail.dart';

import '../pages/camera/index.dart';
import '../pages/login/index.dart';
import '../pages/login/signup.dart';
import '../pages/message/index.dart';
// E Pages

class Routes {
  static FluroRouter? router;
  static List? routerList;

  static void configureRoutes(FluroRouter router) {
    routerList = [
      {
        'url': '/',
        'item': (context, params) {
          return IndexPage();
        }
      },
      {
        "url": "/message/list",
        'item': (context, params) {
          return MessageListPage();
        }
      },
      {
        "url": "/message/:id",
        'item': (context, params) {
          return MessagePage(id: params["id"][0]);
        }
      },
      {
        "url": "/message/detail/:id",
        'item': (context, params) {
          return MessageDetailPage(id: params["id"][0]);
        }
      },
      {
        "url": "/camera",
        'item': (context, params) {
          return CameraPage();
        }
      },
      {
        "url": "/detail/user/:id",
        'item': (context, params) {
          return UserSpacePage(id: params["id"][0]);
        }
      },
      {
        "url": "/detail/player/:id",
        'item': (context, params) {
          return PlayerDetailPage(id: params["id"][0]);
        }
      },
      {
        "url": "/report/:data",
        'item': (context, params) {
          return ReportPage(
            data: params["data"][0],
          );
        }
      },
      {
        "url": "/report/publishResultsPage",
        'item': (context, params) {
          return PublishResultsPage();
        }
      },
      {
        "url": "/report/manage/:id",
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
          return ReplyPage(
            data: params["id"][0],
          );
        }
      },
      {
        "url": "/signin",
        'item': (context, params) {
          return SigninPage();
        }
      },
      {
        "url": "/signup",
        'item': (context, params) {
          return SignupPage();
        }
      },
      {
        "url": "/login/panel",
        'item': (context, params) {
          return LoginPanelPage();
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
        "url": "/my/support",
        'item': (context, params) {
          return SupportPage();
        },
      },
      {
        "url": "/my/theme",
        'item': (context, params) {
          return ThemePage();
        },
      },
      {
        "url": "/guide",
        'item': (context, params) {
          return GuidePage();
        },
      },
      {
        "url": "/richedit",
        'item': (context, params) {
          print(params);
          return RichEditPage();
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

    routerList!.forEach((i) {
      router.define(i['url'], handler: Handler(handlerFunc: (context, Map<String, dynamic> params) {
        return i['item'](context, params);
      }));
    });

    Routes.router = router;
  }
}
