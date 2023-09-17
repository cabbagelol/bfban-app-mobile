import 'package:bfban/component/_html/htmlLink.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class VideoLink extends StatelessWidget {
  Map data;

  VideoLink({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: data["videoLink"].toString().isEmpty,
      child: Column(
        children: [
          Column(
            children: data["videoLink"].toString().split(",").asMap().entries.map((i) {
              return Container(
                margin: const EdgeInsets.only(bottom: 5),
                child: Row(
                  children: [
                    Card(
                      margin: EdgeInsets.zero,
                      color: Theme.of(context).primaryColorDark.withOpacity(.2),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              FlutterI18n.translate(context, "detail.info.videoLink"),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      flex: 1,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: (MediaQuery.of(context).size.width),
                        ),
                        child: HtmlLink(
                          url: i.value,
                          style: const TextStyle(fontSize: 12),
                          softWrap: false,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      color: Theme.of(context).disabledColor.withOpacity(.1),
                      constraints: const BoxConstraints(minWidth: 30, minHeight: 2),
                    ),
                    Text("${i.key + 1}"),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
