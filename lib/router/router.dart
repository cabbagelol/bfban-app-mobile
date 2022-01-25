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
import '../pages/my/app_network.dart';
import '../pages/my/app_package.dart';
// E Pages

class Routes {
  static FluroRouter? router;
  static List? routerList;

  static void configureRoutes(FluroRouter router) {
    routerList = [
      {
        'url': '/',
        'item': (context, params) {
          return const IndexPage();
        }
      },
      {
        'url': '/network',
        'item': (context, params) {
          return const AppNetworkPage();
        }
      },
      {
        "url": "/message/list",
        'item': (context, params) {
          return const MessageListPage();
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
          return const CameraPage();
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
          return const PublishResultsPage();
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
          return const draftsPage();
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
          return const SigninPage();
        }
      },
      {
        "url": "/signup",
        'item': (context, params) {
          return const SignupPage();
        }
      },
      {
        "url": "/login/panel",
        'item': (context, params) {
          return const LoginPanelPage();
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
          return const SupportPage();
        },
      },
      {
        "url": "/my/version",
        'item': (context, params) {
          return const AppPackagePage();
        },
      },
      {
        "url": "/my/theme",
        'item': (context, params) {
          return const ThemePage();
        },
      },
      {
        "url": "/guide",
        'item': (context, params) {
          return const GuidePage();
        },
      },
      {
        "url": "/richedit",
        'item': (context, params) {
          print(params);
          return const RichEditPage();
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

    for (var i in routerList!) {
      router.define(i['url'], handler: Handler(handlerFunc: (context, Map<String, dynamic> params) {
        return i['item'](context, params);
      }));
    }

    Routes.router = router;
  }
}
