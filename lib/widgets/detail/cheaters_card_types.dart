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
import 'package:flutter_translate/flutter_translate.dart';

/// 卡片内置公共
class CardFun {
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
          onTap: () => _urlUtil.onPeUrl(context.tree.element!.attributes["href"].toString()),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
            decoration: const BoxDecoration(
              color: Color(0xfff2f2f2),
              borderRadius: BorderRadius.all(Radius.circular(2)),
            ),
            child: Wrap(
              spacing: 5,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Icon(
                  Icons.insert_link,
                  color: Colors.blue,
                ),
                context.parser,
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
      "*": Style(fontSize: const FontSize(12), color: Theme.of(context).textTheme.subtitle1!.color),
    };
  }

  /// [Event]
  /// 楼层
  Widget getFloor(int index) {
    return Container(
      margin: const EdgeInsets.only(
        right: 5,
      ),
      child: Text("#$index楼 "),
    );
  }

  /// [Event]
  /// 查看用户ID信息
  void openPlayerDetail(context, id) {
    _urlUtil.opEnPage(
      context,
      '/detail/user/$id',
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
      children: getPrivilege(privileges).map((e) {
        return EluiTagComponent(
          size: EluiTagSize.no2,
          color: EluiTagType.none,
          theme: EluiTagTheme(
            textColor: e["textColor"],
            backgroundColor: e["backgroundColor"],
          ),
          value: e["name"],
        );
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

  CardFun cardFun = CardFun();

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
            cardFun._setReply(context, type: 1, floor: floor, toPlayerId: data!["id"], toCommentId: data!["id"]);
            break;
        }
      },
      itemBuilder: (context) {
        return const [
          PopupMenuItem(
            value: 1,
            height: 40,
            child: Text("回复"),
          ),
          // PopupMenuItem(
          //   value: 2,
          //   height: 40,
          //   child: Text("删除"),
          // ),
        ];
      },
    );
  }
}

/// 日历卡片
/// 基本都基于该模板
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
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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

/// 作弊回复中的普通用户回复
/// 类型是0
class CheatUserCheatersCard extends StatelessWidget {
  // 单条数据
  late Map data;

  // 位置
  late int index = 0;

  final Function onReplySucceed;

  final CardFun _detailApi = CardFun();

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
                  // 楼层
                  _detailApi.getFloor(index),

                  // 类型
                  Text.rich(
                    TextSpan(
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
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
                        const TextSpan(
                          text: "回复",
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
                "发布时间: ${Date().getTimestampTransferCharacter(data['createTime'])["Y_D_M"]}",
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
                    // 身份
                    _detailApi.getPrivilegeWidget(data["privilege"]),

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
                  "#${data["toFloor"]}楼 ",
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

/// 举报卡片
/// 类型是1
class CheatReportsCard extends StatelessWidget {
  // 单条数据
  late dynamic data;

  // 位置
  late int? index;

  final UrlUtil _urlUtil = UrlUtil();

  final CardFun _detailApi = CardFun();

  final Function onReplySucceed;

  CheatReportsCard({
    Key? key,
    required this.onReplySucceed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 卡片标题
          Container(
            margin: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
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
                          // 楼层
                          _detailApi.getFloor(index!),

                          // 类型
                          _detailApi.getPrivilegeWidget(data["privilege"]),

                          // 标题
                          Text.rich(
                            TextSpan(
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
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
                                    },
                                ),
                                const TextSpan(
                                  text: "举报",
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                TextSpan(
                                  text: data["toOriginName"],
                                ),
                                const TextSpan(
                                  text: "在",
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                TextSpan(
                                  text: translate("cheatMethods." + data['cheatGame'] + ".title"),
                                ),
                                const TextSpan(
                                  text: " 作弊",
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
                        "发布时间: ${Date().getTimestampTransferCharacter(data['createTime'])["Y_D_M"]}",
                        style: TextStyle(
                          color: Theme.of(context).textTheme.subtitle2!.color,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "举报行为: ",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).textTheme.subtitle2!.color,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Wrap(
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
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ReplyButtonWidget(data: data)..floor = index,
              ],
            ),
          ),

          /// S 评论视频
          Offstage(
            offstage: data["videoLink"] == "",
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: Card(
                borderOnForeground: true,
                elevation: 20,
                color: Theme.of(context).appBarTheme.backgroundColor,
                shadowColor: Colors.black26,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        "附加",
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
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

          /// E 评论视频

          /// Html评论内容
          Offstage(
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
        ],
      ),
    );
  }
}

/// 管理员 or 超级管理的裁判卡片
class JudgementCard extends StatelessWidget {
  // 单条数据
  late Map data;

  // 位置
  late int index = 0;

  final CardFun _detailApi = CardFun();

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
                  // 楼层
                  _detailApi.getFloor(index),

                  // 类型
                  Text.rich(
                    TextSpan(
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
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
                "发布时间: ${Date().getTimestampTransferCharacter(data['createTime'])["Y_D_M"]}",
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
                    // 身份
                    _detailApi.getPrivilegeWidget(data["privilege"]),

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
                  "#${data["toFloor"]}楼 ",
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
