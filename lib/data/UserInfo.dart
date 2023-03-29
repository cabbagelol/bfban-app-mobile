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
class StationUserInfoParame {
  int? id;
  int? skip;
  int? limit;

  StationUserInfoParame({
    this.id,
    this.skip,
    this.limit,
  });

  set setId (dynamic value) => id = int.parse(value);

  get toMap {
    return {
      "id": id,
      "skip": skip,
      "limit": limit,
    };
  }
}

class StationUserInfoData extends StationUserBaseData {
  //
}