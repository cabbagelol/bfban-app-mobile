import '../constants/api.dart';

class AchievementUtil {
  /// 拼接图标地址
  String getIcon(String path) {
    return path.isNotEmpty ? "assets/images/achievement/$path" : "";
  }

  /// 获取成就信息
  Map getItem(String value) {
    Map achievementInfo = {};
    Map achievements = Config.achievements;
    if (value.isEmpty) return achievementInfo;
    for (int index = 0; index < achievements["child"].length; index++) {
      Map i = achievements["child"][index];
      if (i["child"] == null && i["value"] == value)
        achievementInfo = i;
      else if (i["child"] != null && i["child"].length > 0) {
        for (int jIndex = 0; jIndex < i["child"].length; jIndex++) {
          Map j = i["child"][jIndex];
          if (j["value"] == value) achievementInfo = j;
        }
      }
    }
    return achievementInfo;
  }
}
