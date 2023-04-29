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
    if (i["id"] != null) id = i["id"];
    if (i["originName"] != null) originName = i["originName"];
    if (i["originUserId"] != null) originUserId = i["originUserId"];
    if (i["originPersonaId"] != null) originPersonaId = i["originPersonaId"];
    if (i["games"] != null) games = i["games"];
    if (i["cheatMethods"] != null) cheatMethods = i["cheatMethods"];
    if (i["avatarLink"] != null) avatarLink = i["avatarLink"];
    if (i["viewNum"] != null) viewNum = i["viewNum"];
    if (i["commentsNum"] != null) commentsNum = i["commentsNum"];
    if (i["status"] != null) status = i["status"];
    if (i["valid"] != null) valid = i["valid"];
    if (i["createTime"] != null) createTime = i["createTime"];
    if (i["updateTime"] != null) updateTime = i["updateTime"];
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
      "status": status,
      "createTime": createTime,
      "updateTime": updateTime,
    };
  }
}

/// 玩家数据管理
class PlayerStatus {
  late PlayerStatusData? data;
  late bool load;
  late PlayerParame? parame;

  PlayerStatus({
    this.data,
    this.load = false,
    this.parame,
  });
}

class PlayerStatusData extends PlayerBaseData {
  late List? history;

  PlayerStatusData({
    this.history,
  });

  @override
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

  @override
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
  bool history;
  String personaId;
  String dbId;

  PlayerParame({
    this.history = false,
    this.personaId = "",
    this.dbId = "",
  });

  Map<String, dynamic> get toMap {
    Map<String, dynamic> map = {
      "history": history,
    };
    if (dbId.isNotEmpty) map.addAll({"dbId": dbId});
    if (personaId.isNotEmpty) map.addAll({"personaId": personaId});
    return map;
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
    this.limit,
    this.skip,
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
    };
    if (createTimeTo != null) map["createTimeTo"] = createTimeTo;
    if (createTimeFrom != null) map["createTimeFrom"] = createTimeFrom;
    if (updateTimeFrom != null) map["updateTimeFrom"] = updateTimeFrom;
    if (updateTimeTo != null) map["updateTimeTo"] = updateTimeTo;
    map.addAll(pageToMap);
    return map;
  }

  @override
  int? limit;

  @override
  int? skip;
}

/// 玩家时间轴状态
class PlayerTimelineStatus {
  List? list;
  int? total;
  int? pageNumber;
  bool? load;
  PlayerTimelineParame parame;

  PlayerTimelineStatus({
    this.list,
    this.total = 0,
    this.pageNumber = 0,
    this.load = false,
    required this.parame,
  });
}

/// 玩家时间轴参数
class PlayerTimelineParame extends Paging {
  String personaId;

  PlayerTimelineParame({
    required this.personaId,
    this.skip = 0,
    this.limit = 20,
  });

  Map<String, dynamic> get toMap {
    Map<String, dynamic> map = {
      "personaId": personaId,
    };
    map.addAll(pageToMap);
    return map;
  }

  @override
  int? skip;

  @override
  int? limit;
}
