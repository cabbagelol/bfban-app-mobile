import 'dart:async';

import 'package:bfban/utils/index.dart';
import 'package:bfban/data/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/elui.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/svg.dart';

import '../../constants/api.dart';

class CaptchaWidget extends StatefulWidget {
  Function(Captcha)? onChange;

  String? id;

  bool? disable;

  int? seconds;

  double? height;

  CaptchaWidget({
    Key? key,
    this.id = "0",
    this.onChange,
    this.disable = false,
    this.seconds = 60,
    this.height = 45,
  }) : super(key: key);

  @override
  State<CaptchaWidget> createState() => _captchaWidgetState();
}

class _captchaWidgetState extends State<CaptchaWidget> {
  CaptchaStatus captchaStatus = CaptchaStatus(
    load: false,
  );

  CaptchaTime captchaTime = CaptchaTime(count: 60, lock: false);

  get value => captchaStatus.value;

  get load => captchaStatus.load;

  @override
  void initState() {
    super.initState();
  }

  /// [Response]
  /// 更新验证码
  void _refreshCaptcha() async {
    String time = DateTime.now().millisecondsSinceEpoch.toString();

    if (widget.disable! || captchaTime.lock) return;

    setState(() {
      captchaStatus.load = true;
    });

    Response result = await Http.request(
      "${Config.httpHost["captcha"]}?t=$time",
      method: Http.GET,
    );

    if (result.data["success"] == 1) {
      final d = result.data["data"];

      _capthcaTimeout(widget.seconds!);

      result.headers["set-cookie"]?.forEach((i) {
        captchaStatus.cookie = "${captchaStatus.cookie!}$i;";
      });

      setState(() {
        captchaStatus.encryptCaptcha = d["hash"];
        captchaStatus.captchaSvg = d["content"];
      });
    }

    setState(() {
      widget.onChange!(Captcha(
        encryptCaptcha: captchaStatus.encryptCaptcha,
      ));
      captchaStatus.load = false;
    });
  }

  /// [Event]
  /// 计时器
  void _capthcaTimeout(int num) {
    if (captchaTime.lock) return;

    captchaTime.count = num;

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (captchaTime.count <= 0) {
        timer.cancel();
        captchaTime.lock = false;
        return;
      }

      setState(() {
        captchaTime.count -= 1;
      });
    });

    captchaTime.lock = true;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: AnimatedContainer(
        duration: const Duration(seconds: 1),
        margin: const EdgeInsets.only(left: 10),
        height: widget.height,
        width: 100,
        child: Tooltip(
            message: FlutterI18n.translate(context, "captcha.title"),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (captchaStatus.captchaSvg.isEmpty && !captchaStatus.load!)
                      Text(FlutterI18n.translate(context, "captcha.get"))
                    else if (captchaStatus.load!)
                      ELuiLoadComponent(
                        type: "line",
                        lineWidth: 1,
                        color: Theme.of(context).textTheme.displayMedium!.color!,
                        size: 16,
                      )
                    else
                      SvgPicture.string(
                        captchaStatus.captchaSvg,
                        color: Theme.of(context).textTheme.bodyMedium!.color,
                      ),
                  ],
                ),
                Visibility(
                  visible: captchaTime.count > 0 && captchaStatus.captchaSvg.toString().isNotEmpty,
                  child: Positioned(
                    top: 5,
                    right: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${captchaTime.count}s",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                )
              ],
            )),
      ),
      onTap: () => _refreshCaptcha(),
    );
  }
}

class CaptchaTime {
  late int count;
  late bool lock;

  CaptchaTime({
    this.count = 60,
    this.lock = false,
  });
}
