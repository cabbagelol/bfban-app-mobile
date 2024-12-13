import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/index.dart';

class HtmlLink extends StatefulWidget {
  final String? url;

  final Color? color;

  final String? text;

  final TextStyle? style;

  final bool softWrap;

  final int? maxLines;

  final TextOverflow? overflow;

  const HtmlLink({
    super.key,
    required this.url,
    this.color,
    this.text,
    this.style,
    this.softWrap = true,
    this.maxLines,
    this.overflow,
  });

  @override
  State<HtmlLink> createState() => _HtmlLinkState();
}

class _HtmlLinkState extends State<HtmlLink> {
  final UrlUtil _urlUtil = UrlUtil();

  Color color = Colors.blue;

  /// [Event]
  Widget linkIcon(TextStyle? style) {
    color = Color.lerp(Colors.blue, Theme.of(context).colorScheme.primary, .8)!;

    style ??= TextStyle(color: color, fontSize: 15.0);

    String scheme = widget.url!.split(":")[0];
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
        message: widget.url,
        child: Text.rich(
          TextSpan(
            style: TextStyle(
              color: color,
              decorationColor: color.withOpacity(.7),
            ),
            children: [
              WidgetSpan(
                child: Container(
                  padding: const EdgeInsets.only(right: 5),
                  child: linkIcon(widget.style),
                ),
              ),
              TextSpan(
                text: (widget.text ?? widget.url).toString().trim(),
                style: (widget.style ?? const TextStyle()).copyWith(
                  overflow: TextOverflow.fade,
                  decoration: TextDecoration.underline,
                  decorationStyle: TextDecorationStyle.dotted,
                ),
              ),
            ],
          ),
          softWrap: widget.softWrap,
          maxLines: widget.maxLines,
          overflow: widget.overflow,
          textWidthBasis: (!widget.softWrap) ? TextWidthBasis.longestLine : TextWidthBasis.parent,
        ),
      ),
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: widget.url!));
      },
      onTap: () {
        _urlUtil.onPeUrl(
          widget.url!,
          mode: LaunchMode.externalApplication,
        );
      },
    );
  }
}
