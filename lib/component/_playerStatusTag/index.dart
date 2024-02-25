import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

enum PlayerStatusTagSize { small, medium, large }

class PlayerStatusTagWidget extends StatefulWidget {
  int status;
  PlayerStatusTagSize size;

  PlayerStatusTagWidget({
    this.status = 0,
    this.size = PlayerStatusTagSize.medium,
  });

  @override
  State<PlayerStatusTagWidget> createState() => _PlayerStatusTagWidgetState();
}

class _PlayerStatusTagWidgetState extends State<PlayerStatusTagWidget> {
  Map statusColors = {
    0: Colors.green,
    1: Colors.red,
    2: Colors.green,
    3: Colors.yellow,
    4: Colors.grey,
    5: Colors.yellow,
    6: Colors.deepOrangeAccent,
    7: Colors.green,
    8: Colors.green,
    9: Colors.yellow,
  };

  Map<PlayerStatusTagSize, Map> statusSizes = {
    PlayerStatusTagSize.small: {"horizontal": 3.0, "vertical": 1.0},
    PlayerStatusTagSize.medium: {"horizontal": 5.0, "vertical": 2.0},
    PlayerStatusTagSize.large: {"horizontal": 6.0, "vertical": 2.4}
  };

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      padding: EdgeInsets.symmetric(
        horizontal: statusSizes[widget.size]!['horizontal'] as double,
        vertical: statusSizes[widget.size]!['vertical'] as double,
      ),
      decoration: BoxDecoration(
        color: (statusColors[widget.status] as Color).withOpacity(.2),
        border: Border.all(color: statusColors[widget.status].withOpacity(.3) as Color),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        FlutterI18n.translate(context, "basic.status.${widget.status}.text"),
        style: TextStyle(color: statusColors[widget.status] as Color),
      ),
    );
  }
}
