/// 全局接口配置
import '../data/Url.dart';

enum Env { PROD, DEV }

class Config {
  static Env env = Env.DEV;
  static final List _envStringNames = ["production", "development"];
  static String _envCurrentStringName = "";
  static Map<String, BaseUrl> apis = {};

  /// 当前环境名称
  /// [_envStringNames] 所有
  static String get envCurrentName => _envCurrentStringName;

  static BaseUrl apiUpload = BaseUrl(
    protocol: BaseUrlProtocol.HTTPS,
    host: "bfban.gametools.network",
    pathname: "/api/",
  );

  /// 基础请求
  static Map<String, BaseUrl> get apiHost {
    Map<String, BaseUrl> d = {"none": BaseUrl()};
    d.addAll(apis);
    return d;
  }

  /// 游戏类型
  /// base 配置, 会被远程覆盖
  static Map game = {"child": []};
  static Map achievements = {};
  static Map privilege = {};
  static Map cheatMethodsGlossary = {};
  static Map cheaterStatus = {};
  static Map action = {};
  static Map recordLink = {};

  /// 请求接口
  /// 参考 bfban.com项目内置的util/api.js
  static Map get httpHost {
    Map list = {
      "siteStats": "siteStats",
      "admins": "admins",
      "search": "search",
      "cheaters": "player",
      "captcha": "captcha",
      "statistics": "statistics",
      "playerStatistics": "playerStatistics",
      "users": "users",
      "players": "players",
      "activity": "activities",
      "activeStatistical": "activeStatistical",
      "trend": "trend",
      "user_message": "message",
      "user_message_mark": "message/mark",
      "user_info": "user/info",
      "user_info4admin": "user/info4admin",
      "user_me": "user/me",
      "user_subscribes": "user/subscribes",
      "user_subscribes_delete": "user/subscribes/delete",
      "user_subscribes_add": "user/subscribes/add",
      "user_isSubscribes": "user/isSubscribes",
      "user_forgetPassword": "user/forgetPassword",
      "user_forgetPasswordVerify": "user/forgetPasswordVerify",
      "user_bindOrigin": "user/bindOrigin",
      "user_bindOriginVerify": "user/bindOriginVerify",
      "user_reports": "user/reports",
      "user_changePassword": "user/changePassword",
      "user_changeName": "user/changeName",
      "account_signout": "user/signout",
      "account_signin": "user/signin",
      "account_signup": "user/signup",
      "account_signupVerify": "user/signupVerify",
      "account_signup4dev": "user/signup4dev",
      "account_achievements": "user/achievements",
      "account_achievement": "user/achievement",
      "account_achievement_add": "user/achievement/admin/add",
      "account_achievement_delete": "user/achievement/admin/delete",
      "player_reset": "reset",
      "player_batch": "player/batch",
      "player_judgement": "player/judgement",
      "player_judgmentResult": "player/judgmentResult",
      "player_banAppeal": "player/banAppeal",
      "player_viewBanAppeal": "player/viewBanAppeal",
      "player_unReply": "player/unReply",
      "player_reply": "player/reply",
      "player_report": "player/report",
      "player_reportById": "player/reportById",
      "player_update": "player/update",
      "player_viewed": "player/viewed",
      "player_timeline": "player/timeline",
      "player_timeline_item": "player/timeline/item",
      "service_myStorageQuota": "service/myStorageQuota",
      "service_myFiles": "service/myFiles",
      "service_file": "service/file",
      "service_files": "service/files",
      "service_upload": "service/upload",
      "service_uploadBigFile": "service/uploadBigFile",
      "admin_searchUser": "admin/searchUser",
      "admin_setComment": "admin/setComment",
      "admin_commentAll": "admin/commentAll",
      "admin_setUser": "admin/setUser",
      "admin_setAppeal": "admin/setAppeal",
      "admin_setUserAttr": "admin/setUserAttr",
      "admin_msGraphStatus": "admin/msGraphStatus",
      "admin_msGraphInit": "admin/msGraphInit",
      "admin_msGraphAuthCode": "admin/msGraphAuthCode",
      "admin_addUser": "admin/addUser",
      "admin_delUser": "admin/delUser",
      "admin_judgementLog": "admin/judgementLog",
      "admin_chatLog": "admin/chatLog",
      "admin_userOperationLogs": "admin/userOperationLogs",
      "admin_adminLog": "admin/adminLog",
      "admin_muteUser": "admin/muteUser",
      "admin_muteUsers": "admin/muteUsers",
      "admin_muteUserAll": "admin/muteUserAll",
      "admin_verifications": "admin/verifications",
      "admin_blockedUserAll": "admin/blockedUserAll",
      "admin_CommentTypeList": "admin/CommentTypeList"
    };

    return list;
  }

  Config.dev({required Map<String, BaseUrl> api, BaseUrl? apiUpload}) {
    Config.apis.addAll(api);
    if (apiUpload!.host!.isNotEmpty) Config.apiUpload = apiUpload;
    Config.env = Env.DEV;
    Config._envCurrentStringName = _envStringNames[Config.env.index];
  }

  // <String, BaseUrl>
  Config.prod({required Map<String, BaseUrl> api, BaseUrl? apiUpload}) {
    Config.apis.addAll(api);
    if (apiUpload!.host!.isNotEmpty) Config.apiUpload = apiUpload;
    Config.env = Env.PROD;
    Config._envCurrentStringName = _envStringNames[Config.env.index];
  }
}
