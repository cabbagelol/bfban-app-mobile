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
  final Time _time = Time();

  final Map _data = {
    'original': 'N/A',
    'originalConversion': 'N/A',
    'localOriginal': 'N/A',
    'localTimeZoneName': 'N/A',
    'localConversion': 'N/A',
  };

  String get original {
    return widget.data;
  }

  String get originalConversion {
    return _getFriendlyDescriptionTime(widget.data, type: TimeWidgetType.convert, typeTime: widget.timeType);
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      setState(() {
        _data['original'] = original;
        _data['originalConversion'] = originalConversion;
      });
    });
  }

  /// [Event]
  /// 时间转换可读时间刻
  String _getFriendlyDescriptionTime(String date, {type, typeTime = "Y_D_M_M"}) {
    if (date.isEmpty) return "N/A";

    var time = DateTime.parse(date);
    var now = DateTime.now();
    var d = now.difference(time);

    switch (type) {
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
        return _time.parse(time.millisecondsSinceEpoch).getExtendDate.value(typeTime);
    }
    return _time.parse(time.millisecondsSinceEpoch).getExtendDate.value(typeTime);
  }

  /// [Event]
  /// 查看具体时间信息
  void _openDateDetail() {
    setState(() {
      _data['localOriginal'] = DateTime.parse(original).toLocal();
      _data['localTimeZoneName'] = _data['localOriginal'].timeZoneName;
      _data['localConversion'] = _getFriendlyDescriptionTime(_data['localOriginal'].toString(), type: TimeWidgetType.full, typeTime: "Y_D_M_M");
    });

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isDismissible: true,
      useSafeArea: true,
      builder: (context) {
        return ListView(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          children: [
            TextField(
              readOnly: true,
              controller: TextEditingController(text: _data['original']),
              decoration: InputDecoration(
                icon: Icon(Icons.date_range),
                label: Text(FlutterI18n.translate(context, "detail.dateView.primitive")),
                helper: Wrap(
                  spacing: 5,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Icon(Icons.info, size: 15),
                    Text(FlutterI18n.translate(context, "detail.dateView.primitiveDescription")),
                  ],
                ),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 35),
            TextField(
              readOnly: true,
              controller: TextEditingController(text: _data['localTimeZoneName'].toString()),
              decoration: InputDecoration(
                label: Text(FlutterI18n.translate(context, "detail.dateView.localTimeZoneName")),
                icon: Icon(Icons.location_on_sharp),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              readOnly: true,
              controller: TextEditingController(text: _data['localConversion'].toString()),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                icon: Icon(Icons.date_range),
                labelText: FlutterI18n.translate(context, "detail.dateView.localeTime"),
                helper: Wrap(
                  spacing: 5,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Icon(Icons.info, size: 15),
                    Text(FlutterI18n.translate(context, "detail.dateView.localeTimeDescription")),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openDateDetail(),
      child: Text(
        originalConversion,
        style: (widget.style ?? TextStyle()).copyWith(
          decoration: TextDecoration.underline,
          decorationStyle: TextDecorationStyle.dashed,
        ),
        overflow: widget.overflow,
        maxLines: widget.maxLines,
        textAlign: widget.textAlign,
      ),
    );
  }
}
