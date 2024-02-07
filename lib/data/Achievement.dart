import 'User.dart';

class BaseAchievementItem {
  String? name;
  String? acquisitionTime;
  num? points;

  BaseAchievementItem({this.name, this.acquisitionTime, this.points});
}

class UserAchievementStatus extends StationUserBaseData {
  bool? load;
  UserAchievementData? data;

  UserAchievementStatus({
    this.load,
    this.data,
  });
}

class UserAchievementData {
  String? userId;
  String? userAvatar;
  String? username;
  List? o_achievements = [];
  List<BaseAchievementItem>? achievements = [];
  num? userAchievementExp;
  bool? isPublicAchievement;

  Map setData(Map i) {
    userId = i["userId"].toString();
    userAvatar = i["userAvatar"];
    o_achievements = i["achievements"];
    achievements = i["achievements"].map<BaseAchievementItem>((e) => BaseAchievementItem(name: e["name"], acquisitionTime: e["acquisitionTime"], points: e["points"])).toList();
    userAchievementExp = i["userAchievementExp"];
    isPublicAchievement = i["isPublicAchievement"];
    return toMap;
  }

  get toMap {
    return {
      "userId": userId,
      "userAvatar": userAvatar,
      "achievements": achievements,
      "userAchievementExp": userAchievementExp,
      "isPublicAchievement": isPublicAchievement,
    };
  }
}
