import 'index.dart';
import 'framework.dart';

/// S 面板
class FilterItem {
  String? name;
  FilterTitleWidget? title;
  FilterPanelWidget? panel;

  FilterItem({
    this.name,
    required this.title,
    this.panel,
  });
}

/// E 面板

/// 面板返回数据
class FilterPanelData {
  dynamic value;
  String name;

  FilterPanelData({
    required this.value,
    required this.name,
  });
}
