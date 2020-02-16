import 'package:flutter/material.dart';
//import 'package:flutter_html_view/flutter_html_view.dart';

import 'package:bfban/utils/index.dart';

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
                  detailCheatersCard(
                    value: "第一次举报时间",
                    cont: cheatersInfoUser != null
                        ? cheatersInfoUser["createDatetime"]
                        : "",
                  ),
                  detailCheatersCard(
                    value: "最后更新",
                    cont: cheatersInfoUser != null
                        ? cheatersInfoUser["updateDatetime"]
                        : "",
                  ),
                  detailCheatersCard(
                    value: "被举报游戏",
                    cont: cheatersInfo["data"] != null
                        ? cheatersInfo["data"]["games"][0]["game"]
                        : "",
                    onTap: () {},
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 100),
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "时间线",
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
        return "【管理员】";
        break;
      case "normal":
        return "【玩家】";
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
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      color: Colors.white30,
                      padding: EdgeInsets.only(left: 20),
                      child: Text("${getUsetIdentity(i["privilege"])}",
                          style: style),
                    ),
                    Text("${i["username"]}举报 ${cheatersInfoUser["originId"]}:",
                        style: style),
                  ],
                ),
                Container(
                  color: Colors.white30,
                  margin: EdgeInsets.only(bottom: 20),
                  padding: EdgeInsets.all(20),
//                  child: HtmlView(
//                    scrollable: false,
//                    data: i["description"],
//                  ),
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

class detailCheatersCard extends StatelessWidget {
  final value;
  final cont;
  final type;
  final onTap;

  detailCheatersCard({
    this.value,
    this.cont,
    this.type = '0',
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
                      fontSize: 20,
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
