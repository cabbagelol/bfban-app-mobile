import 'dart:core';

/// 时间

class Time {
  DateBaseData? _time;

  /// 转换
  ///
  /// Examples of accepted strings:
  /// date2.parse("2023-11-10").getExtendDate.hour
  /// date2.parse(1541260800000).getExtendDate.Y_D_M
  Time parse(dynamic value) {
    DateTime dateTime;

    if (value is String && DateTime.tryParse(value) != null) {
      dateTime = DateTime.parse(value);
    } else if (value is DateTime) {
      dateTime = value;
    } else if (value is num) {
      dateTime = DateTime.fromMillisecondsSinceEpoch(value as int);
    } else {
      throw "Types are not supported. See the formats supported by DateTime";
    }
    _time = DateBaseData(dateTime);
    return this;
  }

  DateBaseData get getDate => _time ?? DateBaseData(null);

  DateExtendData get getExtendDate => DateExtendData(_time!._get);

  DateExtendSecondData get getExtendSecondDate => DateExtendSecondData(_time!._get);
}

class DateBaseData {
  String? year;
  String? _month;
  String? _day;
  String? _hour;
  String? _minute;
  String? _microsecond;

  DateBaseData(
    dynamic t, {
    bool useLocal = true,
  }) : assert(t is DateTime || t == null) {
    DateTime time = useLocal ? t.toLocal() : t;
    year = time.year.toString();
    _month = time.month.toString();
    _day = time.day.toString();
    _hour = time.hour.toString();
    _minute = time.minute.toString();
    _microsecond = time.microsecond.toString();
  }

  String get month => _handleZeroPadding(_month);

  String get day => _handleZeroPadding(_day);

  String get hour => _handleZeroPadding(_hour);

  String get minute => _handleZeroPadding(_minute);

  String get microsecond => _handleZeroPadding(_microsecond);

  DateTime get _get => DateTime.parse("$year-$month-$day $hour:$minute:$microsecond");

  String _handleZeroPadding(dynamic number) {
    return number.toString().length == 1 ? "0$number" : number.toString();
  }
}

class DateExtendData extends DateBaseData {
  DateExtendData(DateTime t) : super(t);

  String get Y_D => "$year-$month-$day";

  String get Y_D_M => "$year-$month-$day $hour:$minute";

  String get Y_D_M_m => "$year-$month-$day $hour:$minute:$microsecond";

  String get H_M => "$hour:$minute:$microsecond";

  String get H_m => "$hour:$minute";

  String value(String type) {
    switch (type) {
      case "Y_D":
        return Y_D;
      case "Y_D_M":
        return Y_D_M;
      case "H_M":
        return H_M;
      case "H_m":
        return H_m;
      case "Y_D_M_m":
      default:
        return Y_D_M_m;
    }
  }
}

class DateExtendSecondData extends DateBaseData {
  DateExtendSecondData(DateTime t) : super(t);

  String? get secondsSinceEpoch => "${_get.millisecondsSinceEpoch / 1000}";

  String? get millisecondsSinceEpoch => "${_get.millisecondsSinceEpoch}";
}
