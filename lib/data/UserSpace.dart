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
  });

  get toMap {
    return {
      "id": id,
    };
  }
}

class StationUserSpaceData extends StationUserBaseData {
  String? name;

  StationUserSpaceData({
    this.name,
  });
}
