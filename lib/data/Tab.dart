import 'package:flutter/material.dart';

/// 标签切换器状态
class TabStatuc {
  /// 下标
  final int? index;

  final TabController? controller;

  TabStatuc({
    this.index,
    this.controller,
  });
}
