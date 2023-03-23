import 'package:flutter/cupertino.dart';

/// 申诉
class AppealCard extends StatelessWidget {
  // 单条数据
  late Map data;

  // 位置
  late int index = 0;

  final Function onReplySucceed;

  AppealCard({
    Key? key,
    required this.onReplySucceed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}