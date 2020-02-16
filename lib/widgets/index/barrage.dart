import 'package:flutter/material.dart';
import 'dart:async';

class usercenterBarrage extends StatefulWidget {
  @override
  _usercenterBarrageState createState() => _usercenterBarrageState();
}

class _usercenterBarrageState extends State<usercenterBarrage> {
  Timer _timer;
  int _countdownTime = 0;
  List barrageList = [
    "战争任然持续",
    "这是一场与作弊玩家抗争",
    "一场在屏幕的战争",
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(usercenterBarrage oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      _countdownTime = 0;
    });
    this.startCountdownTimer();
  }

  void startCountdownTimer() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) => {
      setState(() {
        print('${_countdownTime} ${barrageList.length - 1}');
        if (_countdownTime == barrageList.length - 2) {
          print("结束倒计时");
          timer.cancel();
        }
        _countdownTime += 1;
      })
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(barrageList[_countdownTime]??"", style: TextStyle(
          color: Colors.white,
          fontSize: 30
        ),)
      ],
    );
  }
}
