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
  @override
  Map setData(Map i) {
    id = i["id"].toString();
    attr!.setData(i["attr"]);
    joinTime = i["joinTime"];
    lastOnlineTime = i["lastOnlineTime"];
    origin = i["origin"];
    privilege = i["privilege"];
    reportNum = i["reportNum"];
    statusNum = i["statusNum"];
    subscribes = i["subscribes"];
    userAvatar = i["userAvatar"];
    username = i["username"];
    return toMap;
  }

  @override
  get toMap {
    return {
      "id": id,
      "attr": attr!.toMap,
      "joinTime": joinTime,
      "lastOnlineTime": lastOnlineTime,
      "origin": origin,
      "privilege": privilege,
      "reportNum": reportNum,
      "statusNum": statusNum,
      "subscribes": subscribes,
      "userAvatar": userAvatar,
      "username": username,
    };
  }
}
