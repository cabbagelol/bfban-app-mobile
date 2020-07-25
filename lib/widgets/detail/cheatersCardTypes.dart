/// 评论类型
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:fluro/fluro.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:flutter_plugin_elui/elui.dart';

import 'package:bfban/constants/api.dart';
import 'package:bfban/utils/index.dart';
import 'package:bfban/widgets/index.dart';
import 'package:bfban/router/router.dart';

/// 对比评论身份
class detailApi {
  /// 查看图片
  static void onImageTap(context, String img) {
    Navigator.of(context).push(CupertinoPageRoute(
      builder: (BuildContext context) {
        return PhotoViewSimpleScreen(
          imageProvider: NetworkImage(img),
          heroTag: 'simple',
        );
      },
    ));
  }

  /// 状态
  static getUsetIdentity(type) {
    switch (type) {
      case "admin":
        return ["管理员", Colors.white, Colors.redAccent];
        break;
      case "normal":
        return ["玩家", Colors.black, Colors.amber];
        break;
      case "super":
        return ["超管", Colors.white, Colors.blueAccent];
        break;
      default:
        return ["未知", Colors.black, Colors.white12];
    }
  }
}

/// 统一回复按钮
class replyButton extends StatelessWidget {
  final onTap;

  replyButton({
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.only(
          right: 10,
        ),
        child: Text(
          "回复",
          style: TextStyle(
            color: Colors.blueAccent,
            fontSize: 14,
          ),
        ),
      ),
      onTap: () async {
        final _login = await Storage.get('com.bfban.login');

        if (_login == null) {
          EluiMessageComponent.error(context)(
            child: Text("请先登录BFBAN"),
          );
          return;
        }

        this.onTap();
      },
    );
  }
}

/// 作弊回复中的普通用户回复
/// 类型是0
class CheatUserCheaters extends StatelessWidget {
  final Map i;

  final UrlUtil _urlUtil = new UrlUtil();

  CheatUserCheaters({
    @required this.i,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            width: 10,
            color: Color(0xfff2f2f2),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                decoration: new BoxDecoration(
                  color: detailApi.getUsetIdentity(i["fooPrivilege"])[2],
                  borderRadius: BorderRadius.all(
                    Radius.circular(15.0),
                  ),
                ),
                margin: EdgeInsets.only(
                  left: 20,
                  top: 5,
                  bottom: 5,
                  right: 10,
                ),
                padding: EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 1,
                  bottom: 1,
                ),
                child: Text(
                  "${detailApi.getUsetIdentity(i["fooPrivilege"])[0]}",
                  style: TextStyle(
                    color: detailApi.getUsetIdentity(i["fooPrivilege"])[1],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "${i["foo"]} 回复",
                    //${cheatersInfoUser["originId"]}
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "发布时间: ${new Date().getTimestampTransferCharacter(i['createDatetime'])["Y_D_M"]}",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ],
              ),
            ],
          ),

          /// Html评论内容
          Container(
            color: Colors.white,
            child: Html(
              data: i["content"],
              onLinkTap: (src) => _urlUtil.onPeUrl(src),
              onImageTap: (img) => detailApi.onImageTap(context, img),
            ),
          )
        ],
      ),
    );
  }
}

/// 举报
/// 类型是1
class CheatReports extends StatelessWidget {
  final Map i;

  final cheatMethods;

  final cheatersInfoUser;

  final cheatersInfo;

  final UrlUtil _urlUtil = new UrlUtil();

  CheatReports({
    this.i,
    this.cheatMethods,
    this.cheatersInfoUser,
    this.cheatersInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            width: 10,
            color: Color(0xfff2f2f2),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                decoration: new BoxDecoration(
                  color: detailApi.getUsetIdentity(i["privilege"])[2],
                  borderRadius: BorderRadius.all(
                    Radius.circular(15.0),
                  ),
                ),
                margin: EdgeInsets.only(
                  left: 20,
                  top: 5,
                  bottom: 5,
                  right: 10,
                ),
                padding: EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 1,
                  bottom: 1,
                ),
                child: Text(
                  "${detailApi.getUsetIdentity(i["privilege"])[0]}",
                  style: TextStyle(
                    color: detailApi.getUsetIdentity(i["privilege"])[1],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text.rich(
                      TextSpan(
                        style: new TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                              text: i["username"],
                              style: new TextStyle(
                                decoration: TextDecoration.underline,
                                decorationStyle: TextDecorationStyle.dashed,
                                decorationColor: Colors.blue,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  Routes.router.navigateTo(
                                    context,
                                    '/record/${i["uId"]}',
                                    transition: TransitionType.cupertino,
                                  );
                                }),
                          TextSpan(
                            text: "举报在",
                          ),
                          TextSpan(
                            text: i["game"],
                          ),
                          TextSpan(
                            text: "作弊",
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "发布时间: ${new Date().getTimestampTransferCharacter(i['createDatetime'])["Y_D_M"]}",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          "举报行为: ",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Wrap(
                          spacing: 2,
                          runSpacing: 2,
                          children: cheatMethods,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              replyButton(
                onTap: () {
                  /// 帖子回复
                  Routes.router.navigateTo(
                    context,
                    '/reply/${jsonEncode({
                      "type": 1,
                      "id": cheatersInfoUser["id"],
                      "originUserId": cheatersInfoUser["originUserId"],
                      "userId": cheatersInfo["data"]["reports"][0]["userId"],
                      "toUserId": i["userId"],
                      "foo": i["username"],

                      /// 取第一条举报信息下的userId
                    })}',
                    transition: TransitionType.cupertino,
                  );
                },
              ),
            ],
          ),

          /// S 评论视频
          Container(
            margin: EdgeInsets.only(
              top: 5,
              left: 10,
              right: 10,
            ),
            padding: EdgeInsets.only(
              left: 10,
              right: 10,
              top: 4,
              bottom: 4,
            ),
            decoration: BoxDecoration(
              color: Color(0xfff2f2f2),
              border: Border.all(
                color: Colors.black12,
                width: 1,
              ),
            ),
            child: Row(
              children: <Widget>[
                Text(
                  "附加 ",
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    i["bilibiliLink"] == "" ? "暂无视频" : i["bilibiliLink"],
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ),
                GestureDetector(
                  child: Icon(
                    Icons.link,
                    color: Colors.blueAccent,
                  ),
                  onTap: () => _urlUtil.onPeUrl(i["bilibiliLink"].toString()),
                ),
              ],
            ),
          ),

          /// E 评论视频

          /// Html评论内容
          Container(
            color: Colors.white,
            child: Html(
              data: i["description"],
              style: {
                "img": Style(
                  alignment: Alignment.centerLeft,
                  width: (MediaQuery.of(context).size.width - 15),
                  border: Border.all(
                    width: 1.0,
                    color: Colors.black12,
                  ),
                ),
              },
              onLinkTap: (src) => _urlUtil.onPeUrl(src),
              onImageTap: (img) => detailApi.onImageTap(context, img),
            ),
          )
        ],
      ),
    );
  }
}

/// 管理员判决列表
/// 类型是2
class CheatVerifies extends StatelessWidget {
  final i;

  final cheatMethods;

  final cheatersInfoUser;

  final cheatersInfo;

  final List<dynamic> startusIng = Config.startusIng;

  final UrlUtil _urlUtil = new UrlUtil();

  CheatVerifies({
    this.i,
    this.cheatMethods,
    this.cheatersInfoUser,
    this.cheatersInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            width: 10,
            color: Color(0xfff2f2f2),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                decoration: new BoxDecoration(
                  color: detailApi.getUsetIdentity(i["privilege"])[2],
                  borderRadius: BorderRadius.all(
                    Radius.circular(15.0),
                  ),
                ),
                margin: EdgeInsets.only(
                  left: 20,
                  top: 5,
                  bottom: 5,
                  right: 10,
                ),
                padding: EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 1,
                  bottom: 1,
                ),
                child: Text(
                  "${detailApi.getUsetIdentity(i["privilege"])[0]}",
                  style: TextStyle(
                    color: detailApi.getUsetIdentity(i["privilege"])[1],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "${i["username"]} 认为 ${startusIng[int.parse(i["status"])]["s"]}",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "发布时间: ${new Date().getTimestampTransferCharacter(i['createDatetime'])["Y_D_M"]}",
                      style: TextStyle(
                        color: Colors.black54,
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
                            color: Colors.black54,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Wrap(
                            spacing: 2,
                            runSpacing: 2,
                            children: cheatMethods,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              replyButton(
                onTap: () {
                  /// 帖子回复
                  Routes.router.navigateTo(
                    context,
                    '/reply/${jsonEncode({
                      "type": 1,
                      "id": cheatersInfoUser["id"],
                      "originUserId": cheatersInfoUser["originUserId"],
                      "userId": cheatersInfo["data"]["reports"][0]["userId"],
                      "toUserId": i["userId"],
                      "foo": i["foo"],

                      /// 取第一条举报信息下的userId
                    })}',
                    transition: TransitionType.cupertino,
                  );
                },
              ),
            ],
          ),

          /// Html评论内容
          Container(
            color: Colors.white,
            child: Html(
              data: i["suggestion"],
              onLinkTap: (src) => _urlUtil.onPeUrl(src),
              onImageTap: (img) => detailApi.onImageTap(context, img),
            ),
          )
        ],
      ),
    );
  }
}

/// 赞同。审核员
/// 类型是3
class CheatConfirms extends StatelessWidget {
  final i;

  final cheatMethods;

  final cheatersInfoUser;

  final cheatersInfo;

  final UrlUtil _urlUtil = new UrlUtil();

  CheatConfirms({
    this.i,
    this.cheatMethods,
    this.cheatersInfoUser,
    this.cheatersInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 10,
        bottom: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            width: 10,
            color: Color(0xfff2f2f2),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                decoration: new BoxDecoration(
                  color: detailApi.getUsetIdentity(i["privilege"])[2],
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                ),
                margin: EdgeInsets.only(
                  left: 20,
                  top: 5,
                  bottom: 5,
                  right: 10,
                ),
                padding: EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 1,
                  bottom: 1,
                ),
                child: Text(
                  "${detailApi.getUsetIdentity(i["privilege"])[0]}",
                  style: TextStyle(
                    color: detailApi.getUsetIdentity(i["privilege"])[1],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "${i["username"]} 同意该决定",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Wrap(
                      spacing: 2,
                      children: cheatMethods,
                    ),
                    Text(
                      "发布时间: ${new Date().getTimestampTransferCharacter(i['createDatetime'])["Y_D_M"]}",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
              ),
              replyButton(
                onTap: () {
                  /// 帖子回复
                  Routes.router.navigateTo(
                    context,
                    '/reply/${jsonEncode({
                      "type": 1,
                      "id": cheatersInfoUser["id"],
                      "originUserId": cheatersInfoUser["originUserId"],
                      "userId": cheatersInfo["data"]["reports"][0]["userId"],
                      "toUserId": i["userId"],
                      "foo": i["foo"],

                      /// 取第一条举报信息下的userId
                    })}',
                    transition: TransitionType.cupertino,
                  );
                },
              ),
            ],
          ),

          /// Html评论内容
          Container(
            margin: EdgeInsets.only(
              top: 2,
            ),
            color: Colors.white,
            child: Row(
              children: <Widget>[
                Padding(
                  child: Text(
                    "\“",
                    style: TextStyle(
                      fontSize: 40,
                      color: Colors.black12,
                    ),
                  ),
                  padding: EdgeInsets.only(left: 20),
                ),
                Expanded(
                  flex: 1,
                  child: Html(
                    data: (i["suggestion"] ?? ""), //  startusIng[int.parse(i["status"])]["t"] + ";" +
                    onLinkTap: (src) => _urlUtil.onPeUrl(src),
                    onImageTap: (img) => detailApi.onImageTap(context, img),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
