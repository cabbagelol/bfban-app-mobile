import 'package:bfban/data/index.dart';

import 'Paging.dart';

class TourRecordStatus extends Paging {
  bool? load;
  List<TourRecordPlayerBaseData>? list;

  TourRecordStatus({
    this.load,
    this.list,
  });
}

class TourRecordPlayerBaseData extends PlayerBaseData {
  @override
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

  @override
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
      "status": status,
      "createTime": createTime,
      "updateTime": updateTime,
    };
  }
}
