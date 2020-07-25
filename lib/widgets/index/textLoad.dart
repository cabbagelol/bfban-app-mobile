import 'package:flutter/material.dart';

class textLoad extends StatefulWidget {
  final String value;

  final double fontSize;

  textLoad({
    this.value,
    this.fontSize,
  });

  @override
  _textLoadState createState() => _textLoadState();
}

class _textLoadState extends State<textLoad> with TickerProviderStateMixin {
  var _animation;

  var _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        double value = _animation.value;

        Gradient gradient = LinearGradient(
          colors: [Colors.grey, Colors.white, Colors.grey],
          stops: [value - 0.2, value, value + 0.2],
        );

        Shader shader = gradient.createShader(
          Rect.fromLTWH(
            0,
            0,
            size.width,
            size.height,
          ),
        );

        return Text(
          widget.value.toString() ?? "-",
          style: TextStyle(
            fontSize: widget.fontSize ?? 28.0,
            foreground: Paint()..shader = shader,
          ),
        );
      },
    );
  }
}
