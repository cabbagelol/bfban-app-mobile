import 'package:bfban/data/Paging.dart';
import 'package:bfban/data/index.dart';

class CloudMediaStatus extends MediaWrite {
  bool? load;
  List list;
  CloudMediaParame? parame;

  CloudMediaStatus({
    this.load,
    required this.list,
    this.parame,
  });
}

class CloudMediaParame extends Paging {
  CloudMediaParame({
    this.skip = 0,
    this.limit = 10,
  });

  Map<String, dynamic> get toMap {
    return pageToMap;
  }

  @override
  int? skip;

  @override
  int? limit;
}

class CloudMediaInfoStatus {
  bool? load;
  Map? data;

  CloudMediaInfoStatus({
    this.load,
    this.data,
  });
}
