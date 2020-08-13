/// 搜索
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:fluro/fluro.dart';

import 'package:flutter_plugin_elui/elui.dart';

import 'package:bfban/router/router.dart';

enum titleSearchTheme {
  white,
  black,
}

class titleSearchColor {
  Color color;
  Color iconColor;
  Color textColor;

  titleSearchColor(titleSearchTheme theme) {
    switch (theme) {
      case titleSearchTheme.black:
        color = Colors.black12;
        iconColor = Colors.white;
        textColor = Colors.white54;
        break;
      case titleSearchTheme.white:
        color = Colors.white;
        iconColor = Colors.black45;
        textColor = Colors.black45;
        break;
    }
  }
}

class titleSearch extends StatefulWidget {
  final titleSearchTheme theme;

  final Function onSubmitted;

  final controller;

  titleSearch({
    this.theme = titleSearchTheme.black,
    this.onSubmitted,
    this.controller,
  });

  @override
  _searchState createState() => _searchState();
}

class _searchState extends State<titleSearch> {
  TextEditingController controller = TextEditingController();

  FocusNode controllerFocus = FocusNode();

  String value = "";

  @override
  void initState() {
    controller = widget.controller;

    super.initState();
  }

  /// 搜索
  dynamic _onSearch() {
    switch (widget.theme) {
      case titleSearchTheme.white:
        FocusScope.of(context).requestFocus(controllerFocus);
        break;
      case titleSearchTheme.black:
        Routes.router.navigateTo(
          context,
          '/search/${jsonEncode({
            "id": value,
          })}',
          transition: TransitionType.cupertino,
        );
        return true;
        break;
    }
    return widget.theme == titleSearchTheme.black ? true : false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: ClipRRect(
        borderRadius: BorderRadius.all(
          Radius.circular(5),
        ),
        child: Container(
          padding: EdgeInsets.only(
            left: 10,
            top: 10,
            right: 10,
            bottom: 10,
          ),
          color: titleSearchColor(widget.theme).color,
          child: Row(
            children: <Widget>[
              Icon(
                Icons.search,
                color: titleSearchColor(widget.theme).iconColor,
                size: 20,
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                flex: 1,
                child: widget.theme == titleSearchTheme.white ? EditableText(
                  controller: controller,
                  focusNode: controllerFocus,
                  keyboardType: TextInputType.text,
                  cursorColor: Color(0xff364e80),
                  cursorWidth: 3,
                  cursorRadius: Radius.circular(100),
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black45,
                  ),
                  backgroundCursorColor: Colors.white,
                  onSubmitted: (data) => widget.onSubmitted(data) ,
                ) : Text(
                  "搜索作弊者id",
                  style: TextStyle(
                    fontSize: 15,
                    color: titleSearchColor(widget.theme).textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () => _onSearch(),
    );
  }
}
