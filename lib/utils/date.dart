/// 时间

class Date {
  /// 补0
  String zeroPadding(number) {
    return number.toString().length == 1 ? "0$number" : number.toString();
  }

  /// 时间转字符
  /// TTC
  Map getTimestampTransferCharacter(
    String date, {
    num = 0,
  }) {
    var time_ = DateTime.parse(date);

    var year = time_.year;
    var month = zeroPadding(time_.month);
    var day = zeroPadding(time_.day);
    var hour = zeroPadding(time_.hour);
    var minute = zeroPadding(time_.minute);
    var microsecond = time_.second;

    return {
      "year": "$year",
      "month": month,
      "day": day,
      "hour": hour,
      "minute": minute,
      "microsecond": "$microsecond",
      "millisecond": "$microsecond",
      "(zh)D_M": "$month月$day日",
      "Y_D": "$year-$month-$day",
      "Y_D_M": "$year-$month-$day $hour:$minute",
      "Y_D_M_M": "$year-$month-$day $hour:$minute:$microsecond",
      "H_M": "$hour:$minute:$microsecond",
      "H_m": "$hour:$minute",
    };
  }

  /// 解析字符串转时间戳
  /// TTT
  Map getTurnTheTimestamp(String date) {
    var time = DateTime.parse(date);

    return {
      "secondsSinceEpoch": time.millisecondsSinceEpoch / 1000,
      "millisecondsSinceEpoch": time.millisecondsSinceEpoch,
    };
  }

}

class DateData {

}
