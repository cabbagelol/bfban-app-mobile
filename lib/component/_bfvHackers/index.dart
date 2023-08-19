import 'package:bfban/utils/index.dart';
import 'package:flutter/material.dart';

import '../../constants/api.dart';

class BfvHackersWidget extends StatefulWidget {
  Map? data;

  BfvHackersWidget({
    Key? key,
    this.data,
  }) : super(key: key);

  @override
  State<BfvHackersWidget> createState() => _BfvHackersWidgetState();
}

class _BfvHackersWidgetState extends State<BfvHackersWidget> {
  final UrlUtil _urlUtil = UrlUtil();

  late Map hackersData = {
    "hack_score_current": 0,
  };

  @override
  void initState() {
    _getBfvHackers();
    super.initState();
  }

  /// [Response]
  /// 获取bfvHackers状态
  Future _getBfvHackers() async {
    Response result = await Http.request(
      "is-hacker",
      typeUrl: "network_bfv_hackers_request",
      parame: {"name": widget.data!["originName"]},
      method: Http.GET,
    );

    setState(() {
      hackersData = result.data;
    });
  }

  /// [Event]
  /// 打开ExcursionistView
  _openExcursionistView() {
    _urlUtil.onPeUrl("${Config.apiHost["network_bfv_hackers_request"]!.baseHost}?name=${widget.data!["originName"]}");
  }

  BfvHackerScoreLevelColor _checkScoreLevels() {
    var hackScoreCurrent = hackersData["hack_score_current"];
    var hackScoreLevels = hackersData["hack_score_levels"] ?? {
      "hack": 10,
      "v_sus": 20,
      "sus": 100
    };

    if (hackScoreCurrent < hackScoreLevels["hack"]) {
      return BfvHackerScoreLevelColor(
        color: Colors.green,
        textColor: Colors.green.shade800,
      );
    } else if (hackScoreCurrent < hackScoreLevels["v_sus"]) {
      return BfvHackerScoreLevelColor(
        color: Colors.yellow,
        textColor: Colors.yellow.shade800,
      );
    } else if (hackScoreCurrent >= hackScoreLevels["sus"]) {
      return BfvHackerScoreLevelColor(
        color: Colors.red,
        textColor: Colors.red.shade900,
      );
    }
    return BfvHackerScoreLevelColor(
      color: Colors.transparent,
      textColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.data!["games"].contains("bfv")
        ? InkWell(
      child: Card(
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Image.network(
                  "https://bfvhackers.com/static/media/bfv-hacker-lookup-logo.png",
                  width: 20,
                  height: 20,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                      color: _checkScoreLevels().color!.withOpacity(.15),
                      border: Border.all(
                        color: _checkScoreLevels().color!.withOpacity(.1),
                      ),
                      borderRadius: BorderRadius.circular(3)
                  ),
                  child: Text(
                    "Hack Score: ${hackersData["hack_score_current"] ?? 0}",
                    style: TextStyle(
                        color: _checkScoreLevels().textColor
                    ),
                  ),
                ),
                const Icon(Icons.open_in_new, size: 15)
              ],
            )),
      ),
      onTap: () => _openExcursionistView(),
    )
        : Container();
  }
}

class BfvHackerScoreLevelColor {
  Color? color;
  Color? textColor;

  BfvHackerScoreLevelColor({
    this.color,
    this.textColor,
  });
}