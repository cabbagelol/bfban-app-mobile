import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

/**
 * 富文本字符格式属性模型
 */
class SpanFormat {
  final bool isBold;
  final bool isItalic;
  final bool isUnderline;
  final bool isStrike;
  final String? linkUrl;
  final Color? color;
  final double? fontSize;

  const SpanFormat({this.isBold = false, this.isItalic = false, this.isUnderline = false, this.isStrike = false, this.linkUrl, this.color, this.fontSize});

  bool get isEmpty => !isBold && !isItalic && !isUnderline && !isStrike && linkUrl == null && color == null && fontSize == null;

  SpanFormat copyWith({bool? isBold, bool? isItalic, bool? isUnderline, bool? isStrike, String? linkUrl, Color? color, double? fontSize}) {
    return SpanFormat(isBold: isBold ?? this.isBold, isItalic: isItalic ?? this.isItalic, isUnderline: isUnderline ?? this.isUnderline, isStrike: isStrike ?? this.isStrike, linkUrl: linkUrl ?? this.linkUrl, color: color ?? this.color, fontSize: fontSize ?? this.fontSize);
  }

  TextStyle toTextStyle(TextStyle baseStyle) {
    TextStyle style = baseStyle;
    if (isBold) style = style.copyWith(fontWeight: FontWeight.bold);
    if (isItalic) style = style.copyWith(fontStyle: FontStyle.italic);

    List<TextDecoration> decorations = [];
    if (isUnderline || (linkUrl != null && linkUrl!.isNotEmpty)) {
      decorations.add(TextDecoration.underline);
    }
    if (isStrike) {
      decorations.add(TextDecoration.lineThrough);
    }
    if (decorations.isNotEmpty) {
      style = style.copyWith(decoration: TextDecoration.combine(decorations));
    }
    if (linkUrl != null && linkUrl!.isNotEmpty) {
      style = style.copyWith(color: Colors.blueAccent);
    }
    if (color != null) style = style.copyWith(color: color);
    if (fontSize != null) style = style.copyWith(fontSize: fontSize);
    return style;
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is SpanFormat && runtimeType == other.runtimeType && isBold == other.isBold && isItalic == other.isItalic && isUnderline == other.isUnderline && isStrike == other.isStrike && linkUrl == other.linkUrl && color == other.color && fontSize == other.fontSize;

  @override
  int get hashCode => Object.hash(isBold, isItalic, isUnderline, isStrike, linkUrl, color, fontSize);
}

/**
 * 历史快照记录
 */
class _EditorSnapshot {
  final TextEditingValue value;
  final List<SpanFormat> formats;
  final List<String> images;

  _EditorSnapshot({required this.value, required List<SpanFormat> formats, required List<String> images}) : formats = List<SpanFormat>.from(formats), images = List<String>.from(images);
}

/**
 * 纯 Flutter 原生可视化所见即所得富文本控制器 (WYSIWYG)
 * 无需显示任何 HTML 标签，直接呈现加粗、斜体、下划线、删除线、超链接与内嵌样式
 */
class VisualRichTextController extends TextEditingController {
  // 每个字符对应的样式格式列表，长度始终与 text.length 保持一致
  List<SpanFormat> _charFormats = [];

  // 当前活跃的输入格式（无选区时新输入字符继承该格式）
  SpanFormat activeTypingFormat = const SpanFormat();

  // 附带的图片列表
  List<String> attachedImages = [];

  // 历史撤销栈
  final List<_EditorSnapshot> _undoStack = [];

  // 历史重做栈
  final List<_EditorSnapshot> _redoStack = [];

  // 是否正在执行内部更新或历史记录回滚
  bool _isInternalChanging = false;

  // 上一次的文本内容缓存，用于对比变更差异
  String _lastText = "";

  VisualRichTextController({String? initialHtml}) {
    if (initialHtml != null && initialHtml.isNotEmpty) {
      setHtml(initialHtml);
    } else {
      _saveSnapshot();
    }
  }

  bool get canUndo => _undoStack.length > 1;

  bool get canRedo => _redoStack.isNotEmpty;

  @override
  set value(TextEditingValue newValue) {
    if (_isInternalChanging) {
      super.value = newValue;
      _lastText = newValue.text;
      return;
    }

    final String oldText = _lastText;
    final String newText = newValue.text;

    if (oldText != newText) {
      _syncFormatsOnTextChange(oldText, newText);
      _lastText = newText;
      _saveSnapshot();
      _redoStack.clear();
    } else {
      _updateActiveTypingFormat(newValue.selection);
    }

    super.value = newValue;
  }

  /**
   * 记录历史快照
   */
  void _saveSnapshot() {
    _undoStack.add(_EditorSnapshot(value: value, formats: _charFormats, images: attachedImages));
    if (_undoStack.length > 50) {
      _undoStack.removeAt(0);
    }
  }

  /**
   * 当用户在键盘输入或删除时，智能增量同步字符格式列表
   */
  void _syncFormatsOnTextChange(String oldText, String newText) {
    int prefixLen = 0;
    while (prefixLen < oldText.length && prefixLen < newText.length && oldText[prefixLen] == newText[prefixLen]) {
      prefixLen++;
    }

    int suffixLen = 0;
    while (suffixLen < (oldText.length - prefixLen) && suffixLen < (newText.length - prefixLen) && oldText[oldText.length - 1 - suffixLen] == newText[newText.length - 1 - suffixLen]) {
      suffixLen++;
    }

    int diffStart = prefixLen;
    int deletedCount = oldText.length - prefixLen - suffixLen;
    int insertedCount = newText.length - prefixLen - suffixLen;

    // 移除已删除字符的格式
    if (deletedCount > 0 && diffStart < _charFormats.length) {
      int removeEnd = diffStart + deletedCount;
      if (removeEnd > _charFormats.length) removeEnd = _charFormats.length;
      _charFormats.removeRange(diffStart, removeEnd);
    }

    // 插入新字符的格式（继承活跃输入格式）
    if (insertedCount > 0) {
      List<SpanFormat> newFormats = List<SpanFormat>.filled(insertedCount, activeTypingFormat);
      if (diffStart <= _charFormats.length) {
        _charFormats.insertAll(diffStart, newFormats);
      } else {
        _charFormats.addAll(newFormats);
      }
    }

    // 防御性补齐或裁剪，确保长度绝对严格相等
    if (_charFormats.length < newText.length) {
      _charFormats.addAll(List<SpanFormat>.filled(newText.length - _charFormats.length, activeTypingFormat));
    } else if (_charFormats.length > newText.length) {
      _charFormats = _charFormats.sublist(0, newText.length);
    }
  }

  /**
   * 根据当前光标位置，同步更新工具栏高亮状态
   */
  void _updateActiveTypingFormat(TextSelection selection) {
    if (selection.start >= 0 && selection.start == selection.end && selection.start <= _charFormats.length) {
      int checkIndex = selection.start > 0 ? selection.start - 1 : 0;
      if (checkIndex < _charFormats.length) {
        activeTypingFormat = _charFormats[checkIndex];
      }
    }
  }

  /**
   * 切换加粗
   */
  void toggleBold() {
    _toggleAttribute((fmt) => fmt.isBold, (fmt, val) => fmt.copyWith(isBold: val));
  }

  /**
   * 切换斜体
   */
  void toggleItalic() {
    _toggleAttribute((fmt) => fmt.isItalic, (fmt, val) => fmt.copyWith(isItalic: val));
  }

  /**
   * 切换下划线
   */
  void toggleUnderline() {
    _toggleAttribute((fmt) => fmt.isUnderline, (fmt, val) => fmt.copyWith(isUnderline: val));
  }

  /**
   * 切换删除线
   */
  void toggleStrike() {
    _toggleAttribute((fmt) => fmt.isStrike, (fmt, val) => fmt.copyWith(isStrike: val));
  }

  /**
   * 通用属性切换处理
   */
  void _toggleAttribute(bool Function(SpanFormat) getter, SpanFormat Function(SpanFormat, bool) setter) {
    TextSelection sel = selection;
    if (sel.start < 0 || sel.end < 0 || sel.start == sel.end) {
      // 无选区，切换即将输入的格式
      bool currentVal = getter(activeTypingFormat);
      activeTypingFormat = setter(activeTypingFormat, !currentVal);
      notifyListeners();
      return;
    }

    int start = sel.start;
    int end = sel.end;
    if (start > end) {
      int t = start;
      start = end;
      end = t;
    }

    bool anyWithout = false;
    for (int i = start; i < end && i < _charFormats.length; i++) {
      if (!getter(_charFormats[i])) {
        anyWithout = true;
        break;
      }
    }

    bool targetVal = anyWithout;
    for (int i = start; i < end && i < _charFormats.length; i++) {
      _charFormats[i] = setter(_charFormats[i], targetVal);
    }

    activeTypingFormat = setter(activeTypingFormat, targetVal);
    _saveSnapshot();
    notifyListeners();
  }

  /**
   * 插入超链接
   */
  void insertLink(String linkText, String url) {
    if (linkText.isEmpty || url.isEmpty) return;

    TextSelection sel = selection;
    int start = sel.start >= 0 ? sel.start : text.length;
    int end = sel.end >= 0 ? sel.end : text.length;
    if (start > end) {
      int t = start;
      start = end;
      end = t;
    }

    SpanFormat linkFormat = activeTypingFormat.copyWith(linkUrl: url);

    String newText = text.replaceRange(start, end, linkText);
    _isInternalChanging = true;

    // 更新格式列表
    if (end > start && start < _charFormats.length) {
      _charFormats.removeRange(start, end.clamp(0, _charFormats.length));
    }
    _charFormats.insertAll(start, List<SpanFormat>.filled(linkText.length, linkFormat));

    _lastText = newText;
    value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + linkText.length),
    );

    _saveSnapshot();
    _isInternalChanging = false;
    notifyListeners();
  }

  /**
   * 插入水平分割线
   */
  void insertHorizontalRule() {
    insertText("\n────────────────────\n");
  }

  /**
   * 插入表情
   */
  void insertEmote(String emoteName) {
    insertText(" [emoji|$emoteName] ");
  }

  /**
   * 插入缩语语法 (CS)
   */
  void insertContractedSyntax(String type, String value) {
    insertText(" {$type:$value} ");
  }

  /**
   * 在当前光标处插入普通文本
   */
  void insertText(String insertContent) {
    TextSelection sel = selection;
    int start = sel.start >= 0 ? sel.start : text.length;
    int end = sel.end >= 0 ? sel.end : text.length;
    if (start > end) {
      int t = start;
      start = end;
      end = t;
    }

    String newText = text.replaceRange(start, end, insertContent);
    _isInternalChanging = true;

    if (end > start && start < _charFormats.length) {
      _charFormats.removeRange(start, end.clamp(0, _charFormats.length));
    }
    _charFormats.insertAll(start, List<SpanFormat>.filled(insertContent.length, activeTypingFormat));

    _lastText = newText;
    value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + insertContent.length),
    );

    _saveSnapshot();
    _isInternalChanging = false;
    notifyListeners();
  }

  /**
   * 切换无序列表
   */
  void toggleBulletList() {
    _insertLinePrefix("• ");
  }

  /**
   * 切换有序列表
   */
  void toggleOrderedList() {
    _insertLinePrefix("1. ");
  }

  void _insertLinePrefix(String prefix) {
    TextSelection sel = selection;
    int start = sel.start >= 0 ? sel.start : 0;
    // 寻找当前行的起始位置
    int lineStart = text.lastIndexOf("\n", start > 0 ? start - 1 : 0);
    lineStart = lineStart < 0 ? 0 : lineStart + 1;

    String curText = text;
    if (curText.substring(lineStart).startsWith(prefix)) {
      // 取消前缀
      String newText = curText.replaceRange(lineStart, lineStart + prefix.length, "");
      _isInternalChanging = true;
      _charFormats.removeRange(lineStart, lineStart + prefix.length);
      _lastText = newText;
      value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: (start - prefix.length).clamp(0, newText.length)),
      );
      _isInternalChanging = false;
    } else {
      // 增加前缀
      String newText = curText.replaceRange(lineStart, lineStart, prefix);
      _isInternalChanging = true;
      _charFormats.insertAll(lineStart, List<SpanFormat>.filled(prefix.length, const SpanFormat()));
      _lastText = newText;
      value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: start + prefix.length),
      );
      _isInternalChanging = false;
    }
    _saveSnapshot();
    notifyListeners();
  }

  /**
   * 添加图片
   */
  void addImage(String url) {
    if (url.trim().isEmpty) return;
    if (!attachedImages.contains(url.trim())) {
      attachedImages.add(url.trim());
      _saveSnapshot();
      notifyListeners();
    }
  }

  /**
   * 移除图片
   */
  void removeImage(String url) {
    attachedImages.remove(url);
    _saveSnapshot();
    notifyListeners();
  }

  /**
   * 撤销
   */
  void undo() {
    if (!canUndo) return;
    _isInternalChanging = true;
    _EditorSnapshot current = _undoStack.removeLast();
    _redoStack.add(current);

    _EditorSnapshot target = _undoStack.last;
    _charFormats = List<SpanFormat>.from(target.formats);
    attachedImages = List<String>.from(target.images);
    _lastText = target.value.text;
    value = target.value;

    _isInternalChanging = false;
    notifyListeners();
  }

  /**
   * 重做
   */
  void redo() {
    if (!canRedo) return;
    _isInternalChanging = true;
    _EditorSnapshot target = _redoStack.removeLast();
    _undoStack.add(target);

    _charFormats = List<SpanFormat>.from(target.formats);
    attachedImages = List<String>.from(target.images);
    _lastText = target.value.text;
    value = target.value;

    _isInternalChanging = false;
    notifyListeners();
  }

  /**
   * 导入并解析 HTML，将其转换为纯文本与格式模型（完全隐藏原生 HTML 标签）
   */
  void setHtml(String html) {
    _isInternalChanging = true;
    _charFormats.clear();
    attachedImages.clear();
    StringBuffer textBuffer = StringBuffer();

    if (html.isEmpty) {
      _lastText = "";
      value = const TextEditingValue();
      _undoStack.clear();
      _redoStack.clear();
      _saveSnapshot();
      _isInternalChanging = false;
      notifyListeners();
      return;
    }

    try {
      var fragment = html_parser.parseFragment(html);
      _parseDomNodes(fragment.nodes, textBuffer, const SpanFormat());
    } catch (_) {
      // 容错处理：若 HTML 解析异常则直接当普通文本
      textBuffer.write(html);
      _charFormats = List<SpanFormat>.filled(html.length, const SpanFormat());
    }

    String resultText = textBuffer.toString();
    if (_charFormats.length < resultText.length) {
      _charFormats.addAll(List<SpanFormat>.filled(resultText.length - _charFormats.length, const SpanFormat()));
    } else if (_charFormats.length > resultText.length) {
      _charFormats = _charFormats.sublist(0, resultText.length);
    }

    _lastText = resultText;
    value = TextEditingValue(
      text: resultText,
      selection: TextSelection.collapsed(offset: resultText.length),
    );

    _undoStack.clear();
    _redoStack.clear();
    _saveSnapshot();
    _isInternalChanging = false;
    notifyListeners();
  }

  void _parseDomNodes(List<dom.Node> nodes, StringBuffer buffer, SpanFormat currentFormat) {
    for (var node in nodes) {
      if (node is dom.Text) {
        String t = node.text;
        buffer.write(t);
        for (int i = 0; i < t.length; i++) {
          _charFormats.add(currentFormat);
        }
      } else if (node is dom.Element) {
        String tag = node.localName?.toLowerCase() ?? "";
        SpanFormat nextFormat = currentFormat;

        switch (tag) {
          case 'b':
          case 'strong':
            nextFormat = nextFormat.copyWith(isBold: true);
            break;
          case 'i':
          case 'em':
            nextFormat = nextFormat.copyWith(isItalic: true);
            break;
          case 'u':
            nextFormat = nextFormat.copyWith(isUnderline: true);
            break;
          case 's':
          case 'del':
          case 'strike':
            nextFormat = nextFormat.copyWith(isStrike: true);
            break;
          case 'a':
            String? href = node.attributes['href'];
            nextFormat = nextFormat.copyWith(linkUrl: href ?? "");
            break;
          case 'img':
            String? src = node.attributes['src'];
            if (src != null && src.isNotEmpty && !attachedImages.contains(src)) {
              attachedImages.add(src);
            }
            continue;
          case 'hr':
            if (buffer.isNotEmpty && !buffer.toString().endsWith("\n")) {
              buffer.write("\n");
              _charFormats.add(const SpanFormat());
            }
            buffer.write("────────────────────\n");
            for (int i = 0; i < 21; i++) {
              _charFormats.add(const SpanFormat());
            }
            continue;
          case 'br':
            buffer.write("\n");
            _charFormats.add(const SpanFormat());
            continue;
          case 'li':
            if (buffer.isNotEmpty && !buffer.toString().endsWith("\n")) {
              buffer.write("\n");
              _charFormats.add(const SpanFormat());
            }
            buffer.write("• ");
            _charFormats.add(const SpanFormat());
            _charFormats.add(const SpanFormat());
            break;
        }

        _parseDomNodes(node.nodes, buffer, nextFormat);

        if (tag == 'p' || tag == 'div') {
          if (!buffer.toString().endsWith("\n")) {
            buffer.write("\n");
            _charFormats.add(const SpanFormat());
          }
        }
      }
    }
  }

  /**
   * 将当前可视化文本与样式模型序列化为标准 HTML 导出
   */
  String toHtml() {
    final String text = this.text;
    if (text.isEmpty && attachedImages.isEmpty) return "";

    StringBuffer html = StringBuffer();
    List<String> lines = text.split("\n");

    int globalIndex = 0;
    for (int l = 0; l < lines.length; l++) {
      String line = lines[l];

      // 分割线特殊处理
      if (line.trim().startsWith("──") || line.trim() == "---") {
        html.write("<hr/>");
        globalIndex += line.length + (l < lines.length - 1 ? 1 : 0);
        continue;
      }

      bool isList = false;
      String contentLine = line;
      if (contentLine.startsWith("• ")) {
        isList = true;
        contentLine = contentLine.substring(2);
        globalIndex += 2;
      }

      StringBuffer lineHtml = StringBuffer();
      int lineStart = globalIndex;
      int lineEnd = globalIndex + contentLine.length;

      int chunkStart = lineStart;
      while (chunkStart < lineEnd) {
        SpanFormat fmt = (chunkStart < _charFormats.length) ? _charFormats[chunkStart] : const SpanFormat();
        int chunkEnd = chunkStart + 1;
        while (chunkEnd < lineEnd && (chunkEnd < _charFormats.length ? _charFormats[chunkEnd] : const SpanFormat()) == fmt) {
          chunkEnd++;
        }

        String chunkText = text.substring(chunkStart, chunkEnd);
        String escaped = _escapeHtml(chunkText);

        String formatted = escaped;
        if (fmt.isBold) formatted = "<b>$formatted</b>";
        if (fmt.isItalic) formatted = "<i>$formatted</i>";
        if (fmt.isUnderline) formatted = "<u>$formatted</u>";
        if (fmt.isStrike) formatted = "<s>$formatted</s>";
        if (fmt.linkUrl != null && fmt.linkUrl!.isNotEmpty) {
          formatted = '<a href="${fmt.linkUrl}">$formatted</a>';
        }

        lineHtml.write(formatted);
        chunkStart = chunkEnd;
      }

      if (isList) {
        html.write("<ul><li>${lineHtml.toString()}</li></ul>");
      } else if (lineHtml.isNotEmpty) {
        html.write("<p>${lineHtml.toString()}</p>");
      } else if (l < lines.length - 1) {
        html.write("<br/>");
      }

      globalIndex = lineEnd + (l < lines.length - 1 ? 1 : 0);
    }

    // 附带图片输出
    for (var imgUrl in attachedImages) {
      html.write('<p><img src="$imgUrl"/></p>');
    }

    return html.toString();
  }

  String _escapeHtml(String text) {
    return text.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;').replaceAll('"', '&quot;');
  }

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    final TextStyle defaultStyle = style ?? TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87, fontSize: 15, height: 1.5);

    final String text = value.text;
    if (text.isEmpty) {
      return TextSpan(text: "", style: defaultStyle);
    }

    // 针对输入法组字阶段（IME Composing），严格隔离并加下划线显示，确保中文输入法正常上屏
    if (withComposing && value.isComposingRangeValid) {
      final TextStyle composingStyle = defaultStyle.merge(const TextStyle(decoration: TextDecoration.underline));

      return TextSpan(
        style: defaultStyle,
        children: <TextSpan>[
          _buildSpansForRange(0, value.composing.start, defaultStyle, context),
          TextSpan(style: composingStyle, text: value.composing.textInside(text)),
          _buildSpansForRange(value.composing.end, text.length, defaultStyle, context),
        ],
      );
    }

    return TextSpan(style: defaultStyle, children: _buildSpansList(0, text.length, defaultStyle, context));
  }

  TextSpan _buildSpansForRange(int start, int end, TextStyle defaultStyle, BuildContext context) {
    if (start >= end || start >= text.length) {
      return const TextSpan(text: "");
    }
    return TextSpan(style: defaultStyle, children: _buildSpansList(start, end, defaultStyle, context));
  }

  List<TextSpan> _buildSpansList(int start, int end, TextStyle defaultStyle, BuildContext context) {
    List<TextSpan> spans = [];
    int chunkStart = start;

    // 特殊语法高亮正则：表情 [emoji|xxx] 与 缩语 {player:xxx}
    final RegExp tokenRegex = RegExp(r'(\[([a-zA-Z0-9_-]+)\|([^\]]+)\])|(\{([a-zA-Z0-9_-]+)(?::([^}]+))?\})');

    while (chunkStart < end && chunkStart < text.length) {
      SpanFormat fmt = (chunkStart < _charFormats.length) ? _charFormats[chunkStart] : const SpanFormat();

      int chunkEnd = chunkStart + 1;
      while (chunkEnd < end && chunkEnd < text.length && (chunkEnd < _charFormats.length ? _charFormats[chunkEnd] : const SpanFormat()) == fmt) {
        chunkEnd++;
      }

      String chunkText = text.substring(chunkStart, chunkEnd);
      TextStyle chunkStyle = fmt.toTextStyle(defaultStyle);

      // 检查 chunk 内部是否有 [emoji] 或 {cs} 标记需要视觉化微调
      int subLast = 0;
      for (final Match m in tokenRegex.allMatches(chunkText)) {
        if (m.start > subLast) {
          spans.add(TextSpan(text: chunkText.substring(subLast, m.start), style: chunkStyle));
        }

        final String token = m.group(0)!;
        if (token.startsWith('{') && token.endsWith('}')) {
          // 缩语徽章样式
          spans.add(
            TextSpan(
              text: token,
              style: chunkStyle.copyWith(color: Colors.deepPurple, fontWeight: FontWeight.bold, backgroundColor: Colors.deepPurple.withValues(alpha: 0.1)),
            ),
          );
        } else if (token.startsWith('[') && token.endsWith(']')) {
          // 表情标记样式
          spans.add(
            TextSpan(
              text: token,
              style: chunkStyle.copyWith(color: Colors.amber.shade800, fontWeight: FontWeight.bold),
            ),
          );
        }

        subLast = m.end;
      }

      if (subLast < chunkText.length) {
        spans.add(TextSpan(text: chunkText.substring(subLast), style: chunkStyle));
      }

      chunkStart = chunkEnd;
    }

    return spans;
  }
}
