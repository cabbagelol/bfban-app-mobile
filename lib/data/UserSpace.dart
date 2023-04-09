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
  }) : super(limit: 0, skip: 0);

  get toMap {
    Map map = {
      "id": id,
    };
    map.addAll(pageToMap);
    return map;
  }
}

class StationUserSpaceData extends StationUserBaseData {
  String? name;

  StationUserSpaceData({
    this.name,
  });
}
