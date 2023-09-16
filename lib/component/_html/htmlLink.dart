import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/index.dart';

class HtmlLink extends StatelessWidget {
  final UrlUtil _urlUtil = UrlUtil();

  String? url;

  Color? color;

  String? text;

  TextStyle? style;

  bool softWrap;

  int? maxLines;

  TextOverflow? overflow;

  HtmlLink({
    Key? key,
    required this.url,
    this.color = Colors.blue,
    this.text,
    this.style,
    this.softWrap = true,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  /// [Event]
  Widget linkIcon() {
    String scheme = url!.split(":")[0];
    switch (scheme) {
      case "http":
      case "https":
        return Icon(Icons.link_outlined, size: 15, color: color);
      case "mailto":
        return Icon(Icons.email_outlined, size: 15, color: color);
      case "sms":
        return Icon(Icons.sms_outlined, size: 15, color: color);
      default:
        return Icon(Icons.link_outlined, size: 15, color: color);
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
                  child: linkIcon(),
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
          textWidthBasis: TextWidthBasis.longestLine,
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
