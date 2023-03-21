import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/_img/index.dart';

import '../../component/_privilegesTag/index.dart';
import '../../utils/date.dart';

class SearchInUserCard extends StatelessWidget {
  final item;

  final onTap;

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
        child: CircleAvatar(
          child: EluiImgComponent(
            width: 40,
            height: 40,
            src: item["userAvatar"] ?? "",
          ),
        ),
      ),
      title: Wrap(
        spacing: 5,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          Text(
            item["username"],
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
            Date().getTimestampTransferCharacter(item["joinTime"])["Y_D_M"],
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
      trailing: Container(
        constraints: BoxConstraints(maxWidth: 100),
        child: PrivilegesTagWidget(data: item["privilege"]),
      ),
      onTap: () => onTap(),
    );
  }
}
