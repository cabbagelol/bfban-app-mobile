import 'package:flutter/cupertino.dart';

/// 社区

import 'package:flutter/material.dart';

import 'package:flutter_plugin_elui/elui.dart';

import 'package:bfban/utils/index.dart';

class communityPage extends StatefulWidget {
  @override
  _communityPageState createState() => _communityPageState();
}

class _communityPageState extends State<communityPage> {
  /// 近期消息
  Map indexActivity = {
    "registers": [],
  };

  Map<String, dynamic> cheatersPost = {
    "game": "bf1",
    "status": 100,
    "sort": "updateDatetime",
    "page": 1,
    "tz": "Asia%2FShanghai",
    "limit": 40,
  };

  @override
  void initState() {
    super.initState();

    this._getActivity();
  }

  /// 获取近期活动
  void _getActivity() async {
    Response result = await Http.request(
      'api/activity',
      parame: cheatersPost,
      method: Http.GET,
    );

    if (result.data["error"] == 0) {
      setState(() {
        indexActivity = result.data["data"];
      });

      this._onMerge();
    }
  }

  /// 整理活动
  List _onMerge() {
    Function _getTurnTheTimestamp = new Date().getTurnTheTimestamp;
    List list = new List();

    list.addAll(indexActivity["registers"]);
    list.addAll(indexActivity["reports"]);

    list.sort((time, timeing) =>
        _getTurnTheTimestamp(timeing["createDatetime"])["millisecondsSinceEpoch"] -
        _getTurnTheTimestamp(time["createDatetime"])["millisecondsSinceEpoch"]);

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomRight,
              colors: [Colors.transparent, Colors.black38],
            ),
          ),
        ),
      ),
      body: ListView(
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          Container(
            color: Colors.black12,
            margin: EdgeInsets.only(
              top: 20,
              left: 10,
              right: 10,
            ),
            padding: EdgeInsets.only(
              top: 10,
              bottom: 10,
              left: 10,
              right: 10,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      Text(
                        "${indexActivity["number"] == null ? "" : indexActivity["number"]["cheater"]}",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        "\u5df2\u6838\u5b9e\u4f5c\u5f0a\u73a9\u5bb6\u4eba\u6570",
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
                        "${indexActivity["number"] == null ? "" : indexActivity["number"]["report"]}",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        "\u793e\u533a\u5df2\u6536\u5230\u4e3e\u62a5\u6b21\u6570",
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

          SizedBox(
            height: 20,
          ),

          /// 动态
          Column(
            children: _onMerge().map<Widget>((i) {
              return Container(
                color: Color(0xff111b2b),
                margin: EdgeInsets.only(
                  left: 10,
                  right: 10,
                  bottom: 5,
                ),
                padding: EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                  left: 10,
                  right: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.deepOrange,
                            borderRadius: BorderRadius.all(
                              Radius.circular(100),
                            ),
                          ),
                          width: 20,
                          height: 20,
                          child: Center(
                            child: Text(
                              "公",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "动态:",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            new Date().getTimestampTransferCharacter(i["createDatetime"])["Y_D_M"],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "${i["username"].toString()}",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        i["cheaterOriginId"] == null
                            ? Text(
                                "注册了BFBAN，欢迎",
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              )
                            : Text(
                                " 举报了 ${i["cheaterOriginId"]} ${i["game"]}",
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
