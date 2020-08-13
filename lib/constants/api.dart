/// 全局接口配置

import 'package:flutter/material.dart';

var imgUrl = 'https://figure.kjwangluo.com';

enum Env {
  PROD,
  DEV,
  LOCAL,
}

class Config {
  static Env env;

  /// 版本设置
  static Map get versionApp {
    return {
      "v": "0.0.3",
      "s": "release",
    };
  }

  static Map get apiHost {
    Map d = {
      "app": "https://app.bfban.com",
      "tracker": "https://api.tracker.gg",
      "upload": "https://upload-z2.qiniup.com",
      "qiniuyunSrc": "http://bfban.bamket.com",
      "imgUrl": imgUrl + '/'
    };

    switch (env) {
      case Env.PROD: // 生产
        d.addAll({
          "url": "https://bf.bamket.com",
        });
        return d;
      case Env.DEV: // 开发
      case Env.LOCAL:
      default:
        d.addAll({
          "url": "localhost:8080",
        });
        return d;
    }
  }

  static Map get game {
    return {
      "type": [
        {
          "name": "\u6218\u5730\u0031",
          "value": "bf1",
          "img": {
            "file": "assets/images/edit/battlefield-1-logo.png",
            "network": "",
          }
        },
        {
          "name": "\u6218\u5730\u0056",
          "value": "bfv",
          "img": {
            "file": "assets/images/edit/battlefield-v-png-logo.png",
            "network": "",
          }
        },
      ]
    };
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

  static List<dynamic> get startusIng {
    return [
      {
        "s": "\u672a\u5904\u7406",
        "t": "\u8fd8\u672a\u5904\u7406",
        "c": Colors.white70,
        "value": 0,
      },
      {
        "s": "\u4f5c\u5f0a\u73a9\u5bb6",
        "t": "\u786e\u5b9a\u5b58\u5728\u4f5c\u5f0a\u884c\u4e3a",
        "c": Colors.red,
        "value": 1,
      },
      {
        "s": "\u5f85\u89c2\u5bdf",
        "t": "\u5b58\u5728\u5acc\u7591\u002c\u5f85\u89c2\u5bdf",
        "c": Colors.orangeAccent,
        "value": 2,
      },
      {
        "s": "\u6e05\u767d",
        "t": "\u6700\u7ec8\u5224\u51b3\u6ca1\u6709\u4f5c\u5f0a\u884c\u4e3a",
        "c": Colors.green,
        "value": 3,
      },
      {
        "s": "\u56de\u6536\u7ad9",
        "t": "\u5173\u95ed\u7684\u5ba1\u6838",
        "c": Colors.black38,
        "value": 4,
      },
      {
        "s": "\u8ba8\u8bba\u4e2d",
        "t": "\u9700\u7ee7\u7eed\u8ba8\u8bba",
        "c": Colors.orange,
        "value": 5,
      },
      {
        "s": "\u5f85\u786e\u8ba4",
        "t": "\u7b49\u5f85\u7ba1\u7406\u786e\u8ba4",
        "c": Colors.orange,
        "value": 6,
      }
    ];
  }
}
