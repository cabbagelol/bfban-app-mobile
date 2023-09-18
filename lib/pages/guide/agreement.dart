/// 协议内容

import 'package:bfban/component/_html/htmlLink.dart';
import 'package:bfban/component/_html/htmlWidget.dart';
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

  ProviderUtil providerUtil = ProviderUtil();

  bool checked = false;

  Map agreement = {
    "load": false,
    "error": 0,
    "content": "Agreement Content",
  };

  String language = "zh_CN";

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    langProvider = providerUtil.ofLang(context);
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
      httpDioValue: "app_web_site",
      method: Http.GET,
    );

    if (result.data is String && result.data != '' || result.data["error"] == null && agreement["content"] != null) {
      setState(() {
        agreement["content"] = result.data.toString();
      });
    } else {
      setState(() {
        agreement["error"] = 1;
      });
      EluiMessageComponent.error(context)(child: const Text("error"));
    }

    setState(() {
      agreement["load"] = false;
    });
  }

  /// [Event]
  /// 许可开关
  _onPermitSwitch() {
    if (agreement["load"]) return;
    setState(() {
      checked = !checked;
    });
    eventUtil.emit("disable-next", !checked);
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
                child: Wrap(
                  children: <Widget>[
                    Text(
                      FlutterI18n.translate(context, "app.guide.agreement.title"),
                      style: const TextStyle(fontSize: 25),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "($language)",
                      style: const TextStyle(fontSize: 25),
                    )
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!agreement["load"] && agreement["error"] == 1)
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                        child: Center(
                          child: GestureDetector(
                            child: Column(
                              children: [
                                Icon(Icons.refresh, size: FontSize.xxLarge.value),
                                const SizedBox(height: 15),
                                HtmlLink(url: "${Config.apis["app_web_site"]!.url}/agreement"),
                              ],
                            ),
                            onTap: () {
                              getAgreement();
                            },
                          ),
                        ),
                      ),
                    )
                  else
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: agreement["load"]
                          ? const SizedBox(
                              height: 100,
                              child: Center(
                                child: SizedBox(width: 30, height: 30, child: CircularProgressIndicator(strokeWidth: 2)),
                              ),
                            )
                          : HtmlWidget(
                              content: agreement["content"],
                              footerToolBar: false,
                            ),
                    ),
                ],
              ),
              InkWell(
                child: Opacity(
                  opacity: agreement["load"] ? .2 : 1,
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
                          onChanged: (bool? checkBoxChecked) => _onPermitSwitch(),
                        ),
                        Text(
                          FlutterI18n.translate(context, "app.guide.agree"),
                        )
                      ],
                    ),
                  ),
                ),
                onTap: () => _onPermitSwitch(),
              )
            ],
          );
        },
      ),
    );
  }
}
