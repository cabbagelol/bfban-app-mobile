import 'package:flutter/material.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/index.dart';

class HtmlLink extends StatelessWidget {
  final UrlUtil _urlUtil = UrlUtil();

  RenderContext? renderContext;

  String? url;

  String? text;

  TextStyle? style;

  HtmlLink({
    Key? key,
    this.renderContext,
    required this.url,
    this.text,
    this.style,
  }) : super(key: key);

  /// [Event]
  Widget linkIcon() {
    String scheme = url!.split(":")[0];
    switch (scheme) {
      case "http":
      case "https":
        return const Icon(Icons.link_outlined, size: 15);
      case "mailto":
        return const Icon(Icons.email_outlined, size: 15);
      case "sms":
        return const Icon(Icons.sms_outlined, size: 15);
      default:
        return const Icon(Icons.link_outlined, size: 15);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Text.rich(
        TextSpan(
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
                color: renderContext?.style.color ?? Colors.blue,
                decoration: TextDecoration.underline,
                decorationStyle: TextDecorationStyle.dotted,
              ),
            ),
          ],
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
