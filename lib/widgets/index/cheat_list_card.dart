/// 作弊者列表卡片

import 'package:flutter/material.dart';

import 'package:bfban/utils/index.dart';

import 'package:flutter_elui_plugin/_img/index.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../../router/router.dart';

class CheatListCard extends StatelessWidget {
  final Map item;

  final GestureTapCallback? onTap;

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
        ],
      ),
      subtitle: Wrap(
        children: [
          if (item["createTime"] != null)
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
          if (item["updateTime"] != null)
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
      onTap: () {
        Routes.router!.navigateTo(
          context,
          '/detail/player/${item["originPersonaId"]}',
        );
        if (onTap != null) onTap!();
      },
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
            opacity: .1,
            child: Icon(
              i,
              // color: Theme.of(context).primaryTextTheme.headline1!.color,
              size: 35,
            ),
          ),
        ),
      ],
    );
  }
}
