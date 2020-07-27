/// 搜索
/// 公共头

import 'package:flutter/cupertino.dart';
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
  String searchValue = "";

  @override
  void initState() {
    super.initState();
  }

  /// 输入框onChange
  void _onChange(String value) {
    if (widget.onChange is Function) {
      widget.onChange(value);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(
        Radius.circular(5),
      ),
      child: Container(
        height: 48,
        color: Color.fromRGBO(238, 238, 238, 1),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                child: EluiInputComponent(
                  placeholder: "搜索作弊者ID",
                  Internalstyle: true,
                  onChange: (data) {
                    setState(() {
                      searchValue = data["value"];
                    });
                  },
                ),
              ),
            ),
            Container(
              color: Color(0xff364e80),
              margin: EdgeInsets.only(
                left: 4,
              ),
              child: FlatButton(
                child: Icon(
                  Icons.search,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => widget.onSearch(searchValue),
              ),
              height: 48,
            )
          ],
        ),
      ),
    );
  }
}
