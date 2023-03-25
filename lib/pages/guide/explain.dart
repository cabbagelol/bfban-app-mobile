/// 说明

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:bfban/widgets/news/index.dart';
import 'package:flutter_elui_plugin/_load/index.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

import '../../constants/api.dart';
import '../../provider/translation_provider.dart';
import '../../utils/http.dart';

class GuideExplainPage extends StatefulWidget {
  const GuideExplainPage({Key? key}) : super(key: key);

  @override
  _ExplainPageState createState() => _ExplainPageState();
}

class _ExplainPageState extends State<GuideExplainPage> with AutomaticKeepAliveClientMixin {
  bool load = false;

  List news = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    getNews();
  }

  /// [Response]
  /// 获取新闻
  getNews() async {
    setState(() {
      load = true;
    });

    Response result = await Http.request(
      "json/news.json",
      typeUrl: "app_web_site",
      method: Http.GET,
    );

    if (result.data.toString().isNotEmpty) {
      setState(() {
        news = result.data["news"];
      });
    }

    setState(() {
      load = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Consumer<TranslationProvider>(
        builder: (BuildContext context, data, Widget? child) {
          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      FlutterI18n.translate(context, "app.setting.versions.title"),
                      style: const TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (load)
                      ELuiLoadComponent(
                        type: "line",
                        lineWidth: 1,
                        color: Theme.of(context).textTheme.subtitle1!.color!,
                        size: 16,
                      ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: news.map((i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 35),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  i["username"],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Opacity(
                                opacity: .8,
                                child: Text(i["time"]),
                              )
                            ],
                          ),
                          const SizedBox(height: 5),
                          Column(
                            children: i["content"].map<Widget>((content) {
                              return Html(
                                data: content,
                                style: {"*": Style(margin: Margins.zero)},
                              );
                            }).toList(),
                          )
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
