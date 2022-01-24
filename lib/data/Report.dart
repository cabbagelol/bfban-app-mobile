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
  late Captcha? captcha;
  late ReportParam? param;

  ReportStatus({
    this.load,
    this.captcha,
    this.param,
  });
}

class ReportParam {
  late Map? data;
  late String? encryptCaptcha;
  late String? captcha;

  ReportParam({
    this.data,
    this.encryptCaptcha,
    this.captcha,
  });

  get toMap {
    return {
      "data": data,
      "encryptCaptcha": encryptCaptcha,
      "captcha": captcha,
    };
  }
}
