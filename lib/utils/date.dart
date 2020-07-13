/**
 * by cabbagelol
 */

class Date {

  /// 处理服务器直接取得的时间数据
  String revise (String date) {
    var _date;

//    date = date.replaceAll("T", " ").replaceAll("Z", " ");

//    parse(date)

    _date = DateTime.parse(date);

    return _date.toString();
  }

  /// 补0
  String zeroPadding(number) {
    return number.toString().length == 1 ? "0${number}" : number.toString();
  }

  /**
   * 时间转字符
   * TTC
   */
  Map getTimestampTransferCharacter (String date, {
    num = 0,
  }) {
    var time_ =  DateTime.parse(date);

    var year = time_.year;
    var month = this.zeroPadding(time_.month + 1);
    var day = this.zeroPadding(time_.day);
    var hour = this.zeroPadding(time_.hour);
    var minute = this.zeroPadding(time_.minute);
    var microsecond = time_.second;

    return {
      "year": "${year}",
      "month": "${month}",
      "day": "${day}",
      "hour": "${hour}",
      "minute": "${minute}",
      "microsecond": "${microsecond}",
      "millisecond": "${microsecond}",
      "(zh)D_M": "${month}月${day}日",
      "Y_D": "${year}-${month}-${day}",
      "Y_D_M": "${year}-${month}-${day} ${hour}:${minute}",
      "Y_D_M_M": "${year}-${month}-${day} ${hour}:${minute}:${microsecond}",
      "H_M": "${hour}:${minute}:${microsecond}",
      "H_m": "${hour}:${minute}",
    };
  }

  /**
   * 解析字符串转时间戳
   * TTT
   */
  Map getTurnTheTimestamp (String date) {
    var time_ =  DateTime.parse(date);

    return {
      "secondsSinceEpoch": time_.millisecondsSinceEpoch / 1000,
      "millisecondsSinceEpoch": time_.millisecondsSinceEpoch,
    };
  }
}