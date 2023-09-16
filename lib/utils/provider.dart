/// 状态管理 工具包

import 'package:bfban/provider/dir_provider.dart';
import 'package:bfban/provider/package_provider.dart';
import 'package:bfban/provider/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../provider/appInfo_provider.dart';
import '../provider/userinfo_provider.dart';
import '../provider/chat_provider.dart';
import '../provider/translation_provider.dart';

class ProviderUtil {
  // App 全局
  AppInfoProvider ofApp(BuildContext context) {
    return Provider.of<AppInfoProvider>(context, listen: false);
  }

  // 国际化
  TranslationProvider ofLang(BuildContext context) {
    return Provider.of<TranslationProvider>(context, listen: false);
  }

  // 内容翻译
  PublicApiTranslationProvider ofPublicApiTranslation(BuildContext context) {
    return Provider.of<PublicApiTranslationProvider>(context, listen: false);
  }

  // 用户信息
  UserInfoProvider ofUser(BuildContext context) {
    return Provider.of<UserInfoProvider>(context, listen: false)..context = context;
  }

  // 聊天
  ChatProvider ofChat(BuildContext context) {
    return Provider.of<ChatProvider>(context, listen: false);
  }

  // 包
  PackageProvider ofPackage(BuildContext context) {
    return Provider.of<PackageProvider>(context, listen: false)..context = context;
  }

  // 主题
  ThemeProvider ofTheme(BuildContext context) {
    return Provider.of<ThemeProvider>(context, listen: false)..context = context;
  }

  // 文件
  DirProvider ofDir(BuildContext context) {
    return Provider.of<DirProvider>(context, listen: false);
  }
}
