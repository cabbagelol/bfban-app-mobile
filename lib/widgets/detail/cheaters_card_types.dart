/// 作弊玩家档案 日历卡片
/// 存放日历卡片的模板

import 'dart:convert' show jsonEncode;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:fluro/fluro.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_elui_plugin/elui.dart';

import 'package:bfban/utils/index.dart';
import 'package:bfban/widgets/index.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

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
          onTap: () => {_urlUtil.onPeUrl(context.tree.element!.attributes["href"].toString())},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text.rich(
              TextSpan(
                children: [
                  const WidgetSpan(child: Icon(Icons.insert_link,size: 15)),
                  TextSpan(text: context.tree.element!.text, style: TextStyle(decoration: TextDecoration.underline, decorationStyle: TextDecorationStyle.dashed)),
                ],
              ),
            ),
          ),
        ),
      ),
      imagesMatcher(): CustomRender.widget(
        widget: (RenderContext context, buildChildren) {
          return GestureDetector(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 3),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: "${context.tree.element!.attributes['src']}",
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (BuildContext buildContext, String url) {
                      return Card(
                        margin: EdgeInsets.zero,
                        color: Theme.of(buildContext).cardColor,
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
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
                                      child: ELuiLoadComponent(
                                        type: "line",
                                        color: Colors.white10,
                                        size: 15,
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
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.only(top: 40, left: 40, right: 5, bottom: 5),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black87,
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.search,
                        color: Colors.white70,
                        size: 30,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.only(top: 40, left: 40, right: 5, bottom: 5),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white70,
                        size: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              // 打开图片
              onImageTap(contextView, context.tree.element!.attributes['src'].toString());
            },
          );
        },
      ),
    };
  }

  /// [Event]
  /// 配置html 样式表
  Map<String, Style> styleHtml(BuildContext context) {
    return {
      "img": Style(
        margin: Margins.symmetric(vertical: 20),
      ),
      "p": Style(
        margin: Margins.symmetric(vertical: 5),
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

/// 统一回复按钮
class ReplyButtonWidget extends StatelessWidget {
  // 单条数据
  Map? data;

  // 楼层
  num? floor = 0;

  final CardUtil cardUtil = CardUtil();

  ReplyButtonWidget({
    Key? key,
    this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      iconSize: 18,
      splashRadius: 10,
      onSelected: (value) async {
        switch (value) {
          case 1:
            cardUtil._setReply(context, type: 1, floor: floor, toPlayerId: data!["id"], toCommentId: data!["id"]);
            break;
        }
      },
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            value: 1,
            height: 40,
            child: I18nText("basic.button.reply", child: const Text("")),
          ),
        ];
      },
    );
  }
}

/// 时间轴卡片
/// Core Card
class TimeLineCard extends StatelessWidget {
  final List<Widget>? header;
  final Widget? headerSecondary;
  final Widget? content;
  final Widget? button;

  const TimeLineCard({
    Key? key,
    this.header,
    this.headerSecondary,
    this.content,
    this.button,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 卡片标题
          Container(
            margin: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: header!,
            ),
          ),

          headerSecondary!,

          // 内容
          content!,
        ],
      ),
    );
  }
}

/// 回复
class CheatUserCheatersCard extends StatelessWidget {
  // 单条数据
  late Map data;

  // 位置
  late int index = 0;

  final Function onReplySucceed;

  final CardUtil _detailApi = CardUtil();

  CheatUserCheatersCard({
    Key? key,
    required this.onReplySucceed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TimeLineCard(
      header: [
        CircleAvatar(
          child: Text(data["username"][0].toString()),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Wrap(
                runAlignment: WrapAlignment.center,
                children: <Widget>[
                  // 类型
                  Text.rich(
                    TextSpan(
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: data["username"] + "\t",
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                            decorationStyle: TextDecorationStyle.dotted,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              _detailApi.openPlayerDetail(context, data["byUserId"]);
                            },
                        ),
                        TextSpan(
                          text: FlutterI18n.translate(context, "basic.button.reply"),
                          style: const TextStyle(
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Text(
                "${Date().getTimestampTransferCharacter(data['createTime'])["Y_D_M"]}",
                style: TextStyle(
                  color: Theme.of(context).textTheme.subtitle2!.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        ReplyButtonWidget(data: data)..floor = index,
      ],
      headerSecondary: data["quote"] != null
          ? Card(
              margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
              color: Theme.of(context).primaryColorDark.withOpacity(.2),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      data["quote"]["username"].toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox(),
      content: Offstage(
        offstage: data["content"] == "",
        child: Container(
          color: Theme.of(context).appBarTheme.backgroundColor!.withOpacity(.4),
          child: Html(
            data: data["content"],
            style: _detailApi.styleHtml(context),
            customRenders: _detailApi.customRenders(context),
          ),
        ),
      ),
    );
  }
}
