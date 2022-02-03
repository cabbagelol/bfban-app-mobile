/// 协议内容

import 'package:flutter/material.dart';

import 'package:flutter_elui_plugin/elui.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../../constants/api.dart';
import '../../utils/http.dart';

class GuideAgreementPage extends StatefulWidget {
  final Function onChanged;

  GuideAgreementPage({
    Key? key,
    required this.onChanged,
  }) : super(key: key);

  @override
  _agreementPageState createState() => _agreementPageState();
}

class _agreementPageState extends State<GuideAgreementPage> {
  Map agreement = {
    "content": "",
  };

  _agreementPageState() {
    getAgreement();
  }

  ///
  /// 获取协议
  getAgreement() async {
    Response result = await Http.request(
      Config.apiHost["web_site"] + "/agreement/zh.html",
      typeUrl: "",
      method: Http.GET,
    );

    setState(() {
      agreement["content"] = result.data.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Column(
          children: [
            Image.asset(
              "assets/images/bfban-logo.png",
              width: 60,
              height: 60,
            ),
            const SizedBox(
              height: 40,
            ),
            Card(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Html(data: agreement["content"] ?? translate("guide.agreement.content")),
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
              translate("guide.agree"),
            ),
            onChanged: (bool checked) => widget.onChanged(checked),
          ),
        ),
      ],
    );
  }
}
