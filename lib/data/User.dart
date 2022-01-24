/// 用户信息
class User {
  Map<String, dynamic>? data;

  User({
    this.data,
  });
}

/// 站内用户数据
class UserInfoStatuc {
  bool? load;
  Map? data;
  UserInfoParame? parame;

  UserInfoStatuc({
    this.load = false,
    this.data,
    this.parame,
  });
}

/// 站内用户参数
class UserInfoParame {
  String? id;
  int? skip;
  int? limit;

  UserInfoParame({
    this.id,
    this.skip,
    this.limit,
  });

  set setId (value) => id = value.toString();

  get toMap {
    return {
      "id": id,
      "skip": skip,
      "limit": limit,
    };
  }
}
