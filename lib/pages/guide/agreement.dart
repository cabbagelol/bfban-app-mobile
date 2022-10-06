/// 协议内容

import 'package:bfban/utils/index.dart';
import 'package:flutter/material.dart';

import 'package:flutter_elui_plugin/elui.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

import '../../constants/api.dart';
import '../../provider/translation_provider.dart';
import '../../utils/http.dart';

class GuideAgreementPage extends StatefulWidget {
  final Function onChanged;

  const GuideAgreementPage({
    Key? key,
    required this.onChanged,
  }) : super(key: key);

  @override
  _AgreementPageState createState() => _AgreementPageState();
}

class _AgreementPageState extends State<GuideAgreementPage> {
  Map agreement = {
    "load": false,
    "content": "Agreement Content",
  };

  String language = "zh";

  @override
  void initState() {
    super.initState();
    getAgreement();
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

    if (result.data.toString().isEmpty) {
      setState(() {
        agreement["content"] = result.data.toString();
      });
    }

    setState(() {
      agreement["load"] = false;
    });
  }

  /// [Event]
  openAgreement () {
    UrlUtil().onPeUrl(Config.apiHost["app_web_site"] + "/agreement/${language}.html");
  }

  @override
  Widget build(BuildContext context) {
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
                      style: const TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                      ),
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
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      child: GestureDetector(
                        child: Html(data: agreement["content"]),
                        onLongPressCancel: () {
                          openAgreement();
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                ),
                child: EluiCheckboxComponent(
                  color: Theme.of(context).colorScheme.primary,
                  child: Text(
                    FlutterI18n.translate(context, "app.guide.agree"),
                  ),
                  onChanged: (bool checked) => widget.onChanged(checked),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
