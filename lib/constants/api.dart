/**
 * 全局接口配置
 */

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
}