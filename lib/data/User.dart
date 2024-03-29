/// 用户信息
abstract class StationUserBaseData {
  String? id;
  StationUserBaseDataInAttr? attr;
  String? joinTime;
  String? lastOnlineTime;
  Map? origin;
  List? privilege;
  int? reportNum;
  Map? statusNum;
  List? subscribes;
  String? userAvatar;
  String? username;

  StationUserBaseData({
    this.id = "0",
    this.attr,
    this.joinTime = "2018-01-01",
    this.lastOnlineTime = "2018-01-01",
    this.origin = const {},
    this.privilege = const [],
    this.reportNum = 0,
    this.statusNum = const {},
    this.subscribes = const [],
    this.userAvatar = "",
    this.username = "username",
  }) : super() {
    attr ??= StationUserBaseDataInAttr();
  }

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

class StationUserBaseDataInAttr {
  bool? allowDM;
  String? avatar;
  String? certUser;
  String? language;
  bool? freezeOfNoBinding;
  String? introduction;
  bool? showOrigin;
  String? mute;
  bool? showAchievement;
  List? achievements;

  StationUserBaseDataInAttr({
    this.allowDM,
    this.avatar,
    this.certUser,
    this.language,
    this.freezeOfNoBinding,
    this.introduction,
    this.showOrigin,
    this.mute,
    this.showAchievement,
    this.achievements,
  });

  Map setData(Map i) {
    allowDM = i["allowDM"];
    avatar = i["avatar"];
    certUser = i["certUser"];
    language = i["language"];
    freezeOfNoBinding = i["freezeOfNoBinding"];
    introduction = i["introduction"];
    showOrigin = i["showOrigin"];
    mute = i["mute"];
    showAchievement = i["showAchievement"];
    achievements = i["achievements"];
    return toMap;
  }

  get toMap {
    return {
      "allowDM": allowDM,
      "avatar": avatar,
      "certUser": certUser,
      "language": language,
      "freezeOfNoBinding": freezeOfNoBinding,
      "introduction": introduction,
      "showOrigin": showOrigin,
      "mute": mute,
      "showAchievement": showAchievement,
      "achievements": achievements,
    };
  }
}
