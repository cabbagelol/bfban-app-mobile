/// 作弊者列表卡片

import 'package:flutter/material.dart';

import 'package:bfban/utils/index.dart';
import 'package:bfban/constants/api.dart';

import 'package:flutter_elui_plugin/_img/index.dart';
import 'package:flutter_translate/flutter_translate.dart';

class CheatListCard extends StatelessWidget {
  final item;

  final onTap;

  /// 进度状态
  final Map startusIng = Config.startusIng;

  CheatListCard({
    Key? key,
    required this.item,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: const BorderRadius.all(
          Radius.circular(20),
        ),
        child: CircleAvatar(
          child: EluiImgComponent(
            width: 40,
            height: 40,
            src: item["avatarLink"],
          ),
        ),
      ),
      title: Wrap(
        spacing: 5,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          Text(
            item["originName"],
            style: TextStyle(
              color: Theme.of(context).primaryTextTheme.headline1!.color,
              fontSize: 20,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,
              borderRadius: const BorderRadius.all(
                Radius.circular(2),
              ),
            ),
            child: Text(
              translate("basic.status.${item["status"]}"),
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
      subtitle: Wrap(
        children: [
          Text(
            Date().getTimestampTransferCharacter(item["createTime"])["Y_D_M"],
            style: TextStyle(
              color: Theme.of(context).textTheme.subtitle2!.color,
              fontSize: 9,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          SizedBox(width: 8),
          Text(
            Date().getTimestampTransferCharacter(item["updateTime"])["Y_D_M"],
            style: TextStyle(
              color: Theme.of(context).textTheme.subtitle2!.color,
              fontSize: 9,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
      trailing: Wrap(
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
      onTap: () => onTap(),
    );

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
                    child: CircleAvatar(
                      child: EluiImgComponent(
                        width: 40,
                        height: 40,
                        src: item["avatarLink"],
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
                      Container(
                        padding: const EdgeInsets.only(
                          left: 5,
                          right: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).backgroundColor,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(2),
                          ),
                        ),
                        child: Text(
                          translate("basic.status.${item["status"]}"),
                          style: TextStyle(fontSize: 12),
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
                        "最后更新:" + Date().getTimestampTransferCharacter(item["updateTime"])["Y_D_M"],
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
    Key? key,
    this.n,
    this.e,
    this.i,
  }) : super(key: key);

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
                color: Theme.of(context).primaryTextTheme.headline4!.color,
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
