import 'package:bfban/component/_loading/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/_tag/tag.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

import '/constants/api.dart';
import '/data/index.dart';
import '/utils/index.dart';

class AppNetworkPage extends StatefulWidget {
  const AppNetworkPage({super.key});

  @override
  AppNetworkPageState createState() => AppNetworkPageState();
}

class AppNetworkPageState extends State<AppNetworkPage> {
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
        AppNetworkItem appNetworkItem = AppNetworkItem(
          load: false,
          statusCode: 0,
          statusLogs: [],
          status: 0,
          ms: 0,
          name: key,
        );

        appNetworkItem.url = value.url;
        appNetworkStatus.list!.add(appNetworkItem);

        _onNetWork(appNetworkItem.url);
      }
    });
  }

  /// [Response]
  /// 网络检查
  _onNetWork(String url) async {
    List<AppNetworkItem> items = appNetworkStatus.list!.where((element) => element.url == url).toList();

    if (items.isEmpty) return;
    AppNetworkItem item = items[0];

    setState(() {
      item.load = true;
    });

    Future headFuture = Http.dio.head(url);
    headFuture.catchError((err) {
      setState(() {
        item.statusCode = err.response.statusCode ??= 100;
        item.statusLogs.add({
          "message": "${err.error}",
          "time": DateTime.now().millisecondsSinceEpoch,
        });
        item.status = 2;
        item.load = false;
      });

      return -1;
    });

    Response result = await headFuture;

    setState(() {
      if (result.statusCode == 200) {
        item.status = 2;
      } else if (result.statusCode! >= 400 && result.statusCode! <= 500) {
        item.status = 1;
      } else {
        item.status = 1;
      }

      // load
      item.statusCode = result.statusCode!;
      item.load = false;
    });

    return result;
  }

  /// [Event]
  /// 刷新
  Future _onRefresh() async {
    appNetworkStatus.list!.clear();
    await _onReady();
  }

  /// [Event]
  /// 编辑网络地址
  void _opEditNetwork(AppNetworkItem i) async {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      isDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, onState) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
              ),
              child: ListBody(
                children: [
                  TextField(
                    controller: TextEditingController(text: i.name),
                    decoration: InputDecoration(
                      hintText: i.name,
                      prefixIcon: Icon(Icons.title),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (data) {
                      onState(() {
                        i.name = data;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField(
                    decoration: InputDecoration(
                      hintText: i.host,
                      prefixIcon: Icon(Icons.https),
                      border: OutlineInputBorder(),
                    ),
                    borderRadius: BorderRadius.circular(40),
                    dropdownColor: Theme.of(context).bottomAppBarTheme.color,
                    style: Theme.of(context).dropdownMenuTheme.textStyle,
                    value: i.protocol.toString(),
                    items: i.protocols.map((protocol) => DropdownMenuItem(value: protocol, child: Text(protocol))).toList(),
                    onChanged: (currentProtocol) {
                      onState(() {
                        i.protocol = currentProtocol.toString();
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: TextEditingController(text: i.host),
                    decoration: InputDecoration(
                      hintText: i.host,
                      prefixIcon: Icon(Icons.web_asset_sharp),
                      border: OutlineInputBorder(),
                    ),
                    minLines: 1,
                    maxLines: 3,
                    onChanged: (data) {
                      setState(() {
                        i.host = data;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: TextEditingController(text: i.pathname),
                    decoration: InputDecoration(
                      hintText: "path",
                      hintStyle: TextStyle(color: Colors.white38),
                      prefixIcon: Icon(Icons.insert_link),
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                    minLines: 2,
                    maxLines: 5,
                    onChanged: (data) {
                      setState(() {
                        i.pathname = data;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        Config.apis.addAll({i.name: i.toBaseUrl});
                      });
                      _onRefresh();
                      Navigator.of(context).pop();
                    },
                    child: SizedBox(
                      height: 50,
                      child: Icon(Icons.done),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "app.networkDetection.title")),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Consumer<AppInfoProvider>(builder: (BuildContext context, data, Widget? child) {
          return Column(
            children: [
              const SizedBox(height: 10),
              Expanded(
                flex: 1,
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    var i = appNetworkStatus.list![index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      title: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.start,
                        spacing: 3,
                        runSpacing: 3,
                        children: [
                          IndexedStack(
                            index: i.status,
                            children: [
                              EluiTagComponent(
                                value: FlutterI18n.translate(context, "app.networkDetection.status.0"),
                                theme: EluiTagTheme(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
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
                          Text(
                            i.name.trim().toUpperCase(),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SelectionArea(
                            child: Text(
                              i.host.toString(),
                              style: TextStyle(
                                color: Theme.of(context).textTheme.displayMedium!.color,
                              ),
                            ),
                          ),
                          if (i.statusLogs.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 10),
                              child: Column(
                                children: i.statusLogs.indexed.map((log) {
                                  return Wrap(
                                    spacing: 5,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      Text("${log.$1}"),
                                      const SizedBox(
                                        width: 4,
                                        child: Divider(height: 1, thickness: 1),
                                      ),
                                      Text(log.$2["message"].toString()),
                                      const SizedBox(
                                        width: 15,
                                        child: Divider(height: 1, thickness: 1),
                                      ),
                                      Text(log.$2["time"].toString()),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      ),
                      trailing: i.load
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: LoadingWidget(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(i.statusCode.toString()),
                      onLongPress: () => _opEditNetwork(i),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) => Divider(),
                  itemCount: appNetworkStatus.list!.length,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
