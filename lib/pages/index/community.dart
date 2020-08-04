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
  Map indexActivity = new Map();

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
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ListView(
          children: <Widget>[
            /// S 管理面板
            Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 10),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border(
                  top: BorderSide(
                    width: 1,
                    color: Colors.white12,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "${indexActivity["number"] == null ? "" : indexActivity["number"]["report"]}",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "\u793e\u533a\u5df2\u6536\u5230\u4e3e\u62a5\u6b21\u6570",
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        "${indexActivity["number"] == null ? "" : indexActivity["number"]["cheater"]}",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "\u5df2\u6838\u5b9e\u4f5c\u5f0a\u73a9\u5bb6\u4eba\u6570",
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.white,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),

            /// E 管理面板
          ],
        ),
      ),
    );
  }
}
