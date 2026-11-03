import 'package:flutter/material.dart';

import '../../utils/index.dart';

class HtmlEmoji extends StatefulWidget {
  final Map? attributes;
  final Color? color;
  final Color? backgroundColor;

  const HtmlEmoji({
    super.key,
    this.attributes,
    this.color,
    this.backgroundColor,
  });

  @override
  State<HtmlEmoji> createState() => _HtmlImageState();
}

class _HtmlImageState extends State<HtmlEmoji> {
  double turns = 0.0;

  @override
  void initState() {
    super.initState();
  }

  /// [Event]
  /// 获取表情地址
  String? getEmojiUrl(Map? attributes) {
    if (attributes == null || attributes['style'] == null) return "";
    Regular regular = Regular();
    RegExpMatch? reg = regular.REGULARTYPE[RegularType.Link]?.v.firstMatch(attributes["style"].toString());
    return reg?.group(0);
  }

  @override
  Widget build(BuildContext context) {
    final Map attrs = widget.attributes ?? {};
    final String onlyLoadUrl = getEmojiUrl(attrs) ?? "";
    final String styleStr = (attrs['style'] ?? "").toString();

    return Container(
      margin: const EdgeInsets.only(right: 2),
      child: Wrap(
        children: [
          if (onlyLoadUrl.isNotEmpty && (styleStr.split(';').where((i) => i.contains('background-position'))).isEmpty)
            Tooltip(
              message: attrs['title'] ?? attrs['alt'] ?? ':none:',
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  border: Border.all(color: Theme
                      .of(context)
                      .dividerTheme
                      .color ?? Colors.grey.shade300),
                ),
                child: Image.network(onlyLoadUrl, width: 20, height: 20),
              ),
            )
          else
            if ((styleStr.split(';').where((i) => i.contains('background-position'))).isNotEmpty)
            Tooltip(
              message: attrs['title'] ?? attrs['alt'] ?? ':none:',
              child: Text(attrs['alt']?.toString() ?? ""),
            )
          else
            const SizedBox(
              width: 18,
              height: 18,
              child: Placeholder(strokeWidth: .5),
            ),
        ],
      ),
    );
  }
}
