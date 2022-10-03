import 'package:bfban/utils/index.dart';
import 'package:bfban/data/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/elui.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/svg.dart';

import '../../constants/api.dart';

class CaptchaWidget extends StatefulWidget {
  Function(Captcha)? onChange;
  Function(Captcha)? onTap;

  String? id;

  CaptchaWidget({
    Key? key,
    this.id,
    this.onChange,
    this.onTap,
  }) : super(key: key);

  @override
  State<CaptchaWidget> createState() => _captchaWidgetState();
}

class _captchaWidgetState extends State<CaptchaWidget> {
  Captcha captcha = Captcha(load: false, value: "", hash: "", captchaSvg: "");

  get hash => captcha.hash;

  get load => captcha.load;

  @override
  void initState() {
    super.initState();
  }

  /// [Response]
  /// 更新验证码
  void _refreshCaptcha() async {
    String time = DateTime.now().millisecondsSinceEpoch.toString();

    setState(() {
      captcha.load = true;
    });

    Response result = await Http.request(
      "${Config.httpHost["captcha"]}?t=$time",
      method: Http.GET,
    );

    if (result.data["success"] == 1) {
      final d = result.data["data"];

      result.headers['set-cookie']?.forEach((i) {
        captcha.cookie += i + ';';
      });

      setState(() {
        captcha.hash = d["hash"];
        captcha.captchaSvg = d["content"];
      });
    }

    setState(() {
      widget.onChange!(captcha);
      captcha.load = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          child: AnimatedContainer(
            duration: const Duration(seconds: 1),
            margin: const EdgeInsets.only(left: 10),
            height: 45,
            width: 100,
            child: Tooltip(
              message: FlutterI18n.translate(context, "captcha.title"),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (captcha.captchaSvg.toString().isEmpty && !captcha.load)
                    Text(FlutterI18n.translate(context, "captcha.get"))
                  else
                    if (captcha.load)
                      ELuiLoadComponent(
                        type: "line",
                        lineWidth: 1,
                        color: Theme.of(context).textTheme.subtitle1!.color!,
                        size: 16,
                      )
                    else
                      SvgPicture.string(
                        captcha.captchaSvg,
                        color: Theme.of(context).textTheme.bodyText1!.color,
                      )
                ],
              ),
            ),
          ),
          onTap: () => _refreshCaptcha(),
        ),
      ],
    );
  }
}
