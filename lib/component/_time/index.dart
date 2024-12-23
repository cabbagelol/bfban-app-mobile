import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../../utils/index.dart';

enum TimeWidgetType { convert, full }

class TimeWidget extends StatefulWidget {
  final String data;
  final TimeWidgetType type;
  final String? timeType;
  final TextStyle? style;
  final TextOverflow? overflow;
  final int? maxLines;
  final TextAlign? textAlign;

  const TimeWidget({
    super.key,
    required this.data,
    this.timeType = "Y_D_M",
    this.type = TimeWidgetType.convert,
    this.style,
    this.overflow,
    this.maxLines,
    this.textAlign,
  });

  @override
  State<TimeWidget> createState() => _TimeWidgetState();
}

class _TimeWidgetState extends State<TimeWidget> {
  String? value;

  Time time = Time();

  /// [Event]
  /// 时间转换可读时间刻
  String getFriendlyDescriptionTime(String date, {typeTime = "Y_D_M_M"}) {
    if (date.isEmpty) return "N/A";

    var time = DateTime.parse(date);
    var now = DateTime.now();
    var d = now.difference(time);

    switch (widget.type) {
      case TimeWidgetType.convert:
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
          return FlutterI18n.translate(context, "app.basic.time.dayAgo", translationParams: {"s": d.inDays.toString()});
        }
        break;
      case TimeWidgetType.full:
      default:
        return this.time.parse(time.millisecondsSinceEpoch).getExtendDate.value(typeTime);
    }
    return this.time.parse(time.millisecondsSinceEpoch).getExtendDate.value(typeTime);
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      getFriendlyDescriptionTime(widget.data, typeTime: widget.timeType),
      style: widget.style,
      overflow: widget.overflow,
      maxLines: widget.maxLines,
      textAlign: widget.textAlign,
    );
  }
}
