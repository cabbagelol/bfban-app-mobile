import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../../utils/index.dart';

class VideoLink extends StatelessWidget {
  Map data;

  final UrlUtil _urlUtil = UrlUtil();

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
                      child: Row(
                        children: [
                          GestureDetector(
                            child: const Icon(Icons.link, size: 15),
                            onTap: () => _urlUtil.onPeUrl(i.value.toString()),
                          ),
                          Expanded(
                            flex: 1,
                            child: GestureDetector(
                              child: Text(
                                i.value.toString(),
                                style: const TextStyle(fontSize: 12),
                                softWrap: true,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () {
                                _urlUtil.onPeUrl(i.value.toString());
                              },
                            ),
                          ),
                        ],
                      ),
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
