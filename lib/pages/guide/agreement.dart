/// 协议内容

import 'package:flutter/material.dart';

import 'package:flutter_elui_plugin/elui.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

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
    "content": "",
  };

  _AgreementPageState() {
    getAgreement();
  }

  /// [Response]
  /// 获取协议
  getAgreement() async {
    setState(() {
      agreement["load"] = true;
    });

    Response result = await Http.request(
      "agreement/zh.html",
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

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Column(
          children: [
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: 200,
                ),
                child: agreement["load"] ? Text("load") : Html(data: agreement["content"]),
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
  }
}
