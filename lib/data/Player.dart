
/// 玩家数据
class Player {
  num id;

  Player({
    this.id = 0,
  });
}

/// 玩家数据管理
class PlayerStatus {
  late Map data;
  late bool load;
  late PlayerParame? parame;

  PlayerStatus({
    required this.data,
    this.load = false,
    this.parame,
  });
}

/// 玩家请求参数
class PlayerParame {
  late bool history;
  late String personaId;

  PlayerParame({
    this.history = false,
    this.personaId = "",
  });

  get toMap => {
    "history": history,
    "personaId": personaId,
  };
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
  late bool? load;
  late int index;
  late PlayerTimelineParame? parame;

  PlayerTimelineStatus({
    this.list,
    this.load = false,
    this.index = 0,
    this.parame,
  });
}

/// 玩家日历参数
class PlayerTimelineParame {
  late num skip;
  late num limit;
  late String? personaId;

  PlayerTimelineParame({
    this.skip = -1,
    this.limit = 0,
    this.personaId,
  });

  get toMap {
    return {"skip": skip, "limit": limit, "personaId": personaId};
  }
}
