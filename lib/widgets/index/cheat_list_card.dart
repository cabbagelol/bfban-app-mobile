/// 作弊者列表卡片

import 'package:bfban/component/_Time/index.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/_img/index.dart';
import 'package:flutter_elui_plugin/_tip/index.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../../router/router.dart';

class CheatListCard extends StatelessWidget {
  final Map item;

  final GestureTapCallback? onTap;

  final bool? isIconView;

  final bool? isIconCommendView;

  final bool? isIconHotView;

  final double? size;

  const CheatListCard({
    Key? key,
    required this.item,
    this.size = 40,
    this.isIconView = true,
    this.isIconCommendView = true,
    this.isIconHotView = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: ClipRRect(
        borderRadius: const BorderRadius.all(
          Radius.circular(20),
        ),
        child: CircleAvatar(
          child: ExtendedImage.network(
            item["avatarLink"],
            width: size,
            height: size,
            fit: BoxFit.fill,
            cache: true,
            printError: false,
            cacheWidth: size?.toInt(),
            cacheHeight: size?.toInt(),
            loadStateChanged: (ExtendedImageState state) {
              switch (state.extendedImageLoadState) {
                case LoadState.completed:
                  return state.completedWidget;
                case LoadState.failed:
                default:
                  return Image.asset(
                    "assets/images/default-player-avatar.jpg",
                    cacheWidth: size!.toInt(),
                    cacheHeight: size!.toInt(),
                  );
              }
            },
          ),
        ),
      ),
      title: Tooltip(
        message: item["originName"],
        child: Text(
          item["originName"] ?? "",
          style: TextStyle(
            fontSize: 20,
            fontFamily: "UbuntuMono",
            color: Theme.of(context).textTheme.titleLarge!.color,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      subtitle: Wrap(
        runAlignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (item["createTime"] != null)
            Tooltip(
              message: FlutterI18n.translate(context, "list.reportTime"),
              child: TimeWidget(
                data: item["createTime"],
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
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
              margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
              height: 20,
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
              margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
              height: 20,
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
            height: 36,
            decoration: BoxDecoration(
              color: item["status"] == 1 ? Theme.of(context).colorScheme.error : Colors.green,
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
