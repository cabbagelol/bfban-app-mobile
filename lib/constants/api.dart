/// 全局接口配置

import 'package:flutter/material.dart';

enum Env {
  PROD,
  DEV,
  LOCAL,
}

class Config {
  static Env env = Env.DEV;

  static Map get jiguan {
    return {
      "appKey": "966c3770c8bb47ffcbaacff1",
      "channel": "developer-default",
    };
  }

  /// 基础请求
  static Map get apiHost {
    Map d = {
      "none": "",
      "sentry": "https://475f587d2c9a44f38cbe58978c0429c7@o438603.ingest.sentry.io/5403628",

      // BFBAN 主站
      "web_site": "https://bfban.gametools.network",

      // BFBAN APP 网站
      "app_web_site": "https://bfban-app.cabbagelol.net",
    };

    switch (env) {
      case Env.PROD: // 生产
        d.addAll({
          "network_service_request": "https://bd37-113-78-165-215.ap.ngrok.io/api",
        });
        return d;
      case Env.DEV: // 开发
      case Env.LOCAL:
      default:
        d.addAll({
          "network_service_request": "https://bfban.gametools.network/api",
        });
        return d;
    }
  }

  /// 游戏类型
  /// base 配置, 会被远程覆盖
  static Map game = {"child": []};
  static Map privilege = {};
  static Map cheatMethodsGlossary = {};
  static Map cheaterStatus = {};
  static Map action = {};

  /// 请求接口
  /// 参考 bfban.com项目内置的util/api.js
  static Map get httpHost {
    Map list = {
      'search': 'search',
      'player': 'player',
      'captcha': 'captcha',
      'statistics': 'statistics',
      'playerStatistics': 'playerStatistics',
      'users': 'users',
      'players': 'players',
      'user_info': 'user/info',
      'user_me': 'user/me',
      'player_judgement': 'player/judgement',
      'user_forgetPassword': 'user/forgetPassword', // 重置请求
      'user_forgetPasswordVerify': 'user/forgetPasswordVerify', // 重置密码验证
      'activities': 'activities',
      'user_bindOrigin': 'user/bindOrigin', // 绑定🍊
      'user_bindOriginVerify': 'user/bindOriginVerify', // 🍊验证
      'user_message': 'message',
      'user_message_mark': 'message/mark',
      'user_reports': 'user/reports',
      'user_changePassword': 'user/changePassword', // 修改密码
      'user_changeName': 'user/changeName', // 修改名称
      'player_banAppeal': "player/banAppeal", // 申诉
      'player_viewBanAppeal': "player/viewBanAppeal",
      'player_unreply': 'player/unreply', // 删除回复
      'player_reply': 'player/reply', // 回复
      'player_report': 'player/report',
      'player_update': 'player/update',
      'player_reset': 'reset',
      'account_timeline': 'player/timeline',
      'account_signout': 'user/signout',
      'account_signin': 'user/signin',
      'account_signup': 'user/signup',
      'account_signupVerify': 'user/signupVerify',
    };

    return list;
  }

  static Map<String, String> get cheatingTpyes {
    return {
      "aimbot": "\u81ea\u7784",
      "wallhack": "\u900f\u89c6",
      "oneShotKill": "\u79d2\u6740",
      "damageChange": "\u6539\u4f24",
      "stealth": "\u9690\u8eab",
      "gadgetModify": "\u4fee\u6539\u88c5\u5907",
      "shootingThroughWalls": "\u5b50\u5f39\u7a7f\u5899",
    };
  }

  static Map get usetIdentity {
    return {
      "admin": ["\u7ba1\u7406\u5458", Colors.white, Colors.redAccent],
      "normal": ["\u73a9\u5bb6", Colors.black, Colors.amber],
      "super": ["\u8d85\u7ba1", Colors.white, Colors.blueAccent],
      "": ["\u672a\u77e5", Colors.black, Colors.white12],
    };
  }
}
