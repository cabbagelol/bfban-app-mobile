// ignore_for_file: must_be_immutable

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

class _BfvHackersWidgetState extends State<BfvHackersWidget> with AutomaticKeepAliveClientMixin {
  final UrlUtil _urlUtil = UrlUtil();

  Storage storage = Storage();

  String NAME = "bfvHackersCache";

  bool hackerLoad = false;

  Map hackersData = {
    "hack_score_current": 0,
  };

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    ready();
    super.initState();
  }

  ready() async {
    StorageData cacheMapItem = await storage.get(NAME);

    // 没有缓冲从接口调用
    if (cacheMapItem.code != 0 || cacheMapItem.value[widget.data!["originPersonaId"]] == null) {
      return _getBfvHackers();
    }

    // 从缓存读取
    setState(() {
      hackersData = cacheMapItem.value[widget.data!["originPersonaId"]];
    });

    // 超过限制缓存时间
    if (cacheMapItem.value[widget.data!["originPersonaId"]]['creationCacheTime'] == null) return;
    int now = DateTime.now().millisecondsSinceEpoch;
    int expirationTime = DateTime(cacheMapItem.value[widget.data!["originPersonaId"]]['creationCacheTime']).add(const Duration(days: 3)).millisecondsSinceEpoch;
    if (expirationTime >= now) _getBfvHackers();
  }

  /// [Response]
  /// 获取bfvHackers状态
  Future _getBfvHackers() async {
    Map cacheMap = {};
    setState(() {
      hackerLoad = true;
    });

    Response result = await Http.request(
      "is-hacker",
      httpDioValue: "network_bfv_hackers_request",
      parame: {"name": widget.data!["originName"]},
      method: Http.GET,
    );

    if (mounted) {
      setState(() {
        hackerLoad = false;
        if (result.data != null) {
          hackersData = result.data as Map;
        }
      });
    }

    if (widget.data!.isNotEmpty && widget.data!["originPersonaId"] != null) {
      hackersData['creationCacheTime'] = DateTime.now().millisecondsSinceEpoch;
      cacheMap[widget.data!["originPersonaId"]] = hackersData;
      storage.set(NAME, value: cacheMap);
    }
  }

  /// [Event]
  /// 打开ExcursionistView
  _openExcursionistView() {
    _urlUtil.onPeUrl("${Config.apiHost["network_bfv_hackers_request"]!.baseHost}?name=${widget.data!["originName"]}");
  }

  BfvHackerScoreLevelColor _checkScoreLevels() {
    var hackScoreCurrent = hackersData["hack_score_current"] ?? 0;
    var hackScoreLevels = hackersData["hack_score_levels"] ?? {"hack": 10, "v_sus": 20, "sus": 100};

    if (!hackerLoad && hackScoreCurrent < hackScoreLevels["hack"]) {
      return BfvHackerScoreLevelColor(
        color: Colors.green,
        textColor: Colors.green,
      );
    } else if (!hackerLoad && hackScoreCurrent < hackScoreLevels["v_sus"]) {
      return BfvHackerScoreLevelColor(
        color: Colors.yellow,
        textColor: Colors.yellow.shade800,
      );
    } else if (!hackerLoad && hackScoreCurrent >= hackScoreLevels["sus"]) {
      return BfvHackerScoreLevelColor(
        color: Colors.red,
        textColor: Colors.red.shade900,
      );
    }
    return BfvHackerScoreLevelColor(
      color: Colors.grey,
      textColor: Theme.of(context).textTheme.titleMedium!.color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.data!["games"].contains("bfv")
        ? InkWell(
      child: AnimatedContainer(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: _checkScoreLevels().color!.withOpacity(.2),
                border: Border.all(
                  color: _checkScoreLevels().color!.withOpacity(.5),
                ),
                borderRadius: BorderRadius.circular(3),
              ),
              duration: const Duration(milliseconds: 350),
              child: Wrap(
                spacing: 5,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/recordPlatforms/Bfv-Hackers.png",
                    width: 15,
                    height: 15,
                  ),
                  if (hackerLoad)
                    Container(
                      width: 25,
                      margin: const EdgeInsets.symmetric(vertical: 9),
                      child: const LinearProgressIndicator(minHeight: 2),
                    )
                  else
                    Text(
                      "${hackersData["hack_score_current"] ?? 0}",
                      style: TextStyle(color: _checkScoreLevels().textColor),
                    ),
                  Container(
                    width: 1,
                    height: 15,
                    color: _checkScoreLevels().color!.withOpacity(.1),
                  ),
                  const Icon(Icons.open_in_new, size: 15)
                ],
              ),
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
