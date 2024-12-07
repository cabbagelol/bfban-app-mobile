/// 版本管理器
library;

enum VersionReleaseType { None, Beta, Release }

class Version {
  // 发布类型权重
  final Map _releaseTypeWeights = {
    VersionReleaseType.Beta: 0,
    VersionReleaseType.None: 1,
    VersionReleaseType.Release: 1,
  };

  /// [Event]
  /// 对比版本
  /// 通常格式 0.0.1-beta
  bool compareVersions(String v1, String v2) {
    VersionData version_1 = _setSplitFactory(v1);
    VersionData version_2 = _setSplitFactory(v2);

    if (version_1.number > version_2.number) {
      return true;
    } else if (version_1.number == version_2.number) {
      return _releaseTypeWeights[version_1.releaseType] > _releaseTypeWeights[version_2.releaseType];
    } else {
      return false;
    }
  }

  VersionData _setSplitFactory(String version) {
    List s = version.split("-");
    VersionReleaseType releaseType = VersionReleaseType.None;

    if (s.length >= 2) {
      switch (s[1]) {
        case "beta":
          releaseType = VersionReleaseType.Beta;
          break;
        case "release":
          releaseType = VersionReleaseType.Release;
          break;
        default:
          releaseType = VersionReleaseType.None;
          break;
      }
    }

    return VersionData(
      number: int.parse(s[0].replaceAll(".", "")),
      releaseType: releaseType,
    );
  }

  /// 忽略特定版本
  void onIgnoredVersionItem() {}
}

class VersionData {
  num number;
  VersionReleaseType releaseType;

  VersionData({
    this.number = -1,
    this.releaseType = VersionReleaseType.Beta,
  });
}
