import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:url_launcher/url_launcher.dart';

import '../../utils/index.dart';
import 'htmlImage.dart';

/**
 * 纯 Flutter 原生 HTML 与自定义语法渲染构建器
 */
class HtmlParserCore {
  /**
   * 基础文本样式
   */
  final TextStyle baseStyle;

  /**
   * 点击链接回调
   */
  final Function(String url)? onLinkTap;

  /**
   * 构造函数
   */
  HtmlParserCore({required this.baseStyle, this.onLinkTap});

  /**
   * 解析 HTML 字符串为 Flutter 控件列表
   */
  List<Widget> parse(BuildContext context, String htmlContent) {
    if (htmlContent.trim().isEmpty) {
      return [];
    }

    // 预处理内容中可能的换行与实体
    String processed = htmlContent;

    // 解析为 DOM 树
    dom.DocumentFragment fragment = html_parser.parseFragment(processed);

    List<Widget> widgets = [];
    for (dom.Node node in fragment.nodes) {
      Widget? w = _buildNodeWidget(context, node);
      if (w != null) {
        widgets.add(w);
      }
    }

    return widgets;
  }

  /**
   * 构建单个 DOM 节点对应的块级组件
   */
  Widget? _buildNodeWidget(BuildContext context, dom.Node node) {
    if (node is dom.Text) {
      String text = node.text.trim();
      if (text.isEmpty) {
        return null;
      }
      List<InlineSpan> spans = _parseTextWithTokens(context, text, baseStyle);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text.rich(TextSpan(children: spans, style: baseStyle)),
      );
    }

    if (node is dom.Element) {
      String tag = node.localName?.toLowerCase() ?? "";

      switch (tag) {
        case "p":
        case "div":
          List<InlineSpan> spans = _buildInlineChildren(context, node, baseStyle);
          if (spans.isEmpty) {
            return const SizedBox(height: 8);
          }
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Text.rich(TextSpan(children: spans, style: baseStyle)),
          );

        case "h1":
          return _buildHeading(context, node, 1.8);
        case "h2":
          return _buildHeading(context, node, 1.5);
        case "h3":
          return _buildHeading(context, node, 1.3);
        case "h4":
          return _buildHeading(context, node, 1.15);
        case "h5":
        case "h6":
          return _buildHeading(context, node, 1.05);

        case "hr":
        case "app-hr":
          return const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1, thickness: 1));

        case "blockquote":
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: Theme.of(context).primaryColor, width: 3)),
              color: Theme.of(context).cardTheme.color?.withOpacity(0.4),
              borderRadius: const BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: node.nodes.map((child) => _buildNodeWidget(context, child)).whereType<Widget>().toList()),
          );

        case "pre":
          String codeContent = node.text;
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Theme.of(context).dividerColor.withOpacity(0.08), borderRadius: BorderRadius.circular(4)),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                codeContent,
                style: TextStyle(fontFamily: 'monospace', fontSize: (baseStyle.fontSize ?? 14) * 0.9, color: baseStyle.color),
              ),
            ),
          );

        case "ul":
          return _buildUnorderedList(context, node);

        case "ol":
          return _buildOrderedList(context, node);

        case "img":
          String? src = node.attributes["src"];
          if (src != null && src.isNotEmpty) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: HtmlImage(src: src),
            );
          }
          return null;

        case "app-player":
          String playerId = node.attributes["id"] ?? "";
          return _buildPlayerCard(context, playerId);

        case "app-user":
          String userId = node.attributes["id"] ?? "";
          return _buildUserCard(context, userId);

        case "app-floor":
          String floorId = node.attributes["id"] ?? "";
          return _buildFloorTag(context, floorId);

        case "app-icon":
          String iconName = node.attributes["icon"] ?? "";
          return _buildIconBadge(context, iconName);

        default:
          List<InlineSpan> spans = _buildInlineChildren(context, node, baseStyle);
          if (spans.isEmpty) {
            return null;
          }
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text.rich(TextSpan(children: spans, style: baseStyle)),
          );
      }
    }

    return null;
  }

  /**
   * 构建标题组件
   */
  Widget _buildHeading(BuildContext context, dom.Element node, double scale) {
    TextStyle headingStyle = baseStyle.copyWith(fontSize: (baseStyle.fontSize ?? 14) * scale, fontWeight: FontWeight.bold);
    List<InlineSpan> spans = _buildInlineChildren(context, node, headingStyle);
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text.rich(TextSpan(children: spans, style: headingStyle)),
    );
  }

  /**
   * 构建无序列表组件
   */
  Widget _buildUnorderedList(BuildContext context, dom.Element node) {
    List<Widget> items = [];
    for (dom.Element child in node.children) {
      if (child.localName?.toLowerCase() == "li") {
        List<InlineSpan> spans = _buildInlineChildren(context, child, baseStyle);
        items.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 4),
                Text("• ", style: baseStyle.copyWith(fontWeight: FontWeight.bold)),
                Expanded(
                  child: Text.rich(TextSpan(children: spans, style: baseStyle)),
                ),
              ],
            ),
          ),
        );
      }
    }
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 2, bottom: 2),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: items),
    );
  }

  /**
   * 构建有序列表组件
   */
  Widget _buildOrderedList(BuildContext context, dom.Element node) {
    List<Widget> items = [];
    int index = 1;
    for (dom.Element child in node.children) {
      if (child.localName?.toLowerCase() == "li") {
        List<InlineSpan> spans = _buildInlineChildren(context, child, baseStyle);
        items.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 4),
                Text("$index. ", style: baseStyle.copyWith(fontWeight: FontWeight.bold)),
                Expanded(
                  child: Text.rich(TextSpan(children: spans, style: baseStyle)),
                ),
              ],
            ),
          ),
        );
        index++;
      }
    }
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 2, bottom: 2),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: items),
    );
  }

  /**
   * 递归解析行内子节点，返回 InlineSpan 列表
   */
  List<InlineSpan> _buildInlineChildren(BuildContext context, dom.Node parent, TextStyle currentStyle) {
    List<InlineSpan> spans = [];

    for (dom.Node child in parent.nodes) {
      if (child is dom.Text) {
        spans.addAll(_parseTextWithTokens(context, child.text, currentStyle));
      } else if (child is dom.Element) {
        String tag = child.localName?.toLowerCase() ?? "";

        switch (tag) {
          case "b":
          case "strong":
            TextStyle boldStyle = currentStyle.copyWith(fontWeight: FontWeight.bold);
            spans.addAll(_buildInlineChildren(context, child, boldStyle));
            break;

          case "i":
          case "em":
            TextStyle italicStyle = currentStyle.copyWith(fontStyle: FontStyle.italic);
            spans.addAll(_buildInlineChildren(context, child, italicStyle));
            break;

          case "u":
            TextStyle underlineStyle = currentStyle.copyWith(decoration: TextDecoration.underline);
            spans.addAll(_buildInlineChildren(context, child, underlineStyle));
            break;

          case "s":
          case "del":
          case "strike":
            TextStyle strikeStyle = currentStyle.copyWith(decoration: TextDecoration.lineThrough);
            spans.addAll(_buildInlineChildren(context, child, strikeStyle));
            break;

          case "code":
            TextStyle codeStyle = currentStyle.copyWith(fontFamily: 'monospace', backgroundColor: Theme.of(context).dividerColor.withOpacity(0.12));
            spans.addAll(_buildInlineChildren(context, child, codeStyle));
            break;

          case "br":
            spans.add(const TextSpan(text: "\n"));
            break;

          case "a":
            String href = child.attributes["href"] ?? "";
            String linkText = child.text.isEmpty ? href : child.text;
            TextStyle linkStyle = currentStyle.copyWith(color: Theme.of(context).primaryColor, decoration: TextDecoration.underline);
            spans.add(
              TextSpan(
                text: linkText,
                style: linkStyle,
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    _handleLinkClick(context, href);
                  },
              ),
            );
            break;

          case "img":
            String? src = child.attributes["src"];
            if (src != null && src.isNotEmpty) {
              spans.add(
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                    constraints: const BoxConstraints(maxWidth: 320, maxHeight: 220),
                    child: HtmlImage(src: src),
                  ),
                ),
              );
            }
            break;

          case "app-player":
            String id = child.attributes["id"] ?? "";
            spans.add(WidgetSpan(alignment: PlaceholderAlignment.middle, child: _buildInlinePlayerChip(context, id)));
            break;

          case "app-user":
            String id = child.attributes["id"] ?? "";
            spans.add(WidgetSpan(alignment: PlaceholderAlignment.middle, child: _buildInlineUserChip(context, id)));
            break;

          case "app-floor":
            String id = child.attributes["id"] ?? "";
            spans.add(WidgetSpan(alignment: PlaceholderAlignment.middle, child: _buildFloorTag(context, id)));
            break;

          default:
            spans.addAll(_buildInlineChildren(context, child, currentStyle));
            break;
        }
      }
    }

    return spans;
  }

  /**
   * 解析纯文本中的各种特殊标记（缩语、表情、自动链接等）
   */
  List<InlineSpan> _parseTextWithTokens(BuildContext context, String rawText, TextStyle style) {
    if (rawText.isEmpty) {
      return [];
    }

    // 综合正则表达式匹配缩语 {type:value}、表情 [type|name]、网址链接
    RegExp tokenRegex = RegExp(r'(\{([a-zA-Z0-9_-]+)(?::([^}]+))?\})|(\[([a-zA-Z0-9_-]+)\|([^\]]+)\])|((https?:\/\/[^\s<"]+))');

    List<InlineSpan> spans = [];
    int lastEnd = 0;

    for (Match match in tokenRegex.allMatches(rawText)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: rawText.substring(lastEnd, match.start), style: style));
      }

      String matchedStr = match.group(0)!;

      // 缩语匹配
      if (matchedStr.startsWith('{') && matchedStr.endsWith('}')) {
        String csType = match.group(2) ?? "";
        String csValue = match.group(3) ?? "";
        InlineSpan? span = _buildContractedSyntaxSpan(context, csType, csValue, style);
        if (span != null) {
          spans.add(span);
        } else {
          spans.add(TextSpan(text: matchedStr, style: style));
        }
      }
      // 表情匹配
      else if (matchedStr.startsWith('[') && matchedStr.endsWith(']')) {
        String emoteType = match.group(5) ?? "";
        String emoteName = match.group(6) ?? "";
        spans.add(WidgetSpan(alignment: PlaceholderAlignment.middle, child: _buildEmoteWidget(context, emoteType, emoteName)));
      }
      // 网址链接自动识别
      else if (matchedStr.startsWith('http://') || matchedStr.startsWith('https://')) {
        TextStyle linkStyle = style.copyWith(color: Theme.of(context).primaryColor, decoration: TextDecoration.underline);
        spans.add(
          TextSpan(
            text: matchedStr,
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                _handleLinkClick(context, matchedStr);
              },
          ),
        );
      }

      lastEnd = match.end;
    }

    if (lastEnd < rawText.length) {
      spans.add(TextSpan(text: rawText.substring(lastEnd), style: style));
    }

    return spans;
  }

  /**
   * 处理缩语语法的行内跨度构建
   */
  InlineSpan? _buildContractedSyntaxSpan(BuildContext context, String type, String value, TextStyle style) {
    switch (type.toLowerCase()) {
      case "user":
        return WidgetSpan(alignment: PlaceholderAlignment.middle, child: _buildInlineUserChip(context, value));
      case "player":
        return WidgetSpan(alignment: PlaceholderAlignment.middle, child: _buildInlinePlayerChip(context, value));
      case "floor":
        return WidgetSpan(alignment: PlaceholderAlignment.middle, child: _buildFloorTag(context, value));
      case "router":
        TextStyle routeLinkStyle = style.copyWith(color: Theme.of(context).primaryColor, decoration: TextDecoration.underline);
        return TextSpan(
          text: value,
          style: routeLinkStyle,
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              UrlUtil().opEnPage(context, value);
            },
        );
      case "privilege":
        return WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(3)),
            child: Text(
              value,
              style: TextStyle(fontSize: (style.fontSize ?? 14) * 0.8, color: Theme.of(context).colorScheme.onPrimaryContainer),
            ),
          ),
        );
      case "signature":
        return WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            constraints: const BoxConstraints(maxHeight: 120),
            child: HtmlImage(src: value),
          ),
        );
      case "icon":
        return WidgetSpan(alignment: PlaceholderAlignment.middle, child: _buildIconBadge(context, value));
      default:
        return null;
    }
  }

  /**
   * 行内用户标签
   */
  Widget _buildInlineUserChip(BuildContext context, String userId) {
    return GestureDetector(
      onTap: () {
        UrlUtil().opEnPage(context, "/account/$userId");
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person, size: 13, color: Theme.of(context).primaryColor),
            const SizedBox(width: 2),
            Text(
              "@$userId",
              style: TextStyle(fontSize: (baseStyle.fontSize ?? 14) * 0.85, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  /**
   * 行内玩家标签
   */
  Widget _buildInlinePlayerChip(BuildContext context, String playerId) {
    return GestureDetector(
      onTap: () {
        UrlUtil().opEnPage(context, "/player/$playerId");
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sports_esports, size: 13, color: Colors.deepOrange),
            const SizedBox(width: 2),
            Text(
              playerId,
              style: TextStyle(fontSize: (baseStyle.fontSize ?? 14) * 0.85, color: Colors.deepOrange, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  /**
   * 楼层标签组件
   */
  Widget _buildFloorTag(BuildContext context, String floorId) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(color: Theme.of(context).dividerColor.withOpacity(0.15), borderRadius: BorderRadius.circular(3)),
      child: Text(
        "#$floorId",
        style: TextStyle(fontSize: (baseStyle.fontSize ?? 14) * 0.85, color: Theme.of(context).textTheme.bodySmall?.color, fontWeight: FontWeight.bold),
      ),
    );
  }

  /**
   * 图标徽章组件
   */
  Widget _buildIconBadge(BuildContext context, String iconName) {
    IconData iconData = Icons.link;
    if (iconName.contains("user") || iconName.contains("person")) {
      iconData = Icons.person;
    } else if (iconName.contains("egg")) {
      iconData = Icons.egg;
    } else if (iconName.contains("image")) {
      iconData = Icons.image;
    }

    return Icon(iconData, size: (baseStyle.fontSize ?? 14) * 1.1, color: Theme.of(context).primaryColor);
  }

  /**
   * 表情渲染组件
   */
  Widget _buildEmoteWidget(BuildContext context, String type, String name) {
    // 常用 Unicode Emoji 快速映射
    Map<String, String> commonEmojiMap = {"smile": "😊", "grinning": "😀", "grin": "😁", "joy": "😂", "rolling-on-the-floor-laughing": "🤣", "smiley": "😃", "sweat-smile": "😅", "laughing": "😆", "wink": "😉", "blush": "😊", "yum": "😋", "sunglasses": "😎", "heart-eyes": "😍", "kissing-heart": "😘", "thinking-face": "🤔", "neutral-face": "😐", "expressionless": "😑", "no-mouth": "😶", "smirk": "😏", "unamused": "😒", "heart": "❤️", "thumbsup": "👍", "thumbsdown": "👎", "clap": "👏", "pray": "🙏", "fire": "🔥", "100": "💯", "tada": "🎉"};

    String? unicodeEmoji = commonEmojiMap[name.toLowerCase()];
    if (unicodeEmoji != null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 1),
        child: Text(unicodeEmoji, style: TextStyle(fontSize: (baseStyle.fontSize ?? 14) * 1.2)),
      );
    }

    // 默认回退为表情胶囊
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
      child: Text(
        "[$name]",
        style: TextStyle(fontSize: (baseStyle.fontSize ?? 14) * 0.8, color: Theme.of(context).primaryColor),
      ),
    );
  }

  /**
   * 玩家卡片块级视图
   */
  Widget _buildPlayerCard(BuildContext context, String playerId) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Theme.of(context).dividerTheme.color ?? Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.orange.withOpacity(0.12), shape: BoxShape.circle),
            child: const Icon(Icons.sports_esports, color: Colors.orange, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(playerId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("BFBAN 档案记录", style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {
              UrlUtil().opEnPage(context, "/player/$playerId");
            },
            child: const Text("查看"),
          ),
        ],
      ),
    );
  }

  /**
   * 用户卡片块级视图
   */
  Widget _buildUserCard(BuildContext context, String userId) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Theme.of(context).dividerTheme.color ?? Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.12), shape: BoxShape.circle),
            child: Icon(Icons.person, color: Theme.of(context).primaryColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("@$userId", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text("BFBAN 社区成员", style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {
              UrlUtil().opEnPage(context, "/account/$userId");
            },
            child: const Text("访问主页"),
          ),
        ],
      ),
    );
  }

  /**
   * 统一链接点击处理
   */
  void _handleLinkClick(BuildContext context, String url) async {
    if (onLinkTap != null) {
      onLinkTap!(url);
      return;
    }

    if (url.isEmpty) return;

    // 站内相对路由直接内部跳转
    if (url.startsWith('/')) {
      UrlUtil().opEnPage(context, url);
      return;
    }

    Uri? uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
