import 'package:bfban/data/Games.dart';
import 'package:flutter/cupertino.dart';

class SearchStatus {
  late bool load;
  late List? historyList;
  late SearchResultData list;
  late SearchBaseParams params;

  SearchStatus({
    this.load = false,
    this.historyList,
    required this.list,
    required this.params,
  });

  Map<String, dynamic> get toMap {
    return {};
  }
}

class SearchResultData {
  late List player = [];
  late List user = [];
  late List comment = [];

  SearchResultData({
    required this.player,
    required this.user,
    required this.comment,
  });

  set (String key, List list) {
    switch (key) {
      case "player":
        player = list;
        break;
      case "user":
        user = list;
        break;
      case "comment":
        comment = list;
        break;
    }
  }

  List data (String key) {
    switch (key) {
      case "player":
        return player;
      case "user":
        return user;
      case "comment":
        return comment;
      default:
        return [];
    }
  }
}

class SearchBaseParams {
  late String? param;

  SearchBaseParams({
    this.param = "",
  });

  get toMap => {"param": param};
}

class SearchScopeTime {
  late num? createTimeFrom;
  late num? createTimeTo;
}

class SearchPageParams {
  late num? skip;
  late num? limit;
}

enum UserSortType {
  byDefault,
  joinedAt,
  lastOnlineTime,
}

enum GameSortType {
  byDefault,
  latest,
  mostViewed,
  mostComments,
}

class SearchPlayerParams implements SearchBaseParams, SearchPageParams, SearchScopeTime {
  late String type;
  late String game;
  late String gameSort;
  final List<String> _gameSortTypeList = ["default", "latest", "mostViewed", "mostComments"];
  final List<String> _gameList = gameList;

  SearchPlayerParams({
    Key? key,
    required this.param,
    this.type = "player",
    GameType game = GameType.all,
    GameSortType gameSort = GameSortType.byDefault,
    this.limit = 40,
    this.skip = 0,
    this.createTimeTo,
    this.createTimeFrom,
  }) : super() {
    this.gameSort = _gameSortTypeList[gameSort.index];
    this.game = _gameList[game.index];
  }

  @override
  Map<String, dynamic> get toMap {
    Map<String, dynamic> map = {
      "type": type,
      "game": game,
      "gameSort": gameSort,
      "param": param,
    };
    if (limit != null) map["limit"] = limit;
    if (skip != null) map["skip"] = skip;
    if (createTimeFrom != null) map["createTimeFrom"] = createTimeFrom;
    if (createTimeTo != null) map["createTimeTo"] = createTimeTo;
    return map;
  }

  @override
  num? limit;

  @override
  String? param;

  @override
  num? skip;

  @override
  num? createTimeFrom;

  @override
  num? createTimeTo;
}

class SearchInStationUser implements SearchBaseParams, SearchPageParams, SearchScopeTime {
  late String type;
  late String gameSort;
  final List _userSortType = ["default", "joinedAt", "lastOnlineTime"];

  SearchInStationUser({
    this.param,
    this.type = "user",
    UserSortType gameSort = UserSortType.byDefault,
    this.createTimeFrom,
    this.createTimeTo,
    this.limit = 40,
    this.skip = 0,
  }) : super() {
    this.gameSort = _userSortType[gameSort.index];
  }

  @override
  Map<String, dynamic> get toMap {
    Map<String, dynamic> map = {
      "type": type,
      "gameSort": gameSort,
      "param": param,
    };
    if (limit != null) map["limit"] = limit;
    if (skip != null) map["skip"] = skip;
    if (createTimeFrom != null) map["createTimeFrom"] = createTimeFrom;
    if (createTimeTo != null) map["createTimeTo"] = createTimeTo;
    return map;
  }

  @override
  num? createTimeFrom;

  @override
  num? createTimeTo;

  @override
  num? limit;

  @override
  String? param;

  @override
  num? skip;
}

class SearchCommentParams implements SearchBaseParams, SearchPageParams, SearchScopeTime {
  late String type;

  SearchCommentParams({
    this.param,
    this.type = "comment",
    this.createTimeFrom,
    this.createTimeTo,
    this.limit = 40,
    this.skip = 0,
  });

  @override
  Map<String, dynamic> get toMap {
    Map<String, dynamic> map = {
      "type": type,
      "param": param,
    };
    if (limit != null) map["limit"] = limit;
    if (skip != null) map["skip"] = skip;
    if (createTimeFrom != null) map["createTimeFrom"] = createTimeFrom;
    if (createTimeTo != null) map["createTimeTo"] = createTimeTo;
    return map;
  }

  @override
  num? createTimeFrom;

  @override
  num? createTimeTo;

  @override
  num? limit;

  @override
  String? param;

  @override
  num? skip;
}
