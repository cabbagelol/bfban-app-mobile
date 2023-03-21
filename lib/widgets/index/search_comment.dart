import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/_img/index.dart';

import '../../utils/date.dart';

class SearchCommentCard extends StatelessWidget {
  final item;

  final onTap;

   SearchCommentCard({
    Key? key,
    required this.item,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const ClipRRect(
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
        child: CircleAvatar(
          child: EluiImgComponent(
            width: 40,
            height: 40,
            src: "",
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

        ],
      ),
      onTap: () => onTap(),
    );
  }
}
