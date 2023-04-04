import 'package:flutter/material.dart';

import 'class.dart';
import 'index.dart';

abstract class FilterPanelWidget extends StatefulWidget {
  List? filterAll = [];

  FilterPanelData? data;

  bool isInit = false;

  num height = 0;

  FilterPanelWidget({
    Key? key,
    this.data,
  }) : super(key: key);

  /// [Event]
  /// 查找对应 _FilterItem 管理
  /// 从_FilterItem取得title or panle的状态
  FilterItem _getPanel(String name) {
    FilterItem? data = null;
    filterAll?.asMap().keys.forEach((index) {
      FilterItem element = filterAll![index];
      if (element.name == name) {
        data = element;
      }
    });
    return data!;
  }

  /// [Event]
  /// 获取 其他面板数据
  FilterPanelData getPanelData(String name) {
    return _getPanel(name).panel!.data!;
  }

  /// [Event]
  /// 获取 其他面板的title状态
  FilterTitleWidget? getTitleData(String name) {
    return _getPanel(name).title;
  }

  /// [Event]
  /// 改变 其他面板数据
  void setPanelData(String name, FilterPanelData data) {
    _getPanel(name).panel!.data = data;
  }

  /// [Event]
  /// 收起面板
  var hide;

  /// [Event]
  /// 展开
  var show;
}

