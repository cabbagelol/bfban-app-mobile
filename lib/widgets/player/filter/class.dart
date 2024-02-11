import 'framework.dart';

/// S 面板
class FilterItem {
  String? name;
  FilterPanelWidget? panel;

  FilterItem({
    this.name,
    this.panel,
  });
}

/// E 面板

class FilterPanelBaseData {}

/// 面板返回数据
class FilterPanelData extends FilterPanelBaseData {
  List<dynamic> values;
  List<String> names;

  FilterPanelData({
    required this.values,
    required this.names,
  });

  Map toMap({bool force = false}) {
    Map map = {};
    for (var element in names.indexed) {
      if (values[element.$1] != null || force) map[names[element.$1]] = values[element.$1];
    }
    return map;
  }

  bool get isValueNull {
    return values.isEmpty || values.where((element) => (element == null || element == "")).length == values.length;
  }
}
