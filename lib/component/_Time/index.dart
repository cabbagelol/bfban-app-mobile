import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../../utils/index.dart';

class TimeWidget extends StatefulWidget {
  String? data;
  String? value;

  var style;
  var overflow;
  var maxLines;
  var textAlign;

  TimeWidget({
    Key? key,
    this.data,
    this.style,
    this.overflow,
    this.maxLines,
    this.textAlign,
  }) : super(key: key);

  @override
  State<TimeWidget> createState() => _TimeWidgetState();
}

class _TimeWidgetState extends State<TimeWidget> {
  Date date = Date();

  /// [Event]
  /// 时间转换可读时间刻
  String getFriendlyDescriptionTime(String date, {type = "Y_D_M"}) {
    var time = DateTime.parse(date);
    var now = DateTime.now();
    var d = now.difference(time);

    if (d.inDays == 0) {
      // 一天之内

      if (d.inSeconds >= 0 && d.inSeconds <= 60) {
        // 60秒内
        return FlutterI18n.translate(context, "app.basic.time.seconds", translationParams: {
          "s": d.inSeconds.toString(),
        });
      } else if (d.inSeconds > 60 && d.inMinutes <= 1) {
        // 一分钟内
        return FlutterI18n.translate(context, "app.basic.time.minutes", translationParams: {
          "s": d.inMinutes.toString(),
        });
      } else if (d.inMinutes >= 1 && d.inMinutes <= 60 && d.inHours <= 24) {
        // 一小时内
        return FlutterI18n.translate(context, "app.basic.time.minutes", translationParams: {
          "s": d.inMinutes.toString(),
        });
      }
      return FlutterI18n.translate(context, "app.basic.time.today");
    } else if (d.inDays == 1) {
      return FlutterI18n.translate(context, "app.basic.time.yesterday");
    } else if (d.inDays == 2) {
      return FlutterI18n.translate(context, "app.basic.time.beforeYesterday");
    } else if (d.inDays >= 3 && d.inDays <= 7) {
      return FlutterI18n.translate(context, "app.basic.time.dayAgo", translationParams: {
        "s": d.inDays.toString()
      });
    }

    widget.value = this.date.getTimestampTransferCharacter(date)[type];
    return this.date.getTimestampTransferCharacter(date)[type];
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      getFriendlyDescriptionTime(widget.data!),
      style: widget.style ??= null,
      overflow: widget.overflow ??= null,
      maxLines: widget.maxLines ??= null,
      textAlign: widget.textAlign ??= null,
    );
  }
}
