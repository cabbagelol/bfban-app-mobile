import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:bfban/utils/index.dart';
import 'package:flutter_html/style.dart';

class cheatersPage extends StatefulWidget {
  final id;

  cheatersPage({this.id = ""});

  @override
  _cheatersPageState createState() => _cheatersPageState();
}

class _cheatersPageState extends State<cheatersPage> {
  Map cheatersInfo = Map();
  Map cheatersInfoUser = Map();
  Future futureBuilder;

  @override
  void initState() {
    super.initState();
    this._getCheatersInfo();

    futureBuilder = this._getCheatersInfo();
  }

  /// 获取房源相册
  Future _getCheatersInfo() async {
    var result =
        await Http.request('api/cheaters/${widget.id}', method: Http.GET);

    if (result.data != null && result.data["error"] == 0) {
      setState(() {
        cheatersInfo = result.data ?? new Map();
        cheatersInfoUser = result.data["data"]["cheater"][0];
      });

      return cheatersInfo;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: this.futureBuilder,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          print(snapshot.data);

          if (snapshot.connectionState != ConnectionState.done) {
            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/bk-companion.jpg'),
                  fit: BoxFit.fitHeight,
                ),
              ),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: true,
                  title: Text(
                    "加载中",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          }

          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bk-companion.jpg'),
                fit: BoxFit.fitHeight,
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                title: cheatersInfoUser != null
                    ? Text(cheatersInfoUser["originId"].toString(),
                        style: TextStyle(color: Colors.white))
                    : Container(),
              ),
              body: ListView(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(30),
                    child: Column(
                      children: <Widget>[
                        cheatersInfoUser != null
                            ? Container(
                                margin: EdgeInsets.only(bottom: 10),
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        cheatersInfoUser["avatarLink"] ?? ""),
                                    fit: BoxFit.fitHeight,
                                  ),
                                ),
                              )
                            : Container(
                                margin: EdgeInsets.only(bottom: 10),
                                height: 100,
                                width: 100,
                                color: Colors.white,
                              )
                      ],
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.only(top: 20),
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "信息",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  /// S 信息方块
                  Container(
                    color: Colors.black12,
                    padding: EdgeInsets.only(
                      top: 10,
                      bottom: 10,
                      left: 20,
                      right: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                          child: Column(
                            children: <Widget>[
                              Text(
                                cheatersInfoUser != null
                                    ? cheatersInfoUser["createDatetime"]
                                    : "",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                "第一次举报时间",
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          child: Column(
                            children: <Widget>[
                              Text(
                                cheatersInfoUser != null
                                    ? cheatersInfoUser["updateDatetime"]
                                    : "",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                "最后更新",
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.black12,
                    padding: EdgeInsets.only(
                      top: 10,
                      bottom: 10,
                      left: 20,
                      right: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                          child: Column(
                            children: <Widget>[
                              Text(
                                cheatersInfo["data"] != null
                                    ? cheatersInfo["data"]["games"][0]["game"]
                                    : "",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                "被举报游戏",
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          child: Column(
                            children: <Widget>[
                              Text(
                                cheatersInfoUser != null
                                    ? cheatersInfo["data"]["cheater"][0]["n"].toString() + "/次"
                                    : "",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                "围观",
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          child: Column(
                            children: <Widget>[
                              Text(
                                (cheatersInfo["data"]["reports"].length + cheatersInfo["data"]["verifies"].length).toString() + "/条",
                                //cheatersInfo["data"]["verifies"]
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                "回复",
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  /// E 信息方块

                  Container(
                    margin: EdgeInsets.only(top: 10),
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "管理记录",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: <Widget>[

                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "玩家举报记录",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  _gelPL(snapshot.data, cheatersInfoUser),
                ],
              ),
            ),
          );
        });
  }

  static getUsetIdentity(type) {
    switch (type) {
      case "admin":
        return "管理员";
        break;
      case "normal":
        return "玩家";
        break;
    }
  }

  static _gelPL(cheatersInfo, cheatersInfoUser) {
    var style = TextStyle(
        color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500);
    List<Widget> list = [];

    cheatersInfo["data"]["reports"].forEach(
      (i) {
        list.add(
          Container(
            color: Colors.white,
            child: Column(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      decoration: new BoxDecoration(
                        color: Colors.amber,
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
                        "${getUsetIdentity(i["privilege"])}",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "${i["username"]}举报 ${cheatersInfoUser["originId"]}:",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "行为: ${i['cheatMethods']}",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "发布时间: ${i['createDatetime']}",
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
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(20),
                  child: Html(
                    data: i["description"],
                    style: {
                      "img": Style(
                        border: Border.all(
                          width: 1.0,
                          color: Colors.black12,
                        ),
                      ),
                    },
                    onImageTap: (src) {
                      // Display the image in large form.
                    },
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
    return Column(
      children: list,
    );
  }
}

/// WG九宫格
class detailCellCard extends StatelessWidget {
  final text;
  final value;

  detailCellCard({
    this.text = "",
    this.value = "",
  });

  @override
  Widget build(BuildContext context) {
    throw Column(
      children: <Widget>[
        Text(
          text ?? "",
          style: TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        )
      ],
    );
  }
}

/// WG单元格
class detailCheatersCard extends StatelessWidget {
  final value;
  final cont;
  final type;
  final onTap;
  final fontSize;

  detailCheatersCard({
    this.value,
    this.cont,
    this.type = '0',
    this.fontSize,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        color: type == '0'
            ? Color.fromRGBO(0, 0, 0, .3)
            : Color.fromRGBO(255, 255, 255, .07),
        padding: EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    value,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize ?? 20,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  '${cont}',
                  style: TextStyle(
                    color: Color.fromRGBO(255, 255, 255, .6),
                    fontSize: 13,
                  ),
                )
              ],
            )
          ],
        ),
      ),
      onTap: onTap != null ? onTap : null,
    );
  }
}
