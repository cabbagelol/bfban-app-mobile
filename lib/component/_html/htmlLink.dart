import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/index.dart';

class HtmlLink extends StatelessWidget {
  final UrlUtil _urlUtil = UrlUtil();

  String? url;

  Color? color;

  String? text;

  final TextStyle? style;

  bool softWrap;

  int? maxLines;

  TextOverflow? overflow;

  HtmlLink({
    super.key,
    required this.url,
    this.color = Colors.blue,
    this.text,
    this.style,
    this.softWrap = true,
    this.maxLines,
    this.overflow,
  });

  /// [Event]
  Widget linkIcon(TextStyle? style) {
    style ??= TextStyle(color: color, fontSize: 15.0);

    String scheme = url!.split(":")[0];
    double? iconSize = style.fontSize ?? 15.0;
    Color? iconColor = style.color ?? color;

    switch (scheme) {
      case "http":
      case "https":
        return Icon(Icons.link_outlined, size: iconSize, color: iconColor);
      case "mailto":
        return Icon(Icons.email_outlined, size: iconSize, color: iconColor);
      case "sms":
        return Icon(Icons.sms_outlined, size: iconSize, color: iconColor);
      default:
        return Icon(Icons.link_outlined, size: iconSize, color: iconColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Tooltip(
        message: url,
        child: Text.rich(
          TextSpan(
            style: TextStyle(
              color: color,
              decorationColor: color!.withOpacity(.7),
            ),
            children: [
              WidgetSpan(
                child: Container(
                  padding: const EdgeInsets.only(right: 5),
                  child: linkIcon(style),
                ),
              ),
              TextSpan(
                text: (text ?? url).toString().trim(),
                style: (style ?? const TextStyle()).copyWith(
                  decoration: TextDecoration.underline,
                  decorationStyle: TextDecorationStyle.dotted,
                ),
              ),
            ],
          ),
          softWrap: softWrap,
          maxLines: maxLines,
          overflow: overflow,
          textWidthBasis: (!softWrap) ? TextWidthBasis.longestLine : TextWidthBasis.parent,
        ),
      ),
      onTap: () {
        _urlUtil.onPeUrl(
          url!,
          mode: LaunchMode.externalApplication,
        );
      },
    );
  }
}
