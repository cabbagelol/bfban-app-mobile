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
    Regular regular = Regular();
    if (attributes!['style'] == null) return "";
    RegExpMatch? reg = regular.REGULARTYPE[RegularType.Link]?.v.firstMatch(attributes["style"]);
    return reg?.group(0);
  }

  @override
  Widget build(BuildContext context) {
    String onlyLoadUrl = getEmojiUrl(widget.attributes!)!;
    return Container(
      margin: const EdgeInsets.only(right: 2),
      child: Wrap(
        children: [
          if (onlyLoadUrl.isNotEmpty && (widget.attributes!['style'].toString().split(';').where((i) => i.indexOf('background-position') >= 0)).isEmpty)
            Tooltip(
              message: widget.attributes!['title'] ?? widget.attributes!['alt'] ?? ':none:',
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  border: Border.all(color: Theme.of(context).dividerTheme.color!),
                ),
                child: Image.network(onlyLoadUrl, width: 20, height: 20),
              ),
            )
          else if ((widget.attributes!['style'].toString().split(';').where((i) => i.indexOf('background-position') >= 0)).isNotEmpty)
            Tooltip(
              message: widget.attributes!['title'] ?? widget.attributes!['alt'] ?? ':none:',
              child: Text(widget.attributes!['alt'].toString()),
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
