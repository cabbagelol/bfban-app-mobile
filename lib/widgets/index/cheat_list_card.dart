/// 作弊者列表卡片

import 'package:bfban/component/_Time/index.dart';
import 'package:flutter/material.dart';
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
      minVerticalPadding: 10,
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
      title: Tooltip(
        message: item["originName"],
        child: Text(
          item["originName"] ?? "",
          style: TextStyle(
            color: Theme.of(context).textTheme.headlineMedium!.color,
            fontSize: 20,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      subtitle: Wrap(
        runAlignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            "${FlutterI18n.translate(context, "list.reportTime")}:\t",
            style: TextStyle(
              color: Theme.of(context).textTheme.displayMedium!.color,
              fontSize: 9,
            ),
          ),
          if (item["createTime"] != null)
            TimeWidget(
              data: item["createTime"],
              style: TextStyle(
                color: Theme.of(context).textTheme.displayMedium!.color,
                fontSize: 9,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          const SizedBox(width: 8),
          Text(
            "${FlutterI18n.translate(context, "list.updateTime")}:\t",
            style: TextStyle(
              color: Theme.of(context).textTheme.displayMedium!.color,
              fontSize: 9,
            ),
          ),
          if (item["updateTime"] != null)
            TimeWidget(
              data: item["updateTime"],
              style: TextStyle(
                color: Theme.of(context).textTheme.displayMedium!.color,
                fontSize: 9,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
        ],
      ),
      trailing: Wrap(
        runAlignment: WrapAlignment.center,
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
              color: Theme.of(context).dividerTheme.color!,
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
              color: Theme.of(context).dividerTheme.color!,
            ),
          if (isIconHotView!)
            CheatersCardIconitem(
              n: item["hot"].toString(),
              i: Icons.local_fire_department,
            ),
          const SizedBox(width: 15),
          Container(
            width: 5,
            height: 35,
            decoration: BoxDecoration(
              color: item["status"] == 1 ? Colors.red : Colors.green,
              borderRadius: BorderRadius.circular(3),
            ),
          )
        ],
      ),
      onTap: () {
        Routes.router!.navigateTo(
          context,
          '/player/personaId/${item["originPersonaId"]}',
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
                  color: Theme.of(context).textTheme.bodyMedium!.color,
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
            child: Icon(i, size: 30),
          ),
        ),
      ],
    );
  }
}
