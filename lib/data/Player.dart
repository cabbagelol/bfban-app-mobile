import 'package:bfban/data/Paging.dart';

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
    this.avatarLink = "",
    this.viewNum,
    this.commentsNum,
    this.valid,
    this.createTime,
    this.updateTime,
  });

  Map setData(Map i) {
    id = i["id"];
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
  bool? load;
  List? list;
  int? pageNumber;
  PlayersParame? parame;

  PlayersStatus({
    this.load = false,
    this.list,
    this.pageNumber = 1,
    this.parame,
  });
}

/// 作弊玩家列表 参 Players
class PlayersParame extends Paging {
  String? game;
  String? sortBy;
  int? status;
  num? createTimeFrom;
  num? createTimeTo;
  num? updateTimeFrom;
  num? updateTimeTo;

  PlayersParame({
    this.game = "all",
    this.sortBy = "updateTime",
    this.status = -1,
    this.createTimeTo,
    this.createTimeFrom,
    this.updateTimeFrom,
    this.updateTimeTo,
    this.limit = 10,
    this.skip = 1,
  });

  setData(Map i) {
    if (i["game"] != null) game = i["game"];
    if (i["sortBy"] != null) sortBy = i["sortBy"];
    if (i["status"] != null) status = i["status"];
    if (i["createTimeFrom"] != null) createTimeFrom = i["createTimeFrom"];
    if (i["createTimeTo"] != null) createTimeTo = i["createTimeTo"];
    if (i["updateTimeFrom"] != null) updateTimeFrom = i["updateTimeFrom"];
    if (i["updateTimeTo"] != null) updateTimeTo = i["updateTimeTo"];
    return toMap;
  }

  get toMap {
    Map<String, dynamic>? map = {
      "game": game,
      "sortBy": sortBy,
      "status": status,
      "skip": skip,
      "limit": limit,
    };
    if (createTimeTo != null) map["createTimeTo"] = createTimeTo;
    if (createTimeFrom != null) map["createTimeFrom"] = createTimeFrom;
    if (updateTimeFrom != null) map["updateTimeFrom"] = updateTimeFrom;
    if (updateTimeTo != null) map["updateTimeTo"] = updateTimeTo;
    return map;
  }

  @override
  int? limit;

  @override
  int? skip;
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
