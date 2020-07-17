/**
 * 全局接口配置
 */
import 'package:flutter/material.dart';

var imgUrl = 'https://figure.kjwangluo.com';

enum Env {
  PROD,
  DEV,
  LOCAL,
}

class Config {
  static Env env;
  static Map get apiHost {
    switch (env) {
      case Env.PROD: // 生产
        return {
          "url": "https://bf.bamket.com",
          "tracker": "https://api.tracker.gg",
          "imgUrl": imgUrl + '/'
        };
      case Env.DEV:  // 开发
      case Env.LOCAL:
      default:
        return {
          "url": "localhost:8080",
          "imgUrl": imgUrl + '/'
        };
    }
  }

  static Map get game {
    return {
      "type": [
        {
          "name": "BF1",
          "img": {
            "file": "assets/images/edit/battlefield-1-logo.png",
            "network": "",
          }
        },
        {
          "name": "BFV",
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
      "aimbot": "自瞄",
      "wallhack": "透视",
      "oneShotKill": "秒杀",
      "damageChange": "改伤",
      "stealth": "隐身",
      "gadgetModify": "修改装备",
      "shootingThroughWalls": "子弹穿墙",
    };
  }

  static List<dynamic> get startusIng {
    return [
      {
        "s": "未处理",
        "t": "还未处理",
        "c": Colors.white70,
      },
      {
        "s": "作弊玩家",
        "t": "确定存在作弊行为",
        "c": Colors.red,
      },
      {
        "s": "待观察",
        "t": "存在嫌疑,待观察",
        "c": Colors.red,
      },
      {
        "s": "清白",
        "t": "最终判决没有作弊行为",
        "c": Colors.red,
      },
      {
        "s": "回收站",
        "t": "关闭的审核",
        "c": Colors.orangeAccent,
      },
      {
        "s": "讨论中",
        "t": "需继续讨论",
        "c": Colors.orangeAccent,
      }
    ];
  }
}