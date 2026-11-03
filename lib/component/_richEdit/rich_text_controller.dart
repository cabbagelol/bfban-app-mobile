import 'package:flutter/material.dart';

/**
 * 支持实时 HTML 标签与特殊标记高亮显示的富文本编辑控制器
 */
class RichTextEditorController extends TextEditingController {
  RichTextEditorController({super.text});

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    final TextStyle defaultStyle = style ?? TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87, fontSize: 15, height: 1.5);

    final String text = value.text;
    if (text.isEmpty) {
      return TextSpan(text: "", style: defaultStyle);
    }

    // 针对输入法输入中的拼音组合状态（IME Composing），严格隔离并下划线显示，确保中文等输入法能正常上屏
    if (withComposing && value.isComposingRangeValid) {
      final TextStyle composingStyle = defaultStyle.merge(const TextStyle(decoration: TextDecoration.underline));

      return TextSpan(
        style: defaultStyle,
        children: <TextSpan>[
          _buildSyntaxTextSpan(value.composing.textBefore(text), defaultStyle, context),
          TextSpan(style: composingStyle, text: value.composing.textInside(text)),
          _buildSyntaxTextSpan(value.composing.textAfter(text), defaultStyle, context),
        ],
      );
    }

    return _buildSyntaxTextSpan(text, defaultStyle, context);
  }

  /// 语法高亮解析构建核心方法
  TextSpan _buildSyntaxTextSpan(String text, TextStyle defaultStyle, BuildContext context) {
    if (text.isEmpty) {
      return TextSpan(text: "", style: defaultStyle);
    }

    // 正则表达式匹配 HTML 标签、缩语语法与表情
    final RegExp tokenRegex = RegExp(r'(</?[a-zA-Z0-9_-]+(?:\s+[^>]*)?>)|(\{([a-zA-Z0-9_-]+)(?::([^}]+))?\})|(\[([a-zA-Z0-9_-]+)\|([^\]]+)\])|(https?:\/\/[^\s<"]+)');

    List<TextSpan> spans = [];
    int lastIndex = 0;

    final Color primaryColor = Theme.of(context).primaryColor;
    final TextStyle tagStyle = defaultStyle.copyWith(color: primaryColor.withValues(alpha: 0.7), fontFamily: 'monospace', fontWeight: FontWeight.w500);
    final TextStyle csStyle = defaultStyle.copyWith(color: Colors.deepPurple, fontWeight: FontWeight.w600);
    final TextStyle emoteStyle = defaultStyle.copyWith(color: Colors.amber.shade800, fontWeight: FontWeight.w600);
    final TextStyle linkStyle = defaultStyle.copyWith(color: Colors.blue, decoration: TextDecoration.underline);

    for (final Match match in tokenRegex.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: text.substring(lastIndex, match.start), style: defaultStyle));
      }

      final String matchedText = match.group(0)!;

      if (matchedText.startsWith('<') && matchedText.endsWith('>')) {
        // HTML 标签高亮
        spans.add(TextSpan(text: matchedText, style: tagStyle));
      } else if (matchedText.startsWith('{') && matchedText.endsWith('}')) {
        // 缩语高亮
        spans.add(TextSpan(text: matchedText, style: csStyle));
      } else if (matchedText.startsWith('[') && matchedText.endsWith(']')) {
        // 表情标记高亮
        spans.add(TextSpan(text: matchedText, style: emoteStyle));
      } else if (matchedText.startsWith('http://') || matchedText.startsWith('https://')) {
        // 链接高亮
        spans.add(TextSpan(text: matchedText, style: linkStyle));
      } else {
        spans.add(TextSpan(text: matchedText, style: defaultStyle));
      }

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex), style: defaultStyle));
    }

    return TextSpan(children: spans, style: defaultStyle);
  }
}
