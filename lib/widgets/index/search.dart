import 'package:flutter/cupertino.dart';
/**
 * 搜索
 * 公共头
 */

import 'package:flutter/material.dart';
import 'package:flutter_plugin_elui/_input/index.dart';

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
    this.onChange,
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
      decoration: BoxDecoration(
        color: Color.fromRGBO(238, 238, 238, 1),
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Row(
        children: <Widget>[
          Flexible(
            flex: 1,
            child: EluiInputComponent(
              value: "",
              placeholder: "搜索内容",
              Internalstyle: true,
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              right: 2,
              left: 4,
            ),
            child: FlatButton(
              disabledColor: Colors.white70,
              color: Color(0xff364e80),
              child: Icon(
                Icons.search,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {},
            ),
            height: 45,
          )
        ],
      ),
    );
  }
}
