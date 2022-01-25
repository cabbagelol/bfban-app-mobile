/// 全局接口配置

import 'package:flutter/material.dart';

enum Env {
  PROD,
  DEV,
  LOCAL,
}

class Config {
  static Env env = Env.DEV;

  /// 版本设置
  static Map get versionApp {
    return {
      "v": "0.1.0",
      "s": "beta",
    };
  }

  /// 基础请求
  static Map get apiHost {
    Map d = {
      "none": "",
      "sentry":
          "https://475f587d2c9a44f38cbe58978c0429c7@o438603.ingest.sentry.io/5403628",
      "web_site": "https://bfban-app.cabbagelol.net/",
      // "tracker": "https://api.tracker.gg",
      // "upload": "https://upload-z2.qiniup.com",
      // "qiniuyunSrc": "http://bfban.bamket.com",

      // # NOT USE
      "gametools": "https://bfban.gametools.network",
      "image_service_1":"https://imagedelivery.net",
      "bfban_web_site": "http://101.43.35.41:84",
    };

    switch (env) {
      case Env.PROD: // 生产
        d.addAll({
          "url": "http://101.43.35.41:3000/api/",
        });
        return d;
      case Env.DEV: // 开发
      case Env.LOCAL:
      default:
        d.addAll({
          "url": "https://bfban.gametools.network",
        });
        return d;
    }
  }

  /// 游戏类型
  static Map get game {
    return {
      "type": [
        {
          "name": "\u6218\u5730\u0031",
          "value": "bf1",
          "img": {
            "file": "assets/images/report/battlefield-1-logo.png",
            "network": "",
          }
        },
        {
          "name": "\u6218\u5730\u0056",
          "value": "bfv",
          "img": {
            "file": "assets/images/report/battlefield-v-png-logo.png",
            "network": "",
          }
        },
        {
          "name": "战地风云2042",
          "value": "bf6",
          "img": {
            "file": "assets/images/report/battlefield-v-png-logo.png",
            "network": "",
          }
        },
      ]
    };
  }

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

    name(String name) {
      return list[name];
    }

    return list;
  }

  /// 贴纸状态类型
  static List get cheaterStatus {
    return [
      {
        "value": -1,
        "values": [-1]
      },
      {
        "value": 0,
        "values": ["0", "wallhack"]
      },
      {
        "value": 5,
        "values": ["5", "gadgetModify", "suspect"]
      },
      {
        "value": 6,
        "values": ["6", "teleport"]
      },
      {
        "value": 1,
        "values": ["1", "guilt"],
        "action": "guilt"
      },
      {
        "value": 2,
        "values": ["2", "invisable", "discuss"],
        "action": "discuss"
      },
      {
        "value": 3,
        "values": ["3", "magicBullet", "innocent"],
        "action": "innocent"
      },
      {
        "value": 4,
        "values": ["4", "damageChange", "trash"],
        "action": "suspect"
      }
    ];
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

  static Map get startusIng {
    return {
      -1: {
        "s": "全部",
        "t": "",
        "c": Colors.lightBlueAccent,
        "tc": Colors.white,
        "value": -1,
      },
      0: {
        "s": "\u672a\u5904\u7406",
        "t": "\u8fd8\u672a\u5904\u7406",
        "c": Colors.lightBlueAccent,
        "tc": Colors.white,
        "value": 0,
      },
      1: {
        "s": "\u4f5c\u5f0a\u73a9\u5bb6",
        "t": "\u786e\u5b9a\u5b58\u5728\u4f5c\u5f0a\u884c\u4e3a",
        "c": Colors.red,
        "tc": Colors.white,
        "value": 1,
      },
      2: {
        "s": "\u5f85\u89c2\u5bdf",
        "t": "\u5b58\u5728\u5acc\u7591\u002c\u5f85\u89c2\u5bdf",
        "c": Colors.orangeAccent,
        "tc": Colors.white,
        "value": 2,
      },
      3: {
        "s": "\u6e05\u767d",
        "t": "\u6700\u7ec8\u5224\u51b3\u6ca1\u6709\u4f5c\u5f0a\u884c\u4e3a",
        "c": Colors.green,
        "tc": Colors.white,
        "value": 3,
      },
      4: {
        "s": "\u56de\u6536\u7ad9",
        "t": "\u5173\u95ed\u7684\u5ba1\u6838",
        "c": Colors.black38,
        "tc": Colors.white,
        "value": 4,
      },
      5: {
        "s": "\u8ba8\u8bba\u4e2d",
        "t": "\u9700\u7ee7\u7eed\u8ba8\u8bba",
        "c": Colors.orange,
        "tc": Colors.white,
        "value": 5,
      },
      6: {
        "s": "\u5f85\u786e\u8ba4",
        "t": "\u7b49\u5f85\u7ba1\u7406\u786e\u8ba4",
        "c": Colors.orange,
        "tc": Colors.white,
        "value": 6,
      }
    };
  }
}
