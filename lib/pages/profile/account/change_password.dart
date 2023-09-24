import 'package:bfban/data/Captcha.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/elui.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../../../component/_captcha/index.dart';
import '../../../constants/api.dart';
import '../../../provider/userinfo_provider.dart';
import '../../../utils/index.dart';

class changePasswordPage extends StatefulWidget {
  const changePasswordPage({key});

  @override
  State<changePasswordPage> createState() => _changePasswordPageState();
}

class _changePasswordPageState extends State<changePasswordPage> {
  Captcha captcha = Captcha();

  bool load = false;

  String newpassword = "";

  String oldpassword = "";

  @override
  void initState() {
    super.initState();
  }

  /// [Response]
  /// 获取账户信息
  void _onSaveChangePassword() async {
    if (load) return;
    if (newpassword.isEmpty || oldpassword.isEmpty || captcha.value.isEmpty) {
      return;
    }

    setState(() {
      load = true;
    });

    Response result = await Http.request(Config.httpHost["user_changePassword"], method: Http.POST, data: {
      "data": {
        "newpassword": newpassword,
        "oldpassword": oldpassword,
      },
      "encryptCaptcha": captcha.hashCode,
      "captcha": captcha.value
    });

    if (result.data["success"] == 1) {
      UserInfoProvider().accountQuit(context);
    }

    setState(() {
      load = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "reset.title")),
        actions: [
          IconButton(
            onPressed: () {
              _onSaveChangePassword();
            },
            icon: load
                ? ELuiLoadComponent(
                    type: "line",
                    lineWidth: 2,
                    color: Theme.of(context).progressIndicatorTheme.color!,
                    size: 20,
                  )
                : const Icon(Icons.done),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          AutofillGroup(
            child: Column(
              children: [
                Card(
                  child: EluiInputComponent(
                    title: FlutterI18n.translate(context, "reset.form.oldPassword"),
                    placeholder: FlutterI18n.translate(context, "reset.form.oldPassword"),
                    value: "",
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.password],
                    onChange: (String value) {
                      setState(() {
                        if (value.isEmpty) return;
                        oldpassword = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 5),
                Card(
                  child: EluiInputComponent(
                    title: FlutterI18n.translate(context, "reset.form.newPassword"),
                    placeholder: FlutterI18n.translate(context, "reset.form.newPassword"),
                    value: "",
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.newPassword],
                    onChange: (String value) {
                      setState(() {
                        if (value.isEmpty) return;
                        newpassword = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  child: EluiInputComponent(
                    title: FlutterI18n.translate(context, "captcha.title"),
                    placeholder: FlutterI18n.translate(context, "captcha.title"),
                    value: "",
                    textInputAction: TextInputAction.done,
                    onChange: (value) {
                      setState(() {
                        captcha.value = value;
                      });
                    },
                    right: CaptchaWidget(
                      context: context,
                      seconds: 25,
                      onChange: (Captcha captcha) => captcha.setCaptcha(captcha),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
