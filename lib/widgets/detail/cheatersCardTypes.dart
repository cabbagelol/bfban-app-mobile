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
  static Map<String, Style> styleHtml(BuildContext context) {
    /// 3/1
    num a = (MediaQuery.of(context).size.width - 15) / 3;

    /// 3/1 -10
    num b = a - 5;
    return {
      "a": Style(
        after: "🔗",
      ),
      "p": Style(
        fontSize: FontSize(12),
        width: (MediaQuery.of(context).size.width - 15),
      ),
      "img": Style(
//        alignment: Alignment.centerLeft,
//        width: b,
//        height: a,
        border: Border.all(
          width: 1,
          color: Color(0xfff2f2f2),
        ),
        backgroundColor: Color(0xfff2f2f2),
      ),
    };
  }

  /// 楼层
  static Widget getFloor(int index) {
    return Container(
      margin: EdgeInsets.only(
        left: 10,
        right: 5,
      ),
      child: Text(
        "#${index}楼 ",
        style: TextStyle(
          color: Colors.black26,
        ),
      ),
    );
  }

  /// 查看用户ID信息
  static void onSeeUserInfo(context, uid) {
    Routes.router.navigateTo(
      context,
      '/record/$uid',
      transition: TransitionType.cupertino,
    );
  }

  /// 查看图片
  static void onImageTap(BuildContext context, String img) {
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

  final int index;

  final cheatMethods;

  final cheatersInfoUser;

  final cheatersInfo;

  final UrlUtil _urlUtil = new UrlUtil();

  CheatUserCheaters({
    @required this.i,
    this.index = 0,
    this.cheatMethods,
    this.cheatersInfoUser,
    this.cheatersInfo,
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              detailApi.getFloor(index),
              Container(
                decoration: new BoxDecoration(
                  color: detailApi.getUsetIdentity(i["fooPrivilege"])[2],
                  borderRadius: BorderRadius.all(
                    Radius.circular(15.0),
                  ),
                ),
                margin: EdgeInsets.only(
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
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text.rich(
                      TextSpan(
                        style: new TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                              text: i["foo"],
                              style: new TextStyle(
                                decoration: TextDecoration.underline,
                                decorationStyle: TextDecorationStyle.dotted,
                                decorationColor: Colors.black,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  detailApi.onSeeUserInfo(context, i["fooUId"]);
                                }),
                          TextSpan(
                            text: " 回复",
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "发布时间: ${new Date().getTimestampTransferCharacter(i['createDatetime'])["Y_D_M"]}",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              replyButton(
                onTap: () {
                  Routes.router.navigateTo(
                    context,
                    '/reply/${jsonEncode({
                      "type": 1,
                      "id": cheatersInfoUser["id"],
                      "originUserId": cheatersInfoUser["originUserId"],
                      "userId": cheatersInfo["data"]["reports"][0]["userId"],
                      "toUserId": i["userId"],
                      "foo": i["foo"],
                      "toFloor": index.toString(),
                      // ignore: equal_keys_in_map
                      "toUserId": i["userId"],
                    })}',
                    transition: TransitionType.cupertino,
                  );
                },
              ),
            ],
          ),

          i["toFloor"] == null
              ? Container()
              : Container(
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.only(
                    top: 5,
                    left: 10,
                    bottom: 5,
                    right: 10,
                  ),
                  color: Color(0xfff2f2f2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Wrap(
                          spacing: 5,
                          children: <Widget>[
                            Container(
                              decoration: new BoxDecoration(
                                color: detailApi.getUsetIdentity(i["fooPrivilege"])[2],
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15.0),
                                ),
                              ),
                              padding: EdgeInsets.only(
                                left: 5,
                                right: 5,
                                top: 1,
                                bottom: 1,
                              ),
                              child: Text(
                                "${detailApi.getUsetIdentity(i["fooPrivilege"])[0]}",
                                style: TextStyle(
                                  color: detailApi.getUsetIdentity(i["fooPrivilege"])[1],
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              i["bar"],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Offstage(
                        offstage: i["toFloor"] == null,
                        child: Text(
                          "#${i["toFloor"]}楼 ",
                          style: TextStyle(
                            color: Colors.black26,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.vertical_align_top,
                        color: Colors.black26,
                        size: 15,
                      )
                    ],
                  ),
                ),

          /// Html评论内容
          Container(
            color: Colors.white,
            child: Html(
              data: i["content"],
              style: detailApi.styleHtml(context),
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

  final int index;

  final cheatMethods;

  final cheatersInfoUser;

  final cheatersInfo;

  final UrlUtil _urlUtil = new UrlUtil();

  CheatReports({
    @required this.i,
    this.index = 0,
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              detailApi.getFloor(index),
              Container(
                decoration: new BoxDecoration(
                  color: detailApi.getUsetIdentity(i["privilege"])[2],
                  borderRadius: BorderRadius.all(
                    Radius.circular(15.0),
                  ),
                ),
                margin: EdgeInsets.only(
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                              text: i["username"],
                              style: new TextStyle(
                                decoration: TextDecoration.underline,
                                decorationStyle: TextDecorationStyle.dotted,
                                decorationColor: Colors.black,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  detailApi.onSeeUserInfo(context, i["uId"]);
                                }),
                          TextSpan(
                            text: " 举报在 ",
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          TextSpan(
                            text: i["game"],
                          ),
                          TextSpan(
                            text: " 作弊",
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "发布时间: ${new Date().getTimestampTransferCharacter(i['createDatetime'])["Y_D_M"]}",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          "举报行为: ",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 9,
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
                  Routes.router.navigateTo(
                    context,
                    '/reply/${jsonEncode({
                      "type": 1,
                      "id": cheatersInfoUser["id"],
                      "originUserId": cheatersInfoUser["originUserId"],
                      "userId": cheatersInfo["data"]["reports"][0]["userId"],
                      "toUserId": i["userId"],
                      "foo": i["username"],
                      "toFloor": index.toString(),
                      // ignore: equal_keys_in_map
                      "toUserId": i["userId"],
                    })}',
                    transition: TransitionType.cupertino,
                  );
                },
              ),
            ],
          ),

          /// S 评论视频
          Offstage(
            offstage: i["bilibiliLink"] == "",
            child: Container(
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
                  style: BorderStyle.none,
                  color: Colors.blue,
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "附加",
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 8, right: 10),
                    width: 1,
                    height: 20,
                    color: Colors.black12,
                    constraints: BoxConstraints(
                      minHeight: 20,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      i["bilibiliLink"],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
          ),

          /// E 评论视频

          /// Html评论内容
          Container(
            color: Colors.white,
            child: Html(
              data: i["description"],
              style: detailApi.styleHtml(context),
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
class CheatVerifies extends StatefulWidget {
  final i;

  final int index;

  final cheatMethods;

  final cheatersInfoUser;

  final cheatersInfo;

  Map login;

  Function onConfirm;

  CheatVerifies({
    @required this.i,
    this.index = 0,
    @required this.cheatMethods,
    @required this.cheatersInfoUser,
    @required this.cheatersInfo,
    @required this.login,
    this.onConfirm,
  });

  @override
  _CheatVerifiesState createState() => _CheatVerifiesState();
}

class _CheatVerifiesState extends State<CheatVerifies> {
  final List<dynamic> startusIng = Config.startusIng;

  final UrlUtil _urlUtil = new UrlUtil();

  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();

    this._onisAdmin();
  }

  /// 判断是否另一个管理员，
  /// 如果是显示赞同按钮
  void _onisAdmin() async {
    var login = widget.login;

    bool _is = false;

    setState(() {
      if (widget.i == null || login == null) {
        _isAdmin = true;
      }

      /// status 1： 作弊者
      if (login["userPrivilege"] == "admin" && login["userId"] != widget.i["userId"] && widget.i["status"] == "1") {
        _isAdmin = false;
      } else {
        _isAdmin = true;
      }

      /// 索引同意列表是否已有该决议
      if (widget.cheatersInfo["data"]["confirms"].length > 0) {
        widget.cheatersInfo["data"]["confirms"].forEach((i) {
          if (i["userVerifyCheaterId"] == widget.i["id"]) {
            _is = true;
          }
        });

        if (_is) {
          _isAdmin = true;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Color(0xfffff6dd),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              detailApi.getFloor(widget.index),
              Container(
                decoration: new BoxDecoration(
                  color: detailApi.getUsetIdentity(widget.i["privilege"])[2],
                  borderRadius: BorderRadius.all(
                    Radius.circular(15.0),
                  ),
                ),
                margin: EdgeInsets.only(
                  right: 10,
                ),
                padding: EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 1,
                  bottom: 1,
                ),
                child: Text(
                  "${detailApi.getUsetIdentity(widget.i["privilege"])[0]}",
                  style: TextStyle(
                    color: detailApi.getUsetIdentity(widget.i["privilege"])[1],
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                              text: widget.i["username"],
                              style: new TextStyle(
                                decoration: TextDecoration.underline,
                                decorationStyle: TextDecorationStyle.dotted,
                                decorationColor: Colors.black,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  detailApi.onSeeUserInfo(context, widget.i["uId"]);
                                }),
                          TextSpan(
                            text: " 认为 ",
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          TextSpan(
                            text: startusIng[int.parse(widget.i["status"])]["s"],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "发布时间: ${new Date().getTimestampTransferCharacter(widget.i['createDatetime'])["Y_D_M"]}",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    (widget.i["status"] == "1")
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "举报行为: ",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Wrap(
                                  spacing: 2,
                                  runSpacing: 2,
                                  children: widget.cheatMethods,
                                ),
                              ),
                            ],
                          )
                        : SizedBox(),
                  ],
                ),
              ),
              replyButton(
                onTap: () {
                  Routes.router.navigateTo(
                    context,
                    '/reply/${jsonEncode({
                      "type": 1,
                      "id": widget.cheatersInfoUser["id"],
                      "originUserId": widget.cheatersInfoUser["originUserId"],
                      "userId": widget.cheatersInfo["data"]["reports"][0]["userId"],
                      "toUserId": widget.i["userId"],
                      "foo": widget.i["username"],
                      "toFloor": widget.index.toString(),
                      // ignore: equal_keys_in_map
                      "toUserId": widget.i["userId"],
                    })}',
                    transition: TransitionType.cupertino,
                  );
                },
              ),
            ],
          ),

          /// Html评论内容
          Container(
            child: Html(
              data: widget.i["suggestion"],
              style: detailApi.styleHtml(context),
              onLinkTap: (src) => _urlUtil.onPeUrl(src),
              onImageTap: (img) => detailApi.onImageTap(context, img),
            ),
          ),

          /// 管理赞同
          Offstage(
            offstage: _isAdmin,
            child: Container(
              padding: EdgeInsets.only(
                left: 20,
              ),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    width: 1,
                    color: Color(0xfff2f2f2),
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "管理员选项:",
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 12,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      right: 20,
                    ),
                    color: Colors.green,
                    child: EluiButtonComponent(
                      child: Text(
                        "赞同该决议",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      onTap: () => widget.onConfirm(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 赞同。审核员
/// 类型是3
class CheatConfirms extends StatelessWidget {
  final i;

  final int index;

  final cheatMethods;

  final cheatersInfoUser;

  final cheatersInfo;

  final UrlUtil _urlUtil = new UrlUtil();

  CheatConfirms({
    @required this.i,
    this.index = 0,
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
        color: Color(0xfffff6dd),
        border: Border(
          bottom: BorderSide(
            width: 10,
            color: Color(0xfff2f2f2),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              detailApi.getFloor(index),
              Container(
                decoration: new BoxDecoration(
                  color: detailApi.getUsetIdentity(i["privilege"])[2],
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                ),
                margin: EdgeInsets.only(
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: i["username"],
                            style: new TextStyle(
                              decoration: TextDecoration.underline,
                              decorationStyle: TextDecorationStyle.dotted,
                              decorationColor: Colors.black,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                detailApi.onSeeUserInfo(context, i["uId"]);
                              },
                          ),
                          TextSpan(
                            text: "同意该决定",
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
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
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
              ),
              replyButton(
                onTap: () {
                  Routes.router.navigateTo(
                    context,
                    '/reply/${jsonEncode({
                      "type": 1,
                      "id": cheatersInfoUser["id"],
                      "originUserId": cheatersInfoUser["originUserId"],
                      "userId": cheatersInfo["data"]["reports"][0]["userId"],
                      "toUserId": i["userId"],
                      "foo": i["foo"],
                      "toFloor": index.toString(),
                      // ignore: equal_keys_in_map
                      "toUserId": i["userId"],
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
            child: Html(
              data: (i["suggestion"] ?? ""),
              style: detailApi.styleHtml(context),
              onLinkTap: (src) => _urlUtil.onPeUrl(src),
              onImageTap: (img) => detailApi.onImageTap(context, img),
            ),
          ),
        ],
      ),
    );
  }
}
