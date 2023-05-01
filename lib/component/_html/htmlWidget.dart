import 'dart:convert';

import 'package:bfban/component/_html/html.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:fluro/fluro.dart';
import 'package:flutter_elui_plugin/elui.dart';

import 'package:bfban/utils/index.dart';

import '../../constants/api.dart';
import 'htmlImage.dart';
import 'htmlLink.dart';

enum HtmlWidgetFontSize {
  Large,
  Default,
  Small,
}

class HtmlWidget extends StatefulWidget {
  String? content;
  HtmlWidgetFontSize? size;
  List sizeConfig = [];
  Widget? quote;

  HtmlWidget({
    Key? key,
    this.content,
    HtmlWidgetFontSize? size = HtmlWidgetFontSize.Default,
    this.quote,
  }) : super(key: key);

  @override
  State<HtmlWidget> createState() => _HtmlWidgetState();
}

class _HtmlWidgetState extends State<HtmlWidget> {
  Future? futureBuilder;

  List htmlStyle = [];

  List dropdownSizeType = [
    {"name": "large", "value": "0"},
    {"name": "default", "value": "1"},
    {"name": "small", "value": "2"},
  ];

  List dropdownRenderingMethods = [
    {"name": "code", "value": "0"},
    {"name": "render", "value": "1"},
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    futureBuilder = onReady();
    super.didChangeDependencies();
  }

  Future onReady() async {
    htmlStyle = [
      {
        "app-hr": Style(margin: Margins.symmetric(horizontal: -10, vertical: 5)),
        "body": Style(
          fontSize: FontSize(12),
        ),
        "img": Style(color: Theme.of(context).primaryColorDark, padding: const EdgeInsets.symmetric(vertical: 5)),
        "p": Style(
          color: Theme.of(context).textTheme.displayMedium!.color,
        ),
      },
      {
        "app-hr": Style(margin: Margins.symmetric(horizontal: -10, vertical: 10)),
        "body": Style(
          fontSize: FontSize(15),
        ),
        "img": Style(color: Theme.of(context).primaryColorDark, padding: const EdgeInsets.symmetric(vertical: 5)),
        "p": Style(
          color: Theme.of(context).textTheme.displayMedium!.color,
        ),
      },
      {
        "app-hr": Style(margin: Margins.symmetric(horizontal: -10, vertical: 15)),
        "body": Style(
          fontSize: FontSize(20),
        ),
        "img": Style(color: Theme.of(context).primaryColorDark, padding: const EdgeInsets.symmetric(vertical: 5)),
        "p": Style(
          color: Theme.of(context).textTheme.displayMedium!.color,
        ),
      }
    ];
    return htmlStyle;
  }

  dynamic dropdownSizeTypeSelectedValue = "1";
  dynamic dropdownRenderingSelectedValue = "1";

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: widget.content == "",
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          border: Border.all(color: Theme.of(context).dividerTheme.color!, width: 1),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.quote != null) widget.quote!,
            [
              Container(
                margin: const EdgeInsets.all(8),
                child: SelectableHtml(
                  data: htmlEscape.convert(widget.content.toString()),
                  style: htmlStyle[int.parse(dropdownSizeTypeSelectedValue)],
                ),
              ),
              SelectionArea(
                child: HtmlCore(
                  data: widget.content,
                  style: htmlStyle[int.parse(dropdownSizeTypeSelectedValue)],
                ),
              ),
            ][int.parse(dropdownRenderingSelectedValue)],
            const Divider(height: 1),
            SizedBox(
              height: 20,
              child: Row(
                children: [
                  InkWell(
                    child: Container(
                      margin: const EdgeInsets.only(left: 4),
                      child: const Icon(Icons.fullscreen, size: 16),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return Scaffold(
                              appBar: AppBar(),
                              body: ListView(
                                children: [
                                  HtmlCore(
                                    data: widget.content,
                                    style: htmlStyle[2],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const Expanded(child: SizedBox(width: 1)),
                  DropdownButton(
                    underline: Container(),
                    dropdownColor: Theme.of(context).bottomAppBarTheme.color,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                    ),
                    items: dropdownSizeType.map<DropdownMenuItem<String>>((e) {
                      return DropdownMenuItem(
                        value: e["value"],
                        child: Text(e["name"]),
                      );
                    }).toList(),
                    value: dropdownSizeTypeSelectedValue,
                    onChanged: (selected) {
                      setState(() {
                        dropdownSizeTypeSelectedValue = selected;
                      });
                    },
                  ),
                  const SizedBox(
                    width: 20,
                    height: 8,
                    child: VerticalDivider(width: 1),
                  ),
                  DropdownButton(
                    elevation: 2,
                    underline: Container(),
                    dropdownColor: Theme.of(context).bottomAppBarTheme.color,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                    ),
                    items: dropdownRenderingMethods.map<DropdownMenuItem<String>>((e) {
                      return DropdownMenuItem(
                        value: e["value"],
                        child: Text(e["name"]),
                      );
                    }).toList(),
                    value: dropdownRenderingSelectedValue,
                    onChanged: (selected) {
                      setState(() {
                        dropdownRenderingSelectedValue = selected;
                      });
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

/// 卡片内置公共
class CardUtil {
  final UrlUtil _urlUtil = UrlUtil();

  /// [Event]
  /// 自定义控件
  customRenders(contextView) {
    // 链接
    CustomRenderMatcher linkMatcher() => (context) => context.tree.element?.localName == "a";
    // 图片
    CustomRenderMatcher imagesMatcher() => (context) => context.tree.element?.localName == "img";
    // hr
    CustomRenderMatcher dividerMatcher() => (context) => context.tree.element?.localName == "app-hr";
    // app-icon
    CustomRenderMatcher appIconMatcher() => (context) => context.tree.element?.localName == "app-icon";
    // app-player
    CustomRenderMatcher appPlayerMatcher() => (context) => context.tree.element?.localName == "app-player";
    // app-user
    CustomRenderMatcher appUserMatcher() => (context) => context.tree.element?.localName == "app-user";
    // app-floor
    CustomRenderMatcher appFloorMatcher() => (context) => context.tree.element?.localName == "app-floor";

    return {
      linkMatcher(): CustomRender.widget(
        widget: (RenderContext context, buildChildren) {
          return HtmlLink(
            renderContext: context,
            url: context.tree.element!.attributes["href"],
            text: context.tree.element!.text,
          );
        },
      ),
      imagesMatcher(): CustomRender.widget(
        widget: (RenderContext context, buildChildren) {
          return HtmlImage(
            src: context.tree.element!.attributes["src"],
            color: context.style.color,
            backgroundColor: context.style.backgroundColor,
          );
        },
      ),
      dividerMatcher(): CustomRender.widget(
        widget: (RenderContext context, buildChildren) => const Divider(height: 10),
      ),
      appIconMatcher(): CustomRender.widget(
        widget: (RenderContext context, buildChildren) => Tooltip(
          message: "APP does not support ICON rendering",
          child: Card(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
              child: const Icon(Icons.error, size: 16),
            ),
          ),
        ),
      ),
      appPlayerMatcher(): CustomRender.widget(
        widget: (RenderContext context, buildChildren) {
          String url = "${Config.apiHost["web_site"]!.url}/player/${context.tree.element!.attributes['id']}/share/card?full=true&theme=default&lang=zh-CN";
          WebViewController webViewController = WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setBackgroundColor(context.style.color!)
            ..loadRequest(Uri.parse(url));

          return ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Container(
              constraints: const BoxConstraints(
                minHeight: 200,
                maxHeight: 350,
              ),
              color: context.style.color!.withOpacity(.5),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    height: 25,
                    child: Row(
                      textBaseline: TextBaseline.ideographic,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            url,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                            maxLines: 1,
                          ),
                        ),
                        const Icon(
                          Icons.widgets_outlined,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: WebViewWidget(controller: webViewController),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      appUserMatcher(): CustomRender.widget(
        widget: (RenderContext context, buildChildren) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                child: Text("@${context.tree.element!.attributes['id']}"),
              ),
            ),
            const SizedBox(height: 5),
            EluiTipComponent(
              type: EluiTip.warning,
              child: const Text("APP does not support User module at the moment"),
            )
          ],
        ),
      ),
      appFloorMatcher(): CustomRender.widget(
        widget: (RenderContext context, buildChildren) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                child: Wrap(
                  children: [
                    const Icon(Icons.person, size: 18),
                    Text("${context.tree.element!.attributes['id']}"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 5),
            EluiTipComponent(
              type: EluiTip.warning,
              child: const Text("APP does not support floor module at the moment"),
            )
          ],
        ),
      ),
    };
  }

  /// [Event]
  /// 默认样式表
  Map<String, Style> styleHtml(BuildContext context) {
    return {
      "body": Style(
        padding: EdgeInsets.zero,
        margin: Margins.zero,
      ),
      "img": Style(color: Theme.of(context).primaryColorDark, padding: const EdgeInsets.symmetric(vertical: 5)),
      "p": Style(
        fontSize: FontSize(15),
        color: Theme.of(context).textTheme.displayMedium!.color,
      ),
    };
  }

  /// [Event]
  /// 查看用户ID信息
  void openPlayerDetail(context, id) {
    _urlUtil.opEnPage(context, '/account/$id', transition: TransitionType.cupertino);
  }

  /// [Event]
  /// 用户回复
  dynamic setReply(context, {type, floor, toCommentId, toPlayerId, callback}) {
    // 检查登录状态
    if (!ProviderUtil().ofUser(context).checkLogin()) return;

    String content = jsonEncode({
      "type": type,
      "toCommentId": toCommentId,
      "toPlayerId": toPlayerId,
    });

    _urlUtil.opEnPage(context, "/reply/$content").then((value) {
      if (callback) callback(value);
    });
  }
}
