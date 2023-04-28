import 'package:bfban/utils/index.dart';

/// 版本管理器

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
    VersionData _version_1 = _setSplitFactory(v1);
    VersionData _version_2 = _setSplitFactory(v2);

    if (_version_1.number > _version_2.number) {
      return true;
    } else if (_version_1.number == _version_2.number) {
      return _releaseTypeWeights[_version_1.releaseType] > _releaseTypeWeights[_version_2.releaseType];
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
}

class VersionData {
  num number;
  VersionReleaseType releaseType;

  VersionData({
    this.number = -1,
    this.releaseType = VersionReleaseType.Beta,
  });
}
