import 'package:flutter/cupertino.dart';
/**
 * 搜索
 * 公共头
 */

import 'package:flutter/material.dart';

class SearchHead extends StatefulWidget {
  final Key key;
  final Widget left;
  final Widget right;
  final String value;
  final Function onSearch;
  final Function(String value) onChange;

  SearchHead({
    this.key,
    this.value = '',
    this.left,
    this.right,
    this.onSearch,
    this.onChange
  }) : super(key: key);

  @override
  SearchHeadState createState() => SearchHeadState();
}

class SearchHeadState extends State<SearchHead> {
  @override
  void initState() {
    super.initState();

  }

  // 输入框onChange
  void _onChange(String value) {
    if (widget.onChange is Function) {
      widget.onChange(value);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 15),
      child: Row(
        children: <Widget>[
          Expanded(
              flex: 1,
              child: Container(
                margin: EdgeInsets.only(
                  top: 0,
                  bottom: 0,
                ),
                decoration: BoxDecoration(
                    color: Color.fromRGBO(238, 238, 238, 1),
                    borderRadius: BorderRadius.circular(5.0),
                ),
                child: Container(
                  child: Row(
                    children: <Widget>[
                      Center(
                        child: Container(
                          margin: EdgeInsets.only(left: 10, right: 5),
                          child: Icon(
                            Icons.search,
                            color: Color(0xFF979797),
                            size: 20,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              child: TextField(
                                onChanged: _onChange,
                                style: TextStyle(
                                    fontSize: 14
                                ),
                                decoration: InputDecoration(
                                  hintText: '搜索玩家名称',
                                  contentPadding: EdgeInsets.all(0),
                                  border: InputBorder.none,
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
