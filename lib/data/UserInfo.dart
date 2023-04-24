import 'Paging.dart';
import 'User.dart';

/// 站内用户数据
class StationUserInfoStatus {
  bool? load;
  StationUserInfoData? data;
  StationUserInfoParame? parame;

  StationUserInfoStatus({
    this.load = false,
    this.data,
    this.parame,
  });
}

/// 站内用户参数
class StationUserInfoParame extends Paging {
  int? id;

  StationUserInfoParame({
    this.id,
    this.skip,
    this.limit,
  });

  set setId(dynamic value) => id = int.parse(value);

  Map<String, dynamic> get toMap {
    Map<String, dynamic> map = {
      "id": id,
    };
    map.addAll(pageToMap);
    return map;
  }

  @override
  int? skip;

  @override
  int? limit;
}

class StationUserInfoData extends StationUserBaseData {
  //
}