import 'package:bfban/utils/index.dart';

import '../constants/api.dart';

class AchievementUtil {
  /// 拼接图标地址
  String getIcon(String? path) {
    if (path == null || path.isEmpty) return "";
    final baseUrl = Config.apiHost["web_site"]?.url ?? "";
    return baseUrl.isNotEmpty ? "$baseUrl/images/achievement/$path" : "";
  }

  /// 获取成就信息
  Map getItem(String? value) {
    Map achievementInfo = {};
    Map achievements = Config.achievements;
    if (value == null || value.isEmpty || achievements["child"] == null || achievements["child"] is! List) return achievementInfo;
    final List childList = achievements["child"] as List;
    for (int index = 0; index < childList.length; index++) {
      if (childList[index] is! Map) continue;
      Map i = childList[index];
      if (i["child"] == null && i["value"] == value) {
        achievementInfo = i;
      } else if (i["child"] != null && i["child"] is List && (i["child"] as List).isNotEmpty) {
        final List subChildList = i["child"] as List;
        for (int jIndex = 0; jIndex < subChildList.length; jIndex++) {
          if (subChildList[jIndex] is! Map) continue;
          Map j = subChildList[jIndex];
          if (j["value"] == value) achievementInfo = j;
        }
      }
    }
    return achievementInfo;
  }

  /// 主动获取成就
  Future onActiveAchievement(String id) async {
    return await HttpToken.request(
      Config.httpHost["account_achievement"],
      method: Http.POST,
      data: {"id": id},
    );
  }
}
