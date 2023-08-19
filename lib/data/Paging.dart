import 'dart:io';

abstract class Paging {
  int? skip;
  int? _minSkip = 0;
  int? limit;
  bool? _isAuto = true;

  Paging({
    this.limit = 40,
    this.skip = 1,
  });

  resetPage() {
    skip = _minSkip!;
  }

  /// 下一页
  nextPage({int count = 1}) {
    skip = skip! + count;
  }

  /// 上一页
  prevPage({int count = 1}) {
    if (skip! <= _minSkip!) return;
    skip = skip! - count;
  }

  bool isMultiplier() {
    if (!_isAuto!) return false;

    switch (Platform.operatingSystem) {
      case "macos":
      case "windows":
      case "linux":
        return true;
      default:
        return false;
    }
  }

  Map<String, dynamic> get pageToMap => Map.from({
        "skip": skip,
        "limit": isMultiplier() ? limit! * 2 : limit ,
      });
}

abstract class Sort {
  String? sort;

  Sort({
    this.sort,
  });
}
