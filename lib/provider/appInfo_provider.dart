/// 全局状态管理

import 'package:flutter/material.dart';

class AppInfoProvider with ChangeNotifier {
  // 主题 + 状态管理
  _ThemeProvider Theme_OS = _ThemeProvider();
}

// /// 持久管理器
// class _StorageProvider {
//   late Storage _storage = Storage();
//
//   // 初始持久管理器
//   // APP 主线程上调用
//   init() {
//     _storage.init();
//   }
//
//   Storage? get get => _storage;
// }

/// 主题
/// TODO 待完成
class _ThemeProvider {}
