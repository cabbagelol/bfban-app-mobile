import 'package:flutter/cupertino.dart';
/// 作弊者列表卡片

import 'package:flutter/material.dart';

import 'package:bfban/utils/index.dart';
import 'package:bfban/constants/api.dart';

class CheatListCard extends StatelessWidget {
  final item;

  final onTap;

  /// 进度状态
  final List<dynamic> startusIng = Config.startusIng;

  CheatListCard({
    @required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => this.onTap(),
      child: Container(
        color: Colors.black12,
        padding: EdgeInsets.only(
          top: 10,
          left: 20,
          bottom: 10,
          right: 20,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              margin: EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(100),
                image: DecorationImage(
                  image: NetworkImage(
                    item["avatarLink"],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(
                          left: 5,
                          right: 5,
                        ),
                        margin: EdgeInsets.only(
                          right: 10,
                        ),
                        color: startusIng[int.parse(item["status"])]["c"] ?? Colors.transparent,
                        child: Text(
                          (startusIng[int.parse(item["status"])]["s"] ?? Colors.white).toString(),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        item["originId"],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),


                  Row(
                    children: <Widget>[
                      Text(
                        "发布时间:" + new Date().getTimestampTransferCharacter(item["createDatetime"])["Y_D_M"],
                        style: TextStyle(
                          color: Color.fromRGBO(255, 255, 255, .6),
                          fontSize: 9,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          left: 7,
                          right: 7,
                        ),
                        height: 8,
                        width: 1,
                        color: Colors.white12,
                      ),
                      Text(
                        "最后更新:" + new Date().getTimestampTransferCharacter(item["updateDatetime"])["Y_D_M"],
                        style: TextStyle(
                          color: Color.fromRGBO(255, 255, 255, .6),
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Wrap(
                        spacing: 2,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.visibility,
                            color: Colors.white,
                            size: 10,
                          ),
                          Text(
                            item["n"].toString() ?? "",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                            ),
                          )
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          left: 7,
                          right: 7,
                        ),
                        height: 8,
                        width: 1,
                        color: Colors.white12,
                      ),
                      Wrap(
                        spacing: 2,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.add_comment,
                            color: Colors.white,
                            size: 10,
                          ),
                          Text(
                            item["commentsNum"].toString() ?? "",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                            ),
                          )
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Icon(
                  Icons.keyboard_arrow_right,
                  color: Colors.white,
                  size: 30,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
