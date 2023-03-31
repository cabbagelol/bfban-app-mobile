/// 作弊玩家档案 日历卡片
/// 存放日历卡片的模板

import 'dart:convert' show jsonEncode;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:fluro/fluro.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_elui_plugin/elui.dart';

import 'package:bfban/utils/index.dart';
import 'package:bfban/widgets/index.dart';
import 'package:url_launcher/url_launcher.dart';

/// 卡片内置公共
class CardUtil {
  final UrlUtil _urlUtil = UrlUtil();

  /// [Event]
  /// 自定义控件
  customRenders(contextView) {
    // 链接
    CustomRenderMatcher linkMatcher() => (context) => context.tree.element?.localName == 'a';
    // 图片
    CustomRenderMatcher imagesMatcher() => (context) => context.tree.element?.localName == 'img';

    return {
      linkMatcher(): CustomRender.widget(
        widget: (RenderContext context, buildChildren) => GestureDetector(
          onTap: () => {
            _urlUtil.onPeUrl(
              context.tree.element!.attributes["href"].toString(),
              mode: LaunchMode.externalNonBrowserApplication,
            )
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text.rich(
              TextSpan(
                children: [
                  const WidgetSpan(child: Icon(Icons.insert_link, size: 15)),
                  TextSpan(text: context.tree.element!.text, style: const TextStyle(decoration: TextDecoration.underline, decorationStyle: TextDecorationStyle.dashed)),
                ],
              ),
            ),
          ),
        ),
      ),
      imagesMatcher(): CustomRender.widget(
        widget: (RenderContext context, buildChildren) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              color: context.style.color,
              child: Stack(
                children: [
                  GestureDetector(
                    child: CachedNetworkImage(
                      imageUrl: "${context.tree.element!.attributes['src']}",
                      width: double.infinity,
                      fit: BoxFit.cover,
                      imageBuilder: (BuildContext buildContext, ImageProvider imageProvider) {
                        return Column(
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
                                      "${context.tree.element!.attributes['src']}",
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12),
                                      maxLines: 1,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.link,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                            Image(image: imageProvider),
                          ],
                        );
                      },
                      placeholderFadeInDuration: const Duration(seconds: 0),
                      placeholder: (BuildContext buildContext, String url) {
                        return Card(
                          margin: EdgeInsets.zero,
                          color: context.style.backgroundColor!.withOpacity(.1),
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
                            child: Center(
                              child: Column(
                                children: [
                                  Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      const Icon(Icons.image, size: 50),
                                      Positioned(
                                        top: -2,
                                        right: -2,
                                        child: ELuiLoadComponent(
                                          type: "line",
                                          color: Theme.of(buildContext).appBarTheme.backgroundColor!,
                                          size: 17,
                                          lineWidth: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Opacity(
                                    opacity: .5,
                                    child: Text(
                                      "${context.tree.element!.attributes['src']}",
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      errorWidget: (BuildContext buildContext, String url, dynamic error) {
                        return Card(
                          margin: EdgeInsets.zero,
                          color: context.style.backgroundColor!.withOpacity(.1),
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
                            child: Center(
                              child: Column(
                                children: [
                                  Stack(
                                    clipBehavior: Clip.none,
                                    children: const [
                                      Icon(Icons.image, size: 50),
                                      Positioned(
                                        top: -5,
                                        right: -5,
                                        child: Icon(
                                          Icons.error,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Opacity(
                                    opacity: .5,
                                    child: Text(
                                      "${context.tree.element!.attributes['src']}",
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    onTap: () {
                      // 打开图片
                      onImageTap(contextView, context.tree.element!.attributes['src'].toString());
                    },
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.only(top: 40, left: 40, right: 5, bottom: 5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withOpacity(.4),
                          ],
                        ),
                      ),
                      child: Icon(
                        Icons.search,
                        color: context.style.color,
                        size: 30,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.only(top: 40, left: 40, right: 5, bottom: 5),
                      child: Icon(
                        Icons.add,
                        color: context.style.color,
                        size: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    };
  }

  /// [Event]
  /// 配置html 样式表
  Map<String, Style> styleHtml(BuildContext context) {
    return {
      "body": Style(
        padding: EdgeInsets.zero,
        margin: Margins.zero,
      ),
      "img": Style(color: Theme.of(context).primaryColorDark, padding: const EdgeInsets.symmetric(vertical: 5)),
      "p": Style(
        fontSize: FontSize(15),
        color: Theme.of(context).textTheme.subtitle1!.color,
      ),
    };
  }

  /// [Event]
  /// 楼层
  Widget getFloor(int index) {
    return Container(
      margin: const EdgeInsets.only(right: 5),
      child: Text("#$index "),
    );
  }

  /// [Event]
  /// 查看用户ID信息
  void openPlayerDetail(context, id) {
    _urlUtil.opEnPage(context, '/account/$id', transition: TransitionType.cupertino);
  }

  /// [Event]
  /// 查看图片
  void onImageTap(context, String img) {
    Navigator.of(context).push(CupertinoPageRoute(
      builder: (BuildContext context) {
        return PhotoViewSimpleScreen(
          imageUrl: img,
          imageProvider: NetworkImage(img),
          heroTag: 'simple',
        );
      },
    ));
  }

  /// [Event]
  /// 用户回复
  dynamic _setReply(context, {type, floor, toCommentId, toPlayerId}) {
    // 检查登录状态
    if (!ProviderUtil().ofUser(context).checkLogin()) return;

    String content = jsonEncode({
      "type": type,
      "toCommentId": toCommentId,
      "toPlayerId": toPlayerId,
    });

    _urlUtil.opEnPage(context, "/reply/$content");
  }
}

enum TimeLineItemType {
  none,
  reply,
  report,
  judgement,
  banAppeal,
}

/// 时间轴卡
/// Core Card
class TimeLineCard extends StatelessWidget {
  List<Widget>? header;
  Widget? headerSecondary;
  Widget? content;
  TimeLineItemBottomBtn? bottom;
  Widget? button;

  List? leftIconTypes = [
    CircleAvatar(
      backgroundColor: Colors.blue.withOpacity(.2),
      child: const Icon(
        Icons.help,
        color: Colors.red,
      ),
    ),
    CircleAvatar(
      backgroundColor: Colors.blue.withOpacity(.2),
      child: const Icon(
        Icons.chat_bubble_outlined,
        color: Colors.blue,
      ),
    ),
    CircleAvatar(
      backgroundColor: Colors.white.withOpacity(.2),
      child: const Icon(Icons.front_hand),
    ),
    CircleAvatar(
      backgroundColor: const Color(0xFF3d1380).withOpacity(.8),
      child: const Icon(
        Icons.chat_rounded,
        color: Colors.white,
      ),
    ),
    CircleAvatar(
      backgroundColor: const Color(0xFFeb2f96).withOpacity(.2),
      child: const Icon(
        Icons.bookmark,
        color: Color(0xFFeb2f96),
      ),
    )
  ];
  Widget? leftIcon;

  TimeLineCard({
    Key? key,
    TimeLineItemType type = TimeLineItemType.none,
    this.header,
    this.headerSecondary,
    this.content,
    this.button,
    this.bottom,
  }) : super(key: key) {
    leftIcon = leftIconTypes![type.index];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: [
          const Divider(height: 1),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
                child: leftIcon!,
              ),
              Flexible(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // 卡片标题
                    Container(
                      margin: const EdgeInsets.only(right: 10, top: 20, bottom: 10),
                      child: Wrap(
                        children: header!,
                      ),
                    ),

                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: Column(
                        children: [
                          if (headerSecondary != null) headerSecondary!,

                          // 内容
                          content!,
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (bottom != null)
            Container(
              margin: const EdgeInsets.only(top: 3, left: 50, right: 10),
              child: Column(
                children: [
                  bottom!,
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// 时间轴按钮集
/// [时间轴卡] 下的按钮集合
class TimeLineItemBottomBtn extends StatefulWidget {
  Map? data;
  num? floor;
  bool isShowReply;
  bool isShowShare;

  TimeLineItemBottomBtn({
    Key? key,
    this.data,
    this.floor,
    this.isShowReply = false,
    this.isShowShare = false,
  }) : super(key: key);

  @override
  State<TimeLineItemBottomBtn> createState() => _TimeLineItemBottomBtnState();
}

class _TimeLineItemBottomBtnState extends State<TimeLineItemBottomBtn> {
  final CardUtil cardUtil = CardUtil();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (widget.isShowReply)
          IconButton(
            onPressed: () {
              cardUtil._setReply(
                context,
                type: 1,
                floor: widget.floor,
                toPlayerId: widget.data!["id"],
                toCommentId: widget.data!["id"],
              );
            },
            icon: const Icon(
              Icons.quickreply_outlined,
            ),
          ),
        if (widget.isShowShare)
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.share_outlined,
            ),
          ),
      ],
    );
  }
}
