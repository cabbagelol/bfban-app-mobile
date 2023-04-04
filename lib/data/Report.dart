import 'Captcha.dart';
import 'Paging.dart';
import 'Player.dart';

/// 举报列表
class ReportListStatus {
  late bool? load;
  late List<ReportListPlayerData> _list = [];
  late ReportListStatusParame parame;

  ReportListStatus({
    this.load = false,
    List<ReportListPlayerData>? list,
    required this.parame,
  }) : super() {
    if (list == null) _list = list!;
  }

  List<ReportListPlayerData> get list => _list;

  set list(List<dynamic> array) {
    for (var i in array) {
      ReportListPlayerData item = ReportListPlayerData();
      item.setData(i);
      _list.add(item);
    }
  }
}

class ReportListPlayerData extends PlayerBaseData {
  @override
  Map setData(Map i) {
    originName = i["originName"];
    originUserId = i["originUserId"];
    originPersonaId = i["originPersonaId"];
    avatarLink = i["avatarLink"];
    status = i["status"];
    createTime = i["createTime"];
    updateTime = i["updateTime"];
    return toMap;
  }
}

/// 举报列表参数
class ReportListStatusParame extends Paging {
  int? id;

  ReportListStatusParame({
    this.id,
    this.limit,
    this.skip,
  });

  get toMap {
    return {
      "id": id,
      "limit": limit,
      "skip": skip,
    };
  }

  @override
  int? limit;

  @override
  int? skip;
}

/// 举报
class ReportStatus {
  late bool? load;
  late ReportParam? param;

  ReportStatus({
    this.load,
    this.param,
  });

  get toMap {
    return {
      "data": param!.data,
    };
  }
}

class ReportParam extends Captcha {
  late Map? data;
  late String? encryptCaptcha;
  late Captcha? captcha;

  ReportParam({
    this.data,
    this.captcha,
  });
}
