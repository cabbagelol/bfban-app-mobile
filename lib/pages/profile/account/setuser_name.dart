import 'package:bfban/component/_loading/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/_input/index.dart';
import 'package:flutter_elui_plugin/_tip/index.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

import '/constants/api.dart';
import '/data/index.dart';
import '/provider/userinfo_provider.dart';
import '/utils/index.dart';
import '/component/_captcha/index.dart';

class UserSetUserNamePage extends StatefulWidget {
  const UserSetUserNamePage({super.key});

  @override
  State<UserSetUserNamePage> createState() => SetuserNamePageState();
}

class SetuserNamePageState extends State<UserSetUserNamePage> {
  int stepIndex = 0;

  int maxStep = 2;

  String newName = "";

  Map userInfo = {
    "attr": {"changeNameLeft": 0}
  };

  Captcha captcha = Captcha();

  bool load = false;

  @override
  void initState() {
    _getUserinfo();
    super.initState();
  }

  /// [Response]
  /// 获取账户信息
  void _getUserinfo() async {
    Response result = await UserInfoProvider().getUserInfo();

    if (result.data["success"] == 1) {
      Map d = result.data["data"];
      setState(() {
        userInfo = d;
      });
    }
  }

  /// [Response]
  /// 保存表单
  void _onSave() async {
    if (newName.isEmpty && captcha.value.isEmpty) return;

    setState(() {
      load = true;
    });

    Response result = await HttpToken.request(Config.httpHost["user_changeName"], method: Http.POST, data: {
      "data": {
        "newname": newName,
      },
      "encryptCaptcha": captcha.hashCode,
      "captcha": captcha.value
    });

    if (result.data["success"] == 1) {
      UserInfoProvider().accountQuit(context);
      setState(() {
        stepIndex += 1;
      });
    }

    setState(() {
      load = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserInfoProvider>(
      builder: (BuildContext buildContext, UserInfoProvider userInfoData, Widget? widget) {
        return Scaffold(
          appBar: AppBar(
            title: Text(FlutterI18n.translate(context, "profile.space.modifyName.title")),
          ),
          body: Stepper(
            currentStep: stepIndex,
            connectorColor: WidgetStateProperty.all(Theme.of(context).cardTheme.color!),
            controlsBuilder: (BuildContext context, ControlsDetails controlsDetails) {
              return Container(
                margin: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    Wrap(
                      spacing: 5,
                      children: [
                        if (stepIndex >= 1 && stepIndex < maxStep)
                          TextButton(
                            onPressed: () {
                              if (load) return;
                              setState(() {
                                if (stepIndex > 0) {
                                  stepIndex--;
                                }
                              });
                            },
                            child: Text(FlutterI18n.translate(context, "basic.button.prev")),
                          ),
                        if (stepIndex >= 1 && stepIndex < maxStep)
                          TextButton(
                            onPressed: () {
                              if (stepIndex >= maxStep && load || userInfo["attr"]["changeNameLeft"] <= 0) return;
                              if (stepIndex == 1) _onSave();
                            },
                            child: Wrap(
                              spacing: 5,
                              children: [
                                if (load)
                                  LoadingWidget(
                                    color: Theme.of(context).progressIndicatorTheme.color!,
                                    size: 20,
                                  ),
                                Text(FlutterI18n.translate(context, "basic.button.next")),
                              ],
                            ),
                          ),
                        if (stepIndex == 0)
                          TextButton(
                            onPressed: () {
                              if (userInfo["attr"]["changeNameLeft"] <= 0) return;
                              setState(() {
                                stepIndex += 1;
                              });
                            },
                            child: Text(FlutterI18n.translate(context, "basic.button.submit")),
                          ),
                      ],
                    )
                  ],
                ),
              );
            },
            steps: [
              Step(
                title: Text(FlutterI18n.translate(context, "profile.space.modifyName.steps.0.title")),
                content: Column(
                  children: [
                    EluiTipComponent(
                      type: EluiTip.warning,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(FlutterI18n.translate(context, "profile.space.modifyName.specification1")),
                          const SizedBox(height: 10),
                          Text(
                            FlutterI18n.translate(
                              context,
                              "profile.space.modifyName.residueDegree",
                              translationParams: {
                                "changeNameLeft": userInfo["attr"]["changeNameLeft"].toString(),
                              },
                            ),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Text(FlutterI18n.translate(context, "profile.space.modifyName.specification2")),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Step(
                title: Text(FlutterI18n.translate(context, "profile.space.modifyName.steps.1.title")),
                content: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(FlutterI18n.translate(context, "signup.form.username")),
                            ),
                            SelectionArea(
                              child: Text(userInfoData.userinfo["username"].toString()),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: EluiInputComponent(
                        title: FlutterI18n.translate(context, "signup.form.newUsername"),
                        value: "",
                        placeholder: FlutterI18n.translate(context, "signup.form.newUsername"),
                        onChange: (value) {
                          setState(() {
                            newName = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 5),
                    Card(
                      child: EluiInputComponent(
                        title: FlutterI18n.translate(context, "captcha.title"),
                        value: "",
                        placeholder: FlutterI18n.translate(context, "captcha.title"),
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
              Step(
                title: Text(FlutterI18n.translate(context, "profile.space.modifyName.steps.2.title")),
                content: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Card(
                        child: Icon(Icons.cloud_done_sharp, size: 100, color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
