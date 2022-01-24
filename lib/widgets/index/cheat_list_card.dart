/// 作弊者列表卡片

import 'package:flutter/material.dart';

import 'package:bfban/utils/index.dart';
import 'package:bfban/constants/api.dart';
import 'package:bfban/constants/theme.dart';

import 'package:provider/provider.dart';
import 'package:flutter_elui_plugin/_img/index.dart';

class CheatListCard extends StatelessWidget {
  final item;

  final onTap;

  /// 进度状态
  final Map startusIng = Config.startusIng;

  CheatListCard({
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(right: 10),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(100),
                    ),
                    child: Container(
                      child: EluiImgComponent(
                        width: 40,
                        height: 40,
                        src: item["avatarLink"],
                      ),
                      color: Theme.of(context).cardColor,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.only(
                          left: 5,
                          right: 5,
                        ),
                        decoration: BoxDecoration(
                          color: startusIng[ item["status"] ]["c"] ?? Colors.transparent,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(2),
                          ),
                        ),
                        child: Text(
                          (startusIng[ item["status"] ]["s"]).toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: startusIng[ item["status"] ]["tc"],
                          ),
                        ),
                      ),
                      Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          Text(
                            item["originName"],
                            style: TextStyle(
                              color: Theme.of(context).primaryTextTheme.headline1!.color,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
//                      Text(
//                        "创建时间 " + new Date().getTimestampTransferCharacter(item["createDatetime"])["Y_D_M"],
//                        style: TextStyle(
//                          color: Color.fromRGBO(255, 255, 255, .6),
//                          fontSize: 9,
//                        ),
//                        overflow: TextOverflow.ellipsis,
//                        maxLines: 1,
//                      ),
                      Text(
                        "最后更新:" + new Date().getTimestampTransferCharacter(item["updateTime"])["Y_D_M"],
                        style: TextStyle(
                          color: Theme.of(context).primaryTextTheme.headline1!.color,
                          fontSize: 9,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        cheatersCardIconitem(
                          n: item["viewNum"].toString(),
                          e: "查阅次数",
                          i: Icons.visibility,
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          height: 30,
                          width: 1,
                          color: Theme.of(context).dividerColor,
                        ),
                        cheatersCardIconitem(
                          n: item["commentsNum"].toString(),
                          e: "回复/条",
                          i: Icons.add_comment,
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class cheatersCardIconitem extends StatelessWidget {
  final String? n;
  final String? e;
  final IconData? i;

  cheatersCardIconitem({
    this.n,
    this.e,
    this.i,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            Text(
              n!,
              style: TextStyle(
                color: Theme.of(context).primaryTextTheme.headline1!.color,
                fontSize: 17,
              ),
            ),
            Text(
              e!,
              style: TextStyle(
                color:
                    Theme.of(context).primaryTextTheme.headline4!.color,
                fontSize: 9,
              ),
            ),
          ],
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Icon(
            i,
            color: Theme.of(context).primaryTextTheme.headline6!.color,
            size: 26,
          ),
        ),
      ],
    );
  }
}
