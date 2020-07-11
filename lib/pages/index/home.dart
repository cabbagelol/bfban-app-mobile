import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/rendering.dart';

import 'package:bfban/router/router.dart';
import 'package:bfban/widgets/index/search.dart';
import 'package:bfban/utils/index.dart';
import 'package:flutter_plugin_elui/elui.dart';

class homePage extends StatefulWidget {
  @override
  _homePageState createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  var indexDate = new Map();
  List indexDateList = new List();
  int indexPagesIndex = 1;
  bool indexPagesState = true;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    this._getIndexList(1);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        print('滑动到了最底部');
        _getMore();
      }
    });
  }

  /// 获取列表
  void _getIndexList(index) async {
    var result = await Http.request(
        'api/cheaters/?game=bfv&status=100&cd=&ud=&page=${index}&sort=updateDatetime&tz=Asia%2FShanghai&limit=40',
        method: Http.GET,
    );

    setState(() {
      indexPagesState = true;
    });

    if (result["error"] == 0) {
      setState(() {
        indexDate = result;
        if (index > 1) {
          result["data"].forEach((i) {
            indexDateList.add(i);
          });
        } else {
          indexDateList = result["data"];
        }
      });
    } else if (result["code"] == -2) {
      EluiMessageComponent.error(context)(
          child: Text("请求异常请联系开发者"),
      );
    }

    setState(() {
      indexPagesState = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: SearchHead(),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: indexDateList.length,
                itemBuilder: (BuildContext context, int index) {
                  return homeItem(item: indexDateList[index]);
                },
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.add,
            color: Colors.black,
            size: 40,
          ),
          onPressed: () {
            Routes.router.navigateTo(context, '/edit',
                transition: TransitionType.fadeIn);
          },
          backgroundColor: Colors.yellow),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  /**
   * 加载更多时显示的组件,给用户提示
   */
  Widget _getMoreWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              '加载中...     ',
              style: TextStyle(fontSize: 16.0),
            ),
            CircularProgressIndicator(
              strokeWidth: 1.0,
            )
          ],
        ),
      ),
    );
  }

  /**
   * 下拉刷新方法,为list重新赋值
   */
  Future<Null> _onRefresh() async {
    await Future.delayed(Duration(seconds: 1), () {
      this._getIndexList(1);
    });
  }

  /**
   * 上拉加载更多
   */
  Future _getMore() async {
    await Future.delayed(Duration(seconds: 1), () {
      if (indexPagesState) {
        return;
      }
      setState(() {
        indexPagesIndex += 1;
      });
      this._getIndexList(indexPagesIndex);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scrollController.dispose();
  }
}

class homeItem extends StatelessWidget {
  final item;

  homeItem({this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Routes.router.navigateTo(
              context, '/detail/cheaters/${item["originUserId"]}',
              transition: TransitionType.fadeIn);
        },
        child: Container(
          color: Color.fromRGBO(0, 0, 0, .3),
          margin: EdgeInsets.only(bottom: 1),
          padding: EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                margin: EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(100),
                  image:
                      DecorationImage(image: NetworkImage(item["avatarLink"])),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(item["originId"],
                        style: TextStyle(color: Colors.white, fontSize: 20)),
                    Row(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.visibility,
                              color: Colors.white,
                              size: 13,
                            ),
                            Text(item["n"].toString() ?? "",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12))
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.add_comment,
                              color: Colors.white,
                              size: 13,
                            ),
                            Text(item["commentsNum"].toString() ?? "",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 13))
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text("发布日期:",
                      style: TextStyle(
                          color: Color.fromRGBO(255, 255, 255, .6),
                          fontSize: 12)),
                  Text("${item["createDatetime"]}",
                      style: TextStyle(
                          color: Color.fromRGBO(255, 255, 255, .6),
                          fontSize: 13))
                ],
              )
            ],
          ),
        ));
  }
}
