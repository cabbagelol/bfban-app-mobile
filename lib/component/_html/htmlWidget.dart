import 'dart:convert';

import 'package:bfban/component/_html/html.dart';
import 'package:bfban/component/_html/htmlEmoji.dart';
import 'package:bfban/component/_html/htmlFullScreen.dart';
import 'package:bfban/component/_html/htmlTextTranslator.dart';
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
  String? id;
  bool? footerToolBar;

  // 选项变动
  Function? onChangeOption;

  HtmlWidget({
    super.key,
    this.content = "",
    HtmlWidgetFontSize? size = HtmlWidgetFontSize.Default,
    this.quote,
    this.id,
    this.footerToolBar = true,
    this.onChangeOption,
  });

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
        "app-hr,hr": Style(margin: Margins.symmetric(horizontal: -10, vertical: 15)),
        "body": Style(
          fontSize: FontSize(20),
        ),
        "img": Style(
          color: Theme.of(context).primaryColorDark,
          backgroundColor: Theme.of(context).primaryColorDark,
          margin: Margins.symmetric(vertical: 10),
        ),
        "p": Style(
          color: Theme.of(context).textTheme.displayMedium!.color,
          margin: Margins.symmetric(vertical: 3),
        ),
        "a": Style(color: Theme.of(context).primaryColorDark)
      },
      {
        "app-hr,hr": Style(margin: Margins.symmetric(horizontal: -10, vertical: 10)),
        "body": Style(
          fontSize: FontSize(15),
        ),
        "img": Style(
          color: Theme.of(context).primaryColorDark,
          backgroundColor: Theme.of(context).primaryColorDark,
          margin: Margins.symmetric(vertical: 7),
        ),
        "p": Style(
          color: Theme.of(context).textTheme.displayMedium!.color,
          margin: Margins.symmetric(vertical: 3),
        ),
        "a": Style(color: Theme.of(context).primaryColorDark),
      },
      {
        "app-hr,hr": Style(margin: Margins.symmetric(horizontal: -10, vertical: 5)),
        "body": Style(
          fontSize: FontSize(12),
        ),
        "img": Style(
          color: Theme.of(context).primaryColorDark,
          backgroundColor: Theme.of(context).primaryColorDark,
          margin: Margins.symmetric(vertical: 3),
        ),
        "p": Style(
          color: Theme.of(context).textTheme.displayMedium!.color,
          margin: Margins.zero,
        ),
        "a": Style(color: Theme.of(context).primaryColorDark)
      },
    ];
    return htmlStyle;
  }

  dynamic dropdownSizeTypeSelectedValue = "1";
  dynamic dropdownRenderingSelectedValue = "1";

  /// [Event]
  /// 全屏预览
  _opEnFullScreenPreview(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return HtmlFullScreen(
            content: widget.content!,
            style: htmlStyle[2],
          );
        },
      ),
    );
  }

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
            /// html widget content
            if (widget.quote != null) widget.quote!,

            SelectionArea(
              child: [
                Html(
                  data: htmlEscape.convert(widget.content ?? ""),
                  style: htmlStyle[int.parse(dropdownSizeTypeSelectedValue)],
                ),
                HtmlCore(
                  data: widget.content ?? "",
                  style: htmlStyle[int.parse(dropdownSizeTypeSelectedValue)],
                ),
              ][int.parse(dropdownRenderingSelectedValue)],
            ),
            HtmlTextTranslator(content: widget.content ?? ""),

            /// html widget footer bar
            if (widget.footerToolBar!)
              Divider(
                thickness: 1,
                height: 1,
                color: Theme.of(context).dividerColor.withOpacity(.08),
              ),
            if (widget.footerToolBar!)
              ClipPath(
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  height: 20,
                  child: Row(
                    children: [
                      InkWell(
                        child: Container(
                          margin: const EdgeInsets.only(left: 4),
                          child: const Icon(Icons.fullscreen, size: 16),
                        ),
                        onTap: () {
                          _opEnFullScreenPreview(context);
                        },
                      ),
                      const Expanded(flex: 2, child: SizedBox(width: 5)),
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

                          if (widget.onChangeOption != null) widget.onChangeOption!();
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

                          if (widget.onChangeOption != null) widget.onChangeOption!();
                        },
                      )
                    ],
                  ),
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
  List<HtmlExtension> customRenders() {
    return [
      // 换行
      // TagExtension(
      //   tagsToExtend: {"br"},
      //   builder: (extensionContext) {
      //     return Wrap(
      //       children: [
      //         Opacity(
      //           opacity: .5,
      //           child: SvgPicture.asset(
      //             "assets/images/wrap-icon.svg",
      //             allowDrawingOutsideViewBox: true,
      //             excludeFromSemantics: true,
      //             matchTextDirection: true,
      //             width: 10,
      //             height: 10,
      //             color: extensionContext.style!.color!,
      //           ),
      //         ),
      //       ],
      //     );
      //   },
      // ),
      // 链接
      TagExtension(
        tagsToExtend: {"a"},
        builder: (extensionContext) {
          return HtmlLink(
            color: extensionContext.style!.color,
            url: extensionContext.element!.attributes["href"],
            text: extensionContext.element!.text,
          );
        },
      ),
      // 图片
      TagExtension(
        tagsToExtend: {"img"},
        builder: (extensionContext) {
          Map<String, Widget> imgTypes = {
            'img': Container(
              margin: EdgeInsets.only(
                top: extensionContext.style!.margin!.top!.value,
                left: extensionContext.style!.margin!.left!.value,
                right: extensionContext.style!.margin!.right!.value,
                bottom: extensionContext.style!.margin!.bottom!.value,
              ),
              child: HtmlImage(
                src: extensionContext.node.attributes["src"] as String,
                color: extensionContext.style!.color,
                backgroundColor: extensionContext.style!.backgroundColor,
              ),
            ),
            'emoji': HtmlEmoji(
              attributes: extensionContext.node.attributes,
              color: extensionContext.style!.color,
              backgroundColor: extensionContext.style!.backgroundColor,
            )
          };
          String imgTypeName = 'img';

          // 地址包含base64，假定是表情
          if (extensionContext.node.attributes["src"]!.indexOf(';base64,') >= 0) imgTypeName = 'emoji';

          return imgTypes[imgTypeName]!;
        },
      ),
      // hr
      TagExtension(
        tagsToExtend: {"app-hr", "hr"},
        child: const Divider(height: 1),
      ),
      // app-icon
      TagExtension(
        tagsToExtend: {"app-icon"},
        builder: (extensionContext) {
          return Tooltip(
            message: "APP does not support ICON rendering",
            child: Card(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                child: const Icon(Icons.error, size: 16),
              ),
            ),
          );
        },
      ),
      // app-player
      TagExtension(
        tagsToExtend: {"app-player"},
        builder: (extensionContext) {
          String url = "${Config.apiHost["web_site"]!.url}/player/${extensionContext.element!.attributes['id']}/share/card?full=true&theme=default&lang=zh-CN";
          WebViewController webViewController = WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setBackgroundColor(extensionContext.style!.color!)
            ..loadRequest(Uri.parse(url));

          return ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Container(
              constraints: const BoxConstraints(
                minHeight: 200,
                maxHeight: 350,
              ),
              color: extensionContext.style!.color!.withOpacity(.5),
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
      // app-user
      TagExtension(
        tagsToExtend: {"app-user"},
        builder: (extensionContext) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                  child: Text("@${extensionContext.element!.attributes['id']}"),
                ),
              ),
              const SizedBox(height: 5),
              EluiTipComponent(
                type: EluiTip.warning,
                child: const Text("APP does not support User module at the moment"),
              )
            ],
          );
        },
      ),
      // app-floor
      TagExtension(
        tagsToExtend: {"app-floor"},
        builder: (extensionContext) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                  child: Wrap(
                    children: [
                      const Icon(Icons.person, size: 18),
                      Text("${extensionContext.element!.attributes['id']}"),
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
          );
        },
      ),
    ];
  }

  /// [Event]
  /// 默认样式表
  Map<String, Style> styleHtml(BuildContext context) {
    return {
      "app-hr,hr": Style(margin: Margins.symmetric(horizontal: -10, vertical: 10)),
      "body": Style(
        fontSize: FontSize(15),
      ),
      "img": Style(
        color: Theme.of(context).primaryColorDark,
        backgroundColor: Theme.of(context).primaryColorDark,
        margin: Margins.symmetric(vertical: 7),
      ),
      "p": Style(
        color: Theme.of(context).textTheme.displayMedium!.color,
        margin: Margins.symmetric(vertical: 3),
      ),
      "a": Style(color: Theme.of(context).primaryColorDark),
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
      if (callback != null) callback();
    });
  }
}
