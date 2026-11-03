import 'dart:convert';

import 'package:bfban/component/_html/html.dart';
import 'package:bfban/component/_html/htmlFullScreen.dart';
import 'package:bfban/component/_html/htmlTextTranslator.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

import 'package:bfban/utils/index.dart';

/**
 * 字体大小枚举配置
 */
enum HtmlWidgetFontSize {
  Large,
  Default,
  Small,
}

/**
 * 富文本与 HTML 原生展示封装组件
 */
class HtmlWidget extends StatefulWidget {
  /**
   * HTML 文本内容
   */
  final String? content;

  /**
   * 字号大小
   */
  late final HtmlWidgetFontSize? size;

  /**
   * 引用组件插槽
   */
  final Widget? quote;

  /**
   * 唯一标识
   */
  final String? id;

  /**
   * 是否展示底部控制栏
   */
  final bool? footerToolBar;

  /**
   * 是否带外边框
   */
  final bool isBorder;

  /**
   * 选项变动回调
   */
  final Function? onChangeOption;

  HtmlWidget({
    super.key,
    this.content = "",
    HtmlWidgetFontSize? size = HtmlWidgetFontSize.Default,
    this.quote,
    this.id,
    this.footerToolBar = true,
    this.onChangeOption,
    this.isBorder = true,
  }) {
    this.size = size;
  }

  @override
  State<HtmlWidget> createState() => HtmlWidgetState();
}

class HtmlWidgetState extends State<HtmlWidget> {
  // 字号大小选项
  List dropdownSizeType = [
    {"name": "large", "value": "0"},
    {"name": "default", "value": "1"},
    {"name": "small", "value": "2"},
  ];

  // 渲染模式选项
  List dropdownRenderingMethods = [
    {"name": "code", "value": "0"},
    {"name": "render", "value": "1"},
    {"name": "text", "value": "2"},
  ];

  // 当前选中的字号类型
  dynamic dropdownSizeTypeSelectedValue = "1";

  // 当前选中的渲染模式
  dynamic dropdownRenderingSelectedValue = "1";

  @override
  void initState() {
    super.initState();
    if (widget.size == HtmlWidgetFontSize.Large) {
      dropdownSizeTypeSelectedValue = "0";
    } else if (widget.size == HtmlWidgetFontSize.Small) {
      dropdownSizeTypeSelectedValue = "2";
    } else {
      dropdownSizeTypeSelectedValue = "1";
    }
  }

  /**
   * 获取当前字号大小数值
   */
  double _getCurrentFontSize() {
    switch (dropdownSizeTypeSelectedValue.toString()) {
      case "0":
        return 18.0;
      case "2":
        return 12.0;
      case "1":
      default:
        return 15.0;
    }
  }

  /**
   * 打开全屏预览
   */
  void _openFullScreenPreview(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return HtmlFullScreen(
            content: widget.content ?? "",
            style: const {},
          );
        },
      ),
    );
  }

  /**
   * 剥离 HTML 标签获取纯文本
   */
  String _stripHtml(String htmlString) {
    return htmlString.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ').trim();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.content == null || widget.content!.isEmpty) {
      return const SizedBox.shrink();
    }

    double currentFontSize = _getCurrentFontSize();

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          border: widget.isBorder ? Border.all(color: Theme
              .of(context)
              .dividerTheme
              .color ?? Colors.grey.shade300, width: 1) : null,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 引用插槽
            if (widget.quote != null) widget.quote!,

            // 核心内容区
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: SelectionArea(
                child: Builder(
                  builder: (context) {
                    switch (dropdownRenderingSelectedValue.toString()) {
                      case "0":
                      // 代码源码模式
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme
                                .of(context)
                                .dividerColor
                                .withOpacity(0.06),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: SelectableText(
                            widget.content ?? "",
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: currentFontSize * 0.9,
                              color: Theme
                                  .of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color,
                            ),
                          ),
                        );

                      case "2":
                      // 纯文本过滤模式
                        return SelectableText(
                          _stripHtml(widget.content ?? ""),
                          style: TextStyle(
                            fontSize: currentFontSize,
                            color: Theme
                                .of(context)
                                .textTheme
                                .bodyMedium
                                ?.color,
                            height: 1.5,
                          ),
                        );

                      case "1":
                      default:
                      // 原生富文本渲染模式
                        return HtmlCore(
                          data: widget.content ?? "",
                          fontSize: currentFontSize,
                        );
                    }
                  },
                ),
            ),
            ),

            // 翻译工具栏
            HtmlTextTranslator(content: widget.content ?? ""),

            // 底部控制工具栏
            if (widget.footerToolBar ?? true) ...[
              Divider(
                thickness: 1,
                height: 1,
                color: Theme
                    .of(context)
                    .dividerColor
                    .withValues(alpha: 0.08),
              ),
              SizedBox(
                height: 28,
                child: Material(
                  color: Colors.transparent,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: constraints.maxWidth),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.fullscreen, size: 16),
                                onPressed: () {
                                  _openFullScreenPreview(context);
                                },
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  DropdownButton<String>(
                                    underline: const SizedBox(),
                                    isDense: true,
                                    dropdownColor: Theme
                                        .of(context)
                                        .bottomAppBarTheme
                                        .color,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme
                                          .of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color,
                                    ),
                                    items: dropdownSizeType.map<DropdownMenuItem<String>>((e) {
                                      return DropdownMenuItem<String>(
                                        value: e["value"],
                                        child: Text(e["name"]),
                                      );
                                    }).toList(),
                                    value: dropdownSizeTypeSelectedValue,
                                    onChanged: (selected) {
                                      setState(() {
                                        dropdownSizeTypeSelectedValue = selected;
                                      });
                                      if (widget.onChangeOption != null) widget.onChangeOption!();
                                    },
                                  ),
                                  const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: VerticalDivider(width: 1),
                                  ),
                                  DropdownButton<String>(
                                    underline: const SizedBox(),
                                    isDense: true,
                                    dropdownColor: Theme
                                        .of(context)
                                        .bottomAppBarTheme
                                        .color,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme
                                          .of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color,
                                    ),
                                    items: dropdownRenderingMethods.map<DropdownMenuItem<String>>((e) {
                                      return DropdownMenuItem<String>(
                                        value: e["value"],
                                        child: Text(e["name"]),
                                      );
                                    }).toList(),
                                    value: dropdownRenderingSelectedValue,
                                    onChanged: (selected) {
                                      setState(() {
                                        dropdownRenderingSelectedValue = selected;
                                      });
                                      if (widget.onChangeOption != null) widget.onChangeOption!();
                                    },
                                  ),
                                  const SizedBox(width: 4),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/**
 * 卡片通用工具类
 */
class CardUtil {
  // 基础 URL 工具
  final UrlUtil _urlUtil = UrlUtil();

  /**
   * 默认样式表兼容配置
   */
  Map<String, dynamic> styleHtml(BuildContext context) {
    return {
      "body": TextStyle(
        fontSize: 15,
        color: Theme
            .of(context)
            .textTheme
            .bodyMedium
            ?.color,
      ),
      "p": TextStyle(
        color: Theme
            .of(context)
            .textTheme
            .bodyMedium
            ?.color,
      ),
      "a": TextStyle(
        color: Theme
            .of(context)
            .primaryColor,
      ),
    };
  }

  /**
   * 查看用户详情
   */
  void openPlayerDetail(BuildContext context, dynamic id) {
    _urlUtil.opEnPage(context, '/account/$id', transition: TransitionType.cupertino);
  }

  /**
   * 用户回复事件处理
   */
  dynamic setReply(BuildContext context, {dynamic type, dynamic floor, dynamic toCommentId, dynamic toPlayerId, Function? callback}) {
    if (!ProviderUtil().ofUser(context).checkLogin()) return;

    String content = jsonEncode({
      "type": type,
      "toCommentId": toCommentId,
      "toPlayerId": toPlayerId,
    });

    _urlUtil.opEnPage(context, "/reply/$content").then((value) {
      if (callback != null) callback();
    });
  }
}
