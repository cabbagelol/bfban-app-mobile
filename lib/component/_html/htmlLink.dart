import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/index.dart';

class HtmlLink extends StatelessWidget {
  final UrlUtil _urlUtil = UrlUtil();

  String? url;

  String? text;

  TextStyle? style;

  HtmlLink({
    Key? key,
    required this.url,
    this.text,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Text.rich(
        TextSpan(
          children: [
            WidgetSpan(
              child: Container(
                padding: const EdgeInsets.only(right: 5),
                child: const Icon(Icons.link, size: 15),
              ),
            ),
            TextSpan(
              text: text ?? url.toString().trim(),
              style: (style ?? const TextStyle()).copyWith(
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
