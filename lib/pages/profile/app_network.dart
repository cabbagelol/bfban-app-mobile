/// 网络

import 'package:bfban/data/Url.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/_tag/tag.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

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
      if (value.url.isNotEmpty && key != "none") {
        appNetworkStatus.list!.add({
          "load": false,
          "err": 0,
          "ms": 0,
          "name": key,
          "url": value.url,
        });

        _onNetWork(value.url);
      }
    });
  }

  /// [Response]
  /// 网络检查
  _onNetWork(String url) async {
    dynamic item = appNetworkStatus.list!.where((element) => element["url"] == url).toList()[0];

    setState(() {
      item["load"] = true;
    });

    // 超时
    Future.delayed(const Duration(seconds: 2)).then((result) {
      // 如果依旧是load true，则超时
      if (item["load"]) {
        setState(() {
          item["err"] = 3;
          item["load"] = false;
        });
      }
    });

    Response result = await Http.dio.head(url);

    setState(() {
      if (result.statusCode == 200) {
        item["err"] = 2;
      } else {
        item["err"] = 1;
      }

      // load
      item["statusCode"] = result.statusCode ?? "NONE";
      item["load"] = false;
    });

    return result;
  }

  /// [Event]
  /// 刷新
  Future _onRefresh() async {
    appNetworkStatus.list!.clear();
    await _onReady();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "app.networkDetection.title")),
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
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      title: Text(
                        e["name"].toString().toUpperCase(),
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      subtitle: Text(
                        e["url"].toString(),
                        style: TextStyle(
                          color: Theme.of(context).textTheme.displayMedium!.color,
                        ),
                      ),
                      leading: IndexedStack(
                        index: e["err"],
                        children: [
                          EluiTagComponent(
                            value: FlutterI18n.translate(context, "app.networkDetection.status.0"),
                            theme: EluiTagTheme(
                              backgroundColor: Theme.of(context).appBarTheme.backgroundColor!,
                            ),
                            color: EluiTagType.none,
                            size: EluiTagSize.no2,
                          ),
                          EluiTagComponent(
                            value: FlutterI18n.translate(context, "app.networkDetection.status.2"),
                            color: EluiTagType.error,
                            size: EluiTagSize.no2,
                          ),
                          EluiTagComponent(
                            value: FlutterI18n.translate(context, "app.networkDetection.status.1"),
                            color: EluiTagType.succeed,
                            size: EluiTagSize.no2,
                          ),
                          EluiTagComponent(
                            value: FlutterI18n.translate(context, "app.networkDetection.status.3"),
                            color: EluiTagType.warning,
                            size: EluiTagSize.no2,
                          )
                        ],
                      ),
                      trailing: e["load"]
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
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
