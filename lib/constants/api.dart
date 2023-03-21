/// 全局接口配置

enum Env { PROD, DEV }

class Config {
  static Env env = Env.DEV;
  static Map apis = {};

  static Map get jiguan {
    return {
      "appKey": "966c3770c8bb47ffcbaacff1",
      "channel": "developer-default",
    };
  }

  /// 基础请求
  static Map get apiHost {
    Map d = {"none": ""};
    d.addAll(apis);
    return d;
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
      'players': 'players',
      'activities': 'activities',
      'users': 'users',
      'user_info': 'user/info',
      'user_me': 'user/me',
      'user_forgetPassword': 'user/forgetPassword',
      'user_forgetPasswordVerify': 'user/forgetPasswordVerify',
      'user_bindOrigin': 'user/bindOrigin',
      'user_bindOriginVerify': 'user/bindOriginVerify',
      'user_message': 'message',
      'user_message_mark': 'message/mark',
      'user_reports': 'user/reports',
      'user_changePassword': 'user/changePassword',
      'user_changeName': 'user/changeName',
      'player_judgement': 'player/judgement',
      'player_banAppeal': "player/banAppeal",
      'player_viewBanAppeal': "player/viewBanAppeal",
      'player_unreply': 'player/unreply',
      'player_reply': 'player/reply',
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

  Config.dev({required Map api}) {
    Config.apis.addAll(api);
    env = Env.DEV;
  }

  Config.prod({required Map api}) {
    Config.apis.addAll(api);
    env = Env.PROD;
  }
}
