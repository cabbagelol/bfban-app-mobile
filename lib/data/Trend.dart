import 'Player.dart';

class TrendStatus {
  bool? load;
  List<TrendPlayerBaseData> _list = [];
  TrendStatusParame? parame;

  TrendStatus({
    this.load = false,
    this.parame,
  });

  set list(List list) {
    for (var key in list) {
      TrendPlayerBaseData data = TrendPlayerBaseData();
      data.setData(key);
      _list.add(data);
    }
  }

  List<TrendPlayerBaseData> get list => _list;
}

class TrendPlayerBaseData extends PlayerBaseData {
  num? hot;

  TrendPlayerBaseData({
    this.hot,
  }) : super();

  Map setData(Map i) {
    id = i["id"];
    hot = i["hot"];
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
      "hot": hot,
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

enum TrendStatusParameTime {
  daily,
  weekly,
  monthly,
  yearly,
}

class TrendStatusParame {
  num? limit;
  String? time;

  final List? _TrendStatusParameTimeList = ["daily", "weekly", "monthly", "yearly"];

  TrendStatusParame({
    this.limit = 10,
    TrendStatusParameTime time = TrendStatusParameTime.weekly,
  }) : super() {
    this.time = _TrendStatusParameTimeList![time.index];
  }

  get toMap {
    return {
      "limit": limit,
      "time": time,
    };
  }
}
