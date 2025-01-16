import 'package:bfban/data/index.dart';
import 'package:flutter/material.dart';

import './svg.dart';
import './turnstile.dart';

class CaptchaWidget extends StatefulWidget {
  final Function(CaptchaBaseType)? onChange;

  final CaptchaType type;

  // cap opt S
  final BuildContext? context;

  final String? id;

  final bool? disable;

  final int? seconds;

  final double? height;

  // cap opt E

  const CaptchaWidget({
    super.key,
    this.type = CaptchaType.SVG,
    this.onChange,

    // cap opt
    this.context,
    this.id = "0",
    this.disable = false,
    this.seconds = 60,
    this.height = 45,
  });

  @override
  State<CaptchaWidget> createState() => _CaptchaWidgetState();
}

class _CaptchaWidgetState extends State<CaptchaWidget> {
  Widget get captchaWidget {
    switch (widget.type) {
      case CaptchaType.SVG:
        return CaptchaSvgWidget(
          id: widget.id,
          disable: widget.disable,
          seconds: widget.seconds,
          height: widget.height,
          onChange: onDoneChange,
        );
      case CaptchaType.None:
      case CaptchaType.TURNSTILE:
        return CaptchaTurnstileWidget();
    }
  }

  onDoneChange(CaptchaBaseType captcha) {
    if (widget.onChange != null) widget.onChange!(captcha);
  }

  @override
  Widget build(BuildContext context) {
    return captchaWidget;
  }
}
