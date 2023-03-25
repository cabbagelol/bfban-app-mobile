/// 作弊者列表卡片

import 'package:flutter/material.dart';

import 'package:bfban/utils/index.dart';

import 'package:flutter_elui_plugin/_img/index.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class CheatListCard extends StatelessWidget {
  final Map item;

  final onTap;

  final bool? isIconView;

  final bool? isIconCommendView;

  final bool? isIconHotView;

  const CheatListCard({
    Key? key,
    required this.item,
    this.isIconView = true,
    this.isIconCommendView = true,
    this.isIconHotView = false,
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
            item["originName"] ?? "",
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
          const SizedBox(width: 8),
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
          if (isIconView!)
            CheatersCardIconitem(
              n: item["viewNum"].toString(),
              i: Icons.visibility,
            ),
          if (isIconCommendView!)
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 12,
              ),
              height: 30,
              width: 1,
              color: Theme.of(context).dividerColor,
            ),
          if (isIconCommendView!)
            CheatersCardIconitem(
              n: item["commentsNum"].toString(),
              i: Icons.add_comment,
            ),
          if (isIconHotView!)
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 12,
              ),
              height: 30,
              width: 1,
              color: Theme.of(context).dividerColor,
            ),
          if (isIconHotView!)
            CheatersCardIconitem(
              n: item["hot"].toString(),
              i: Icons.local_fire_department,
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
                          FlutterI18n.translate(context, "app.basic.status.${item["status"]}"),
                          style: const TextStyle(fontSize: 12),
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
                        CheatersCardIconitem(
                          n: item["viewNum"].toString(),
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
                        CheatersCardIconitem(
                          n: item["commentsNum"].toString(),
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

class CheatersCardIconitem extends StatelessWidget {
  final String? n;
  final IconData? i;

  const CheatersCardIconitem({
    Key? key,
    this.n,
    this.i,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: <Widget>[
        Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                n!,
                style: TextStyle(
                  color: Theme.of(context).primaryTextTheme.headline1!.color,
                  fontSize: 17,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        Positioned(
          child: Opacity(
            child: Icon(
              i,
              // color: Theme.of(context).primaryTextTheme.headline1!.color,
              size: 35,
            ),
            opacity: .1,
          ),
        ),
      ],
    );
  }
}
