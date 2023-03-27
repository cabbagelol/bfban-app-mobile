/// 玩家数据
abstract class PlayerBaseData {
  num id;
  String? originName;
  String? originUserId;
  String? originPersonaId;
  List? games;
  List? cheatMethods;
  String? avatarLink;
  int? viewNum;
  int? commentsNum;
  int? valid;
  int? status;
  String? createTime;
  String? updateTime;

  PlayerBaseData({
    this.id = 0,
    this.originName,
    this.originUserId,
    this.originPersonaId,
    this.games,
    this.cheatMethods,
    this.avatarLink,
    this.viewNum,
    this.commentsNum,
    this.valid,
    this.createTime,
    this.updateTime,
  });

  get toMap {
    return {
      "id": id,
      "originName": originName,
      "originUserId": originUserId,
      "originPersonaId": originPersonaId,
      "games": games,
      "cheatMethods": cheatMethods,
      "avatarLink": avatarLink,
      "viewNum": viewNum,
      "commentsNum": commentsNum,
      "valid": valid,
      "createTime": createTime,
      "updateTime": updateTime,
    };
  }
}

/// 玩家数据管理
class PlayerStatus {
  late PlayerStatusData data;
  late bool load;
  late PlayerParame? parame;

  PlayerStatus({
    required this.data,
    this.load = false,
    this.parame,
  });
}

class PlayerStatusData extends PlayerBaseData {
  late List? history;

  PlayerStatusData({
    this.history,
  });

  Map setData(Map i) {
    id = i["id"];
    history = i["history"];
    originName = i["originName"];
    originUserId = i["originUserId"];
    originPersonaId = i["originPersonaId"];
    games = i["games"];
    cheatMethods = i["cheatMethods"];
    avatarLink = i["avatarLink"];
    viewNum = i["viewNum"];
    commentsNum = i["commentsNum"];
    status = i["status"];
    createTime = i["createTime"];
    updateTime = i["updateTime"];
    return toMap;
  }

  get toMap {
    return {
      "id": id,
      "history": history,
      "originName": originName,
      "originUserId": originUserId,
      "originPersonaId": originPersonaId,
      "games": games,
      "cheatMethods": cheatMethods,
      "avatarLink": avatarLink,
      "viewNum": viewNum,
      "commentsNum": commentsNum,
      "status": status,
      "createTime": createTime,
      "updateTime": updateTime,
    };
  }
}

/// 玩家请求参数
class PlayerParame {
  late bool history;
  late String personaId;

  PlayerParame({
    this.history = false,
    this.personaId = "",
  });

  get toMap {
    return {
      "history": history,
      "personaId": personaId,
    };
  }
}

/// 作弊玩家列表 Players
class PlayersStatus {
  late bool? load;
  late List? list;
  late int page;
  late PlayersParame? parame;

  PlayersStatus({
    this.load = false,
    this.list,
    this.page = 0,
    this.parame,
  });
}

/// 作弊玩家列表 参 Players
class PlayersParame {
  dynamic data;

  PlayersParame({
    this.data,
  });

  get toMap {
    return data;
  }

  set skip(value) {
    data["skip"] = value;
  }

  get skip => data["skip"];
}

/// 玩家日历状态
class PlayerTimelineStatus {
  late List? list;
  late int? total;
  late bool? load;
  late int index;
  late PlayerTimelineParame? parame;

  PlayerTimelineStatus({
    this.list,
    this.total = 0,
    this.load = false,
    this.index = 0,
    this.parame,
  });
}

/// 玩家日历参数
class PlayerTimelineParame {
  late num skip;
  late num limit;
  late String personaId;

  PlayerTimelineParame({
    this.skip = -1,
    this.limit = 0,
    required this.personaId,
  });

  get toMap {
    return {
      "skip": skip,
      "limit": limit,
      "personaId": personaId,
    };
  }
}
