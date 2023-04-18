/// 网络

import 'package:bfban/data/Url.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/_input/index.dart';
import 'package:flutter_elui_plugin/_message/index.dart';
import 'package:flutter_elui_plugin/_tag/tag.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

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
        AppNetworkItem appNetworkItem = AppNetworkItem(
          load: false,
          status: 0,
          ms: 0,
          name: key,
        );
        appNetworkItem.url = value.url;

        appNetworkStatus.list!.add(appNetworkItem);

        _onNetWork(value.url);
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
    headFuture.ignore();
    headFuture.catchError((err) {
      EluiMessageComponent.warning(context)(
        child: Text("$url:${err.error}"),
        duration: 3000,
      );
      setState(() {
        item.statusCode = err.response.statusCode;
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
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, onState) {
            return AlertDialog(
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    TextField(
                      controller: TextEditingController(text: i.name),
                      decoration: InputDecoration(
                        hintText: i.name,
                        border: InputBorder.none,
                      ),
                      onChanged: (data) {
                        setState(() {
                          i.name = data;
                        });
                      },
                    ),
                    DropdownButton(
                      isExpanded: true,
                      dropdownColor: Theme.of(context).bottomAppBarTheme.color,
                      style: Theme.of(context).dropdownMenuTheme.textStyle,
                      value: i.protocol.toString(),
                      items: i.protocols
                          .map((protocol) => DropdownMenuItem(
                                value: protocol,
                                child: Text(protocol),
                              ))
                          .toList(),
                      onChanged: (currentProtocol) {
                        onState(() {
                          i.protocol = currentProtocol.toString();
                        });
                      },
                    ),
                    TextField(
                      controller: TextEditingController(text: i.host),
                      decoration: InputDecoration(
                        hintText: i.host,
                        border: InputBorder.none,
                      ),
                      minLines: 1,
                      maxLines: 3,
                      onChanged: (data) {
                        setState(() {
                          i.host = data;
                        });
                      },
                    ),
                    TextField(
                      controller: TextEditingController(text: i.pathname),
                      decoration: const InputDecoration(
                        hintText: "path",
                        border: InputBorder.none,
                      ),
                      minLines: 2,
                      maxLines: 5,
                      onChanged: (data) {
                        setState(() {
                          i.pathname = data;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      Config.apis.addAll({i.name: i.toBaseUrl});
                    });
                    _onRefresh();
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
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
                child: ListView(
                  children: appNetworkStatus.list!.map((AppNetworkItem i) {
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                            const SizedBox(height: 5),
                            Text(
                              i.name.toString().toUpperCase(),
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ],
                        ),
                        subtitle: SelectionArea(
                          child: Text(
                            i.url.toString(),
                            style: TextStyle(
                              color: Theme.of(context).textTheme.displayMedium!.color,
                            ),
                          ),
                        ),
                        trailing: i.load
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(i.statusCode.toString()),
                        onLongPress: () => _opEditNetwork(i),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
