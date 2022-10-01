/// 网络

import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/_tag/tag.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../../constants/api.dart';
import '../../data/index.dart';
import '../../utils/index.dart';

class AppNetworkPage extends StatefulWidget {
  const AppNetworkPage({Key? key}) : super(key: key);

  @override
  _AppNetworkPageState createState() => _AppNetworkPageState();
}

class _AppNetworkPageState extends State<AppNetworkPage> {
  final UrlUtil _urlUtil = UrlUtil();

  AppNetworkStatus appNetworkStatus = AppNetworkStatus(
    list: [],
  );

  @override
  initState() {
    _onReady();

    super.initState();
  }

  /// [Event]
  /// 初始网络
  _onReady() async {
    Config.apiHost.forEach((key, value) {
      if (value.isNotEmpty) {
        appNetworkStatus.list!.add({
          "load": false,
          "err": 0,
          "ms": 0,
          "name": key,
          "url": value,
        });

        _onNetWork(value);
      }

      return value;
    });
  }

  /// [Response]
  /// 网络检查
  _onNetWork(String url) async {
    dynamic item = appNetworkStatus.list!
        .where((element) => element["url"] == url)
        .toList()[0];

    setState(() {
      item["load"] = true;
    });

    Response result = await Http.request(
      url,
      typeUrl: "none",
      method: Http.GET,
    );

    setState(() {
      if (result.data.toString().isNotEmpty) {
        item["err"] = 2;
      } else {
        item["err"] = 1;
      }

      // load
      item["statusCode"] = result.statusMessage ?? "NONE";
      item["load"] = false;
    });

    return result;
  }

  /// [Event]
  /// 刷新
  Future _onRefresh() async {
    appNetworkStatus.list = [];
    return await _onReady();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translate("networkDetection.title")),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Expanded(
              flex: 1,
              child: ListView(
                children: appNetworkStatus.list!.map((e) {
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    child: ListTile(
                      title: Text(
                        "[${e["statusCode"].toString()}] " +
                            e["name"].toString().toUpperCase(),
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      subtitle: Text(e["url"].toString()),
                      leading: IndexedStack(
                        index: e["err"],
                        children: [
                          EluiTagComponent(
                            value: translate("networkDetection.status.0"),
                            theme: EluiTagTheme(
                              backgroundColor: Theme.of(context)
                                  .appBarTheme
                                  .backgroundColor!,
                            ),
                            color: EluiTagType.none,
                            size: EluiTagSize.no2,
                          ),
                          EluiTagComponent(
                            value: translate("networkDetection.status.2"),
                            color: EluiTagType.error,
                            size: EluiTagSize.no2,
                          ),
                          EluiTagComponent(
                            value: translate("networkDetection.status.1"),
                            color: EluiTagType.succeed,
                            size: EluiTagSize.no2,
                          )
                        ],
                      ),
                      trailing: e["load"]
                          ? const CircularProgressIndicator(
                              strokeWidth: 2,
                            )
                          : null,
                      onTap: () {
                        _urlUtil.onPeUrl(e["src"]);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
