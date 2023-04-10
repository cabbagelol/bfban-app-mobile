import 'package:flutter/material.dart';

import '../../utils/index.dart';

class HtmlLink extends StatelessWidget {
  final UrlUtil _urlUtil = UrlUtil();

  String? url;

  TextStyle? style;

  HtmlLink({
    Key? key,
    required this.url,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
              text: url.toString().trim(),
              style: (style ?? const TextStyle()).copyWith(
                decoration: TextDecoration.underline,
                decorationStyle: TextDecorationStyle.dotted,
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        _urlUtil.onPeUrl(url!);
      },
    );
  }
}
