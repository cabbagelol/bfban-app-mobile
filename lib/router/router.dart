/// 应用路由

import 'dart:io';

import 'package:bfban/pages/detail/user_space.dart';
import 'package:bfban/pages/license/index.dart';
import 'package:bfban/pages/not_found/index.dart';
import 'package:bfban/pages/profile/account/change_password.dart';
import 'package:bfban/pages/profile/account/setuser_name.dart';
import 'package:bfban/pages/profile/setting/destock.dart';
import 'package:bfban/pages/profile/setting/language.dart';
import 'package:bfban/pages/profile/setting/notice.dart';
import 'package:bfban/pages/profile/setting/public_translator.dart';
import 'package:bfban/pages/profile/setting/setting.dart';
import 'package:fluro/fluro.dart';

// S Pages
import 'package:bfban/pages/guide/guide.dart';
import 'package:bfban/pages/detail/index.dart';
import 'package:bfban/pages/report/report.dart';
import 'package:bfban/pages/report/publish_results.dart';
import 'package:bfban/pages/detail/reply.dart';
import 'package:bfban/pages/index/index.dart';
import 'package:bfban/pages/report/judgement.dart';
import 'package:bfban/pages/login/signin.dart';
import 'package:bfban/pages/search/index.dart';
import 'package:bfban/pages/profile/support.dart';
import 'package:bfban/pages/profile/setting/theme.dart';
import 'package:bfban/pages/rich_edit/index.dart';
import 'package:bfban/pages/chat/chat_list.dart';
import 'package:bfban/pages/chat/chat_detail.dart';

import '../component/_customReply/customReplyEdit.dart';
import '../component/_customReply/customReplyList.dart';
import '../pages/camera/index.dart';
import '../pages/login/index.dart';
import '../pages/login/signup.dart';
import '../pages/media/Insert.dart';
import '../pages/media/dir_configuration.dart';
import '../pages/media/index.dart';
import '../pages/chat/index.dart';
import '../pages/profile/account/information.dart';
import '../pages/profile/app_network.dart';
import '../pages/profile/app_version_package.dart';
import '../pages/splash.dart';
// E Pages

class Routes {
  static FluroRouter? router;
  static List? routerList;

  static void configureRoutes(FluroRouter router) {
    routerList = [
      {
        "url": '/',
        "item": (context, params) {
          return const IndexPage();
        }
      },
      {
        "url": '/notfound',
        "item": (context, params) {
          return const NotFoundPage();
        }
      },
      {
        "url": '/splash',
        "item": (context, params) {
          return const SplashPage();
        }
      },
      {
        "url": '/network',
        "item": (context, params) {
          return const AppNetworkPage();
        }
      },
      {
        "url": "/chat/list",
        "item": (context, params) {
          return const ChatListPage();
        }
      },
      {
        "url": "/chat/:id",
        "item": (context, params) {
          return MessagePage(id: params["id"][0]);
        }
      },
      {
        "url": "/chat/detail/:id",
        "item": (context, params) {
          return ChatDetailPage(id: params["id"][0]);
        }
      },
      {
        "url": "/camera",
        "item": (context, params) {
          return const CameraPage();
        }
      },
      {
        "url": "/account/:id",
        "item": (context, params) {
          return UserSpacePage(id: params["id"][0]);
        }
      },
      {
        "url": "/account/information/",
        "item": (context, params) {
          return const InformationPage();
        }
      },
      {
        "url": "/account/information/setUserName",
        "item": (context, params) {
          return const setuserNamePage();
        }
      },
      {
        "url": "/account/information/changePassword",
        "item": (context, params) {
          return const changePasswordPage();
        }
      },
      {
        "url": "/account/media/",
        "item": (context, params) {
          return MediaPage();
        }
      },
      {
        "url": "/account/media/selectFile",
        "item": (context, params) {
          return MediaPage(isSelectFile: true);
        }
      },
      {
        "url": "/account/media/insert",
        "item": (context, params) {
          return const InsertMediaPage();
        }
      },
      {
        "url": "/profile/dir/configuration",
        "item": (context, params) {
          return const directoryConfigurationPage();
        },
      },
      {
        "url": "/player/dbId/:dbId",
        "item": (context, params) {
          return PlayerDetailPage(dbId: params["dbId"][0]);
        }
      },
      {
        "url": "/player/personaId/:personaId",
        "item": (context, params) {
          return PlayerDetailPage(personaId: params["personaId"][0]);
        }
      },
      {
        "url": "/report/:data",
        "item": (context, params) {
          return ReportPage(
            data: params["data"][0],
          );
        }
      },
      {
        "url": "/report/publish_results/:type",
        "item": (context, params) {
          return PublishResultsPage(
            type: params["type"][0],
          );
        }
      },
      {
        "url": "/report/manage/:id",
        "item": (context, params) {
          return JudgementPage(
            id: params["id"][0],
          );
        }
      },
      {
        "url": "/report/customReply/page",
        "item": (context, params) {
          return const CustomReplyListPage();
        }
      },
      {
        "url": "/report/customReply/edit/:data",
        "item": (context, params) {
          return CustomReplyEditPage(
            isEdit: true,
            data: params["data"][0],
          );
        }
      },
      {
        "url": "/report/customReply/add/",
        "item": (context, params) {
          return CustomReplyEditPage(
            isEdit: false,
          );
        }
      },
      {
        "url": "/reply/:id",
        "item": (context, params) {
          return ReplyPage(
            data: params["id"][0],
          );
        }
      },
      {
        "url": "/signin",
        "item": (context, params) {
          return const SigninPage();
        }
      },
      {
        "url": "/signup",
        "item": (context, params) {
          return const SignupPage();
        }
      },
      {
        "url": "/login/panel",
        "item": (context, params) {
          return const LoginPanelPage();
        }
      },
      {
        "url": "/search/:data",
        "item": (context, params) {
          return SearchPage(
            data: params["data"][0],
          );
        }
      },
      {
        "url": "/profile/language",
        "item": (context, params) {
          return const LanguagePage();
        },
      },
      {
        "url": "/profile/destock",
        "item": (context, params) {
          return const DestockPage();
        },
      },
      {
        "url": "/profile/setting",
        "item": (context, params) {
          return const SettingPage();
        },
      },
      {
        "url": "/profile/support",
        "item": (context, params) {
          return const SupportPage();
        },
      },
      {
        "url": "/profile/version",
        "item": (context, params) {
          return const AppVersionPackagePage();
        },
      },
      {
        "url": "/profile/theme",
        "item": (context, params) {
          return const ThemePage();
        },
      },
      {
        "url": "/profile/notice",
        "item": (context, params) {
          return const NoticePage();
        }
      },
      {
        "url": "/profile/translator",
        "item": (context, params) {
          return PublicTranslatorPage();
        }
      },
      {
        "url": "/guide",
        "item": (context, params) {
          return const GuidePage();
        },
      },
      {
        "url": "/richedit",
        "item": (context, params) {
          return const RichEditPage();
        },
      },
      {
        "url": "/license",
        "item": (context, params) {
          return const LicensePage();
        },
      },
    ];

    for (var i in routerList!) {
      router.define(i["url"], handler: Handler(handlerFunc: (context, Map<String, dynamic> params) {
        return i["item"](context, params);
      }));
    }

    Routes.router = router;
  }
}
