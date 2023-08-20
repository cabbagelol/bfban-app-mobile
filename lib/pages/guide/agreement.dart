/// 协议内容

import 'package:bfban/provider/translation_provider.dart';
import 'package:bfban/utils/index.dart';
import 'package:flutter/material.dart';

import 'package:flutter_elui_plugin/elui.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

import '../../constants/api.dart';

class GuideAgreementPage extends StatefulWidget {
  const GuideAgreementPage({
    Key? key,
  }) : super(key: key);

  @override
  AgreementPageState createState() => AgreementPageState();
}

class AgreementPageState extends State<GuideAgreementPage> with AutomaticKeepAliveClientMixin {
  TranslationProvider? langProvider;

  bool checked = false;

  Map agreement = {
    "load": false,
    "content": "Agreement Content",
  };

  String language = "zh_CN";

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    langProvider = ProviderUtil().ofLang(context);

    language = langProvider!.currentLang;
    getAgreement();

    super.initState();
  }


  /// [Response]
  /// 获取协议
  getAgreement() async {
    setState(() {
      agreement["load"] = true;
    });

    Response result = await Http.request(
      "agreement/$language.html",
      typeUrl: "app_web_site",
      method: Http.GET,
    );

    if (result.data.toString().isNotEmpty) {
      setState(() {
        agreement["content"] = result.data.toString();
      });
    }

    setState(() {
      agreement["load"] = false;
    });
  }

  /// [Event]
  openAgreement() {
    UrlUtil().onPeUrl("${Config.apiHost["app_web_site"]!.url}/agreement/$language.html");
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Consumer<TranslationProvider>(
        builder: (BuildContext context, TranslationProvider data, Widget? child) {
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
                      FlutterI18n.translate(context, "app.guide.agreement.title"),
                      style: const TextStyle(fontSize: 25),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    elevation: 0,
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: agreement["load"]
                        ? SizedBox(
                            height: 100,
                            child: ELuiLoadComponent(
                              type: "line",
                              color: Theme.of(context).appBarTheme.backgroundColor!,
                              size: 17,
                              lineWidth: 2,
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.all(5),
                            child: GestureDetector(
                              child: Html(data: agreement["content"], shrinkWrap: true),
                            ),
                          ),
                  ),
                ],
              ),
              InkWell(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                  ),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Checkbox(
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                        value: checked,
                        onChanged: (bool? checkBoxChecked) {
                          setState(() {
                            checked = checkBoxChecked!;
                          });
                        },
                      ),
                      Text(
                        FlutterI18n.translate(context, "app.guide.agree"),
                      )
                    ],
                  ),
                ),
                onTap: () {
                  setState(() {
                    checked = !checked;
                  });
                },
              )
            ],
          );
        },
      ),
    );
  }
}
