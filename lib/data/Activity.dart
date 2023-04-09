import 'package:bfban/data/Paging.dart';

/// 动态数据
class ActivityStatus {
  late bool load;
  late List? list;
  ActivityParame parame;

  ActivityStatus({
    this.load = false,
    this.list,
    required this.parame,
  });
}

class ActivityParame extends Paging {
  ActivityParame({
    this.limit = 20,
    this.skip = 0,
  });

  get toMap {
    Map map = {};
    map.addAll(pageToMap);
    return map;
  }

  @override
  int? limit;

  @override
  int? skip;
}