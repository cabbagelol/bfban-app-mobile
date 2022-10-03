/// 作弊玩家档案 日历卡片
/// 存放日历卡片的模板

import 'dart:convert' show jsonEncode;

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
    CustomRenderMatcher imgMatcher() => (context) => context.tree.element?.localName == 'img';

    return {
      linkMatcher(): CustomRender.widget(
        widget: (RenderContext context, buildChildren) => GestureDetector(
          onTap: () => {_urlUtil.onPeUrl(context.tree.element!.attributes["href"].toString())},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(2)),
            ),
            child: Wrap(
              spacing: 5,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Icon(
                  Icons.insert_link,
                ),
                Text.rich(
                  TextSpan(text: context.tree.element!.text),
                  style: const TextStyle(fontSize: 18),
                )
              ],
            ),
          ),
        ),
      ),
      imgMatcher(): CustomRender.widget(widget: (RenderContext context, buildChildren) {
        return GestureDetector(
          child: Card(
            borderOnForeground: true,
            elevation: 10,
            clipBehavior: Clip.hardEdge,
            margin: const EdgeInsets.symmetric(vertical: 5),
            child: Stack(
              children: [
                EluiImgComponent(
                  src: "${context.tree.element!.attributes['src']}?imageslim",
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                  errorWidget: const Icon(
                    Icons.error,
                    size: 50,
                    color: Colors.black54,
                  ),
                  isPlaceholder: true,
                  placeholder: (BuildContext context, String url) {
                    return const ELuiLoadComponent(
                      type: "line",
                      color: Colors.white12,
                      size: 20,
                      lineWidth: 2,
                    );
                  },
                ),
                Image.network(
                  context.tree.element!.attributes['src']! + "?imageslim",
                  fit: BoxFit.cover,
                  width: double.infinity,
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
      }),
    };
  }

  /// [Event]
  /// 配置html 样式表
  Map<String, Style> styleHtml(BuildContext context) {
    return {
      "*": Style(fontSize: FontSize(15), color: Theme.of(context).textTheme.subtitle1!.color),
    };
  }

  /// [Event]
  /// 楼层
  Widget getFloor(int index) {
    return Container(
      margin: const EdgeInsets.only(
        right: 5,
      ),
      child: Text("#$index "),
    );
  }

  /// [Event]
  /// 查看用户ID信息
  void openPlayerDetail(context, id) {
    _urlUtil.opEnPage(
      context,
      '/account/$id',
      transition: TransitionType.fadeIn,
    );
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

  /// [Widget]
  /// TODO 国际化
  /// TODO 身份列表应读身份表
  /// 身份 返回数据结构
  List getPrivilege(List privileges) {
    List privilegeList = [];
    Map privilegeConf = {
      "admin": {
        "name": "管理员",
        "backgroundColor": Colors.redAccent,
        "textColor": Colors.white,
      },
      "normal": {
        "name": "玩家",
        "backgroundColor": Colors.black,
        "textColor": Colors.amber,
      },
      "super": {
        "name": "超级管理",
        "backgroundColor": Colors.blueAccent,
        "textColor": Colors.white,
      },
      "": {
        "name": "未知",
        "backgroundColor": Colors.black,
        "textColor": Colors.white12,
      }
    };

    for (var i in privileges) {
      privilegeList.add(privilegeConf[i]);
    }

    return privilegeList;
  }

  /// [Event]
  /// 身份类型 返回Widget
  Widget getPrivilegeWidget(List privileges) {
    return Wrap(
      spacing: 5,
      runAlignment: WrapAlignment.center,
      children: privileges.map((e) {
        return I18nText("basic.privilege.$e", child: const Text(""));
      }).toList(),
    );
  }

  /// [Event]
  /// 用户回复
  dynamic _setReply(context, {type, floor, toCommentId, toPlayerId}) {
    // 检查登录状态
    if (!ProviderUtil().ofUser(context).checkLogin()) return;

    String content = jsonEncode({
      "type": type,
      "toFloor": floor,
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
      margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
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
                            text: data["username"],
                            style: const TextStyle(
                              decoration: TextDecoration.underline,
                              decorationStyle: TextDecorationStyle.dotted,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                _detailApi.openPlayerDetail(context, data["byUserId"]);
                              }),
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
      headerSecondary: data["quote"] != null ? Card(
        margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        color: Theme.of(context).appBarTheme.backgroundColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
      ) : const SizedBox(),
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

/// 举报
class CheatReportsCard extends StatelessWidget {
  // 单条数据
  late dynamic data;

  // 位置
  late int? index;

  final UrlUtil _urlUtil = UrlUtil();

  final CardUtil _detailApi = CardUtil();

  final Function onReplySucceed;

  CheatReportsCard({
    Key? key,
    required this.onReplySucceed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TimeLineCard(
      header: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Wrap(
                      runAlignment: WrapAlignment.center,
                      spacing: 5,
                      children: [
                        // 标题
                        Text.rich(
                          TextSpan(
                            style: const TextStyle(fontSize: 18),
                            children: <TextSpan>[
                              TextSpan(
                                text: data["username"],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                  decorationStyle: TextDecorationStyle.dotted,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () async {
                                    _detailApi.openPlayerDetail(context, data["byUserId"]);
                                  },
                              ),
                              TextSpan(
                                text: FlutterI18n.translate(context, "detail.info.report"),
                                style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              TextSpan(
                                text: data["toOriginName"],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: FlutterI18n.translate(context, "detail.info.inGame"),
                                style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              TextSpan(
                                text: FlutterI18n.translate(context, "basic.games.${data['cheatGame']}"),
                              ),
                              TextSpan(
                                text: FlutterI18n.translate(context, "detail.info.gaming"),
                                style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                ),
                              )
                            ],
                          ),
                        ),

                        Wrap(
                          spacing: 3,
                          runSpacing: 3,
                          children: data["cheatMethods"].map<Widget>((i) {
                            return EluiTagComponent(
                              color: EluiTagType.none,
                              round: true,
                              size: EluiTagSize.no2,
                              theme: EluiTagTheme(
                                backgroundColor: Theme.of(context).textTheme.subtitle2!.color!.withOpacity(.2),
                                textColor: Theme.of(context).textTheme.subtitle1!.color!,
                              ),
                              value: i,
                            );
                          }).toList(),
                        )
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
          ),
          flex: 1,
        ),
      ],
      headerSecondary: Offstage(
        offstage: data["videoLink"] == "",
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          child: Card(
            borderOnForeground: true,
            elevation: 20,
            color: Theme.of(context).appBarTheme.backgroundColor,
            shadowColor: Colors.black26,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  I18nText("detail.info.videoLink",
                      child: const Text("",
                          style: TextStyle(
                            fontSize: 12,
                          ))),
                  Container(
                    margin: const EdgeInsets.only(left: 8, right: 10),
                    width: 1,
                    height: 20,
                    color: Colors.black12,
                    constraints: const BoxConstraints(
                      minHeight: 20,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      data["videoLink"],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    child: const Icon(
                      Icons.link,
                      color: Colors.blueAccent,
                    ),
                    onTap: () => _urlUtil.onPeUrl(data["videoLink"].toString()),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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

/// 裁判
class JudgementCard extends StatelessWidget {
  // 单条数据
  late Map data;

  // 位置
  late int index = 0;

  final CardUtil _detailApi = CardUtil();

  JudgementCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TimeLineCard(
      header: [
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
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      children: <TextSpan>[
                        TextSpan(
                            text: data["username"],
                            style: const TextStyle(
                              decoration: TextDecoration.underline,
                              decorationStyle: TextDecorationStyle.dotted,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                _detailApi.openPlayerDetail(context, data["byUserId"]);
                              }),
                        const TextSpan(
                          text: "认为",
                          style: TextStyle(
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
      headerSecondary: Card(
        margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        color: Theme.of(context).appBarTheme.backgroundColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Wrap(
                  runAlignment: WrapAlignment.center,
                  spacing: 5,
                  children: <Widget>[
                    // 名称
                    Text(
                      data["username"],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Offstage(
                offstage: data["toFloor"] == null,
                child: Text(
                  "#${data["toFloor"]} ",
                  style: const TextStyle(
                    color: Colors.black26,
                  ),
                ),
              ),
              const Icon(
                Icons.vertical_align_top,
                color: Colors.black26,
                size: 15,
              )
            ],
          ),
        ),
      ),
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

/// 申诉
class AppealCard extends StatelessWidget {
  // 单条数据
  late Map data;

  // 位置
  late int index = 0;

  final Function onReplySucceed;

  AppealCard({
    Key? key,
    required this.onReplySucceed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
