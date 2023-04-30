import 'package:bfban/component/_gamesTag/index.dart';
import 'package:bfban/constants/api.dart';
import 'package:bfban/utils/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class RecordLinkWidget extends StatefulWidget {
  Map? data;

  RecordLinkWidget({
    Key? key,
    this.data,
  }) : super(key: key);

  @override
  State<RecordLinkWidget> createState() => _RecordLinkWidgetState();
}

class _RecordLinkWidgetState extends State<RecordLinkWidget> {
  final UrlUtil _urlUtil = UrlUtil();

  final Util _util = Util();

  List<Widget> rows = [];

  @override
  void initState() {
    super.initState();
    _generateTable();
  }

  /// [Event]
  /// 创建表
  _generateTable() {
    _generateColumn();
  }

  _generateColumn() {
    if (widget.data!.isEmpty || widget.data!["games"].isEmpty) return;
    List games = widget.data!["games"];
    List<Widget> rows = [];

    for (var i in games) {
      rows.add(Column(
        children: _generateLine([], i),
      ));
    }

    setState(() {
      this.rows = rows;
    });
  }

  List<Widget> _generateLine(List children, String gameName) {
    String platformSelect = 'origin';
    List<Widget> _children = [];
    if (widget.data!.isEmpty) return [];

    Config.recordLink["links"][gameName].forEach((platformName) {
      if (Config.recordLink["site"][platformName]["platform"][platformSelect][gameName].isNotEmpty) {
        String url = Config.recordLink["site"][platformName]["webSite"] + Config.recordLink["site"][platformName]["platform"][platformSelect][gameName];
        List<Widget> gamePlatform = [];

        for (var gamePlatformKey in Config.recordLink["site"][platformName]["platform"].entries) {
          if (Config.recordLink["site"][platformName]["platform"][gamePlatformKey.key][gameName] != null) {
            gamePlatform.add(
              InkWell(
                child: ActionChip(
                  visualDensity: const VisualDensity(horizontal: 3, vertical: -4),
                  label: Text(gamePlatformKey.key),
                ),
                onTap: () => _urlUtil.onPeUrl(
                  _util.onReplacementStringVariable(url, {
                    "id": widget.data!["originUserId"],
                    "name": widget.data!["originName"],
                  }),
                ),
              ),
            );
          }
        }

        _children.add(Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Card(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: Image.asset(
                            "assets/images/recordPlatforms/$platformName.png",
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        flex: 1,
                        child: Text(platformName),
                      ),
                      GamesTagWidget(data: [gameName.toString()]),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 3,
                    children: gamePlatform,
                  )
                ],
              ),
            ),
            const Divider(height: 1),
          ],
        ));
      }
    });

    return _children;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                FlutterI18n.translate(context, "detail.info.gameScores"),
                style: TextStyle(
                  fontSize: FontSize.xLarge.value,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: rows,
            ),
          ),
        ],
      ),
    );
  }
}
