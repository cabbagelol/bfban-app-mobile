import 'package:bfban/data/Paging.dart';

class TraceStatus {
  bool? load;
  List? list;
  TraceParame parame;

  TraceStatus({
    this.load = false,
    this.list,
    required this.parame,
  });
}

class TraceParame extends Paging {
  TraceParame({
    this.skip,
    this.limit,
  });

  get toMap {
    Map map = {};
    map.addAll(pageToMap);
    return map;
  }

  @override
  int? skip;

  @override
  int? limit;
}
