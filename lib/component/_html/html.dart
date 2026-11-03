import 'package:flutter/material.dart';

import 'html_parser_core.dart';

/**
 * 纯 Flutter 原生 HTML 与自定义富文本渲染核心组件
 */
class HtmlCore extends StatefulWidget {
  /**
   * 待渲染的 HTML 或富文本字符串内容
   */
  final String? data;

  /**
   * 兼容样式字典或配置
   */
  final dynamic style;

  /**
   * 基础文本样式
   */
  final TextStyle? textStyle;

  /**
   * 基础字号
   */
  final double? fontSize;

  /**
   * 点击链接回调
   */
  final Function(String url)? onLinkTap;

  /**
   * 是否支持长按复制与文本选择
   */
  final bool selectable;

  const HtmlCore({
    super.key,
    this.data,
    this.style,
    this.textStyle,
    this.fontSize,
    this.onLinkTap,
    this.selectable = true,
  });

  @override
  State<HtmlCore> createState() => _HtmlCoreState();
}

class _HtmlCoreState extends State<HtmlCore> {
  // 解析后的组件列表
  List<Widget> _parsedWidgets = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _rebuildWidgets();
  }

  @override
  void didUpdateWidget(covariant HtmlCore oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data || oldWidget.fontSize != widget.fontSize || oldWidget.style != widget.style) {
      _rebuildWidgets();
    }
  }

  /**
   * 重新解析构建内容组件
   */
  void _rebuildWidgets() {
    String content = widget.data ?? "";
    if (content
        .trim()
        .isEmpty) {
      setState(() {
        _parsedWidgets = [];
      });
      return;
    }

    // 计算实际基础样式
    double effectiveFontSize = widget.fontSize ?? 14.0;
    if (widget.style is Map && widget.style["body"] != null) {
      dynamic bodyStyle = widget.style["body"];
      if (bodyStyle is TextStyle && bodyStyle.fontSize != null) {
        effectiveFontSize = bodyStyle.fontSize!;
      }
    }

    TextStyle baseStyle = widget.textStyle ??
        TextStyle(
          fontSize: effectiveFontSize,
          color: Theme
              .of(context)
              .textTheme
              .bodyMedium
              ?.color ?? Colors.black87,
          height: 1.5,
        );

    HtmlParserCore parser = HtmlParserCore(
      baseStyle: baseStyle,
      onLinkTap: widget.onLinkTap,
    );

    List<Widget> result = parser.parse(context, content);

    setState(() {
      _parsedWidgets = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_parsedWidgets.isEmpty) {
      return const SizedBox.shrink();
    }

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: _parsedWidgets,
    );

    if (widget.selectable) {
      return SelectionArea(child: content);
    }

    return content;
  }
}
