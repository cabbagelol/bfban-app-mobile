import 'Captcha.dart';

/// 举报列表
class ReportListStatuc {
  late List? list;
  late bool? load;
  late ReportListParam? param;

  ReportListStatuc({
    this.list,
    this.load = false,
    this.param,
  });
}

/// 举报列表参数
class ReportListParam {
  final String? id;
  final int? skip;
  final int? limit;

  ReportListParam({
    this.id,
    this.skip,
    this.limit,
  });

  get toMap {
    return {
      "id": id,
      "skip": skip,
      "limit": limit,
    };
  }
}

/// 举报
class ReportStatus {
  late bool? load;
  late ReportParam? param;
  late Captcha? captcha;

  ReportStatus({
    this.load,
    this.param,
    this.captcha,
  });

  get toMap {
    return {
      "data": param!.data,
      "encryptCaptcha": captcha!.hash,
      "captcha": captcha!.value,
    };
  }
}

class ReportParam {
  late Map? data;
  late String? encryptCaptcha;

  ReportParam({
    this.data,
  });
}
