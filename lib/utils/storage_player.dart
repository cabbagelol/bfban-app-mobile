import '../constants/api.dart';
import '../utils/index.dart';
import "./storage.dart";

class StoragePlayer extends Storage {
  String NAME = "viewed";
  num MAXCOUNT = 50;
  Map PLAYERDATA = {};

  // 更新
  updateStorage() {
    Map data = PLAYERDATA;
    num count = data.length;
    num executionsNumber = count - MAXCOUNT;

    if (count >= MAXCOUNT) {
      for (int i = 0; i < executionsNumber; i++) {
        PLAYERDATA.remove(data[i]);
      }
    }

    super.set(NAME, value: PLAYERDATA);
  }

  // 插入
  push(dynamic key, dynamic val) {
    PLAYERDATA[key] = val;
  }

  // 查询
  query(dynamic key) async {
    if (PLAYERDATA.containsKey(key)) {
      return PLAYERDATA[key];
    }

    return await getCheatersInfo(key);
  }

  // 删除
  pop(dynamic key) {
    if (!PLAYERDATA.containsKey(key)) return;
    PLAYERDATA.remove(key);
  }

  // 强制更新
  onForcedUpdate() {
    PLAYERDATA.forEach((key, value) async {
      if (PLAYERDATA[key] != null) PLAYERDATA[key] = await getCheatersInfo(key);
    });

    updateStorage();
  }

  // 获取作弊档案
  Future getCheatersInfo(dynamic dbId) async {
    Response result = await Http.request(
      Config.httpHost["cheaters"],
      parame: {"hisroty": true, "dbId": dbId},
      method: Http.GET,
    );
    Map d = result.data;

    if (d["success"]! != 1) return {};

    d.remove("history");

    PLAYERDATA[d["data"]["id"]] = d["data"];
    updateStorage();
    return d["data"];
  }
}
