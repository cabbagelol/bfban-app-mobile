/// 状态管理 工具包

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../provider/appInfo_provider.dart';
import '../provider/userinfo_provider.dart';
import '../provider/message_provider.dart';

class ProviderUtil {
  // App 全局
  AppInfoProvider ofApp (BuildContext context) {
    return Provider.of<AppInfoProvider>(context, listen: false);
  }

  // 用户信息
  UserInfoProvider ofUser (BuildContext context) {
    return Provider.of<UserInfoProvider>(context, listen: false)..context = context;;
  }

  // 消息
  MessageProvider ofMessage (BuildContext context) {
    return Provider.of<MessageProvider>(context, listen: false);
  }
}