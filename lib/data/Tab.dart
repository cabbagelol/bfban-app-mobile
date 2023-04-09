import 'package:flutter/material.dart';

/// 标签切换器状态
class TabStatus {
  /// 下标
  final int? index;

  final TabController? controller;

  TabStatus({
    this.index,
    this.controller,
  });
}
