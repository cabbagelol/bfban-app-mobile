import 'package:bfban/component/_userAvatar/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/_img/index.dart';

import '../../component/_privilegesTag/index.dart';
import '../../utils/date.dart';

class SearchInUserCard extends StatelessWidget {
  final Map? item;

  final Function? onTap;

  const SearchInUserCard({
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
        child: UserAvatar(
          src: item!["userAvatar"] ?? "",
          size: 40,
        ),
      ),
      title: Wrap(
        spacing: 5,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          Text(
            item!["username"] ?? "",
            style: TextStyle(
              color: Theme.of(context).primaryTextTheme.displayLarge!.color,
              fontSize: 20,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: const BorderRadius.all(
                Radius.circular(2),
              ),
            ),
          ),
        ],
      ),
      subtitle: Wrap(
        children: [
          if (item!["joinTime"] != null)
            Text(
              Date().getTimestampTransferCharacter(item!["joinTime"])["Y_D_M"],
              style: TextStyle(
                color: Theme.of(context).textTheme.titleSmall!.color,
                fontSize: 9,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          const SizedBox(width: 8),
          if (item!["updateTime"] != null)
            Text(
              Date().getTimestampTransferCharacter(item!["updateTime"])["Y_D_M"],
              style: TextStyle(
                color: Theme.of(context).textTheme.titleSmall!.color,
                fontSize: 9,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
        ],
      ),
      trailing: Container(
        constraints: const BoxConstraints(maxWidth: 200),
        child: PrivilegesTagWidget(data: item!["privilege"]),
      ),
      onTap: () => onTap!(),
    );
  }
}
