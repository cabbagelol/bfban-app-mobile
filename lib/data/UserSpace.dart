import 'Paging.dart';
import 'User.dart';

/// 站内用户数据
class StationUserSpaceStatus {
  bool? load;
  StationUserSpaceData data;
  StationUserSpaceParame parame;

  StationUserSpaceStatus({
    this.load = false,
    required this.data,
    required this.parame,
  });
}

/// 站内用户参数
class StationUserSpaceParame extends Paging {
  String? id;

  StationUserSpaceParame({
    this.id,
    this.limit,
    this.skip,
  });

  Map<String, dynamic> get toMap {
    Map<String, dynamic> map = {
      "id": id,
    };
    map.addAll(pageToMap);
    return map;
  }

  @override
  int? limit;

  @override
  int? skip;
}

class StationUserSpaceData extends StationUserBaseData {
  String? name;

  StationUserSpaceData({
    this.name,
  });
}
