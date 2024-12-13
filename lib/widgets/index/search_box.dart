/// 搜索框

import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:fluro/fluro.dart';

import 'package:bfban/router/router.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_i18n/widgets/I18nText.dart';

enum TitleSearchTheme {
  white,
  black,
}

class TitleSearchColor {
  Color? color;
  Color? iconColor;
  Color? textColor;

  TitleSearchColor(TitleSearchTheme theme) {
    switch (theme) {
      case TitleSearchTheme.black:
        color = Colors.black26;
        iconColor = Colors.white;
        textColor = Colors.white54;
        break;
      case TitleSearchTheme.white:
        color = Colors.white;
        iconColor = Colors.black45;
        textColor = Colors.black45;
        break;
    }
  }
}

class SearchAppBarWidget extends StatefulWidget {
  final TitleSearchTheme theme;

  final Function(String data)? onSubmitted;

  final Function(String data)? onChanged;

  final Widget? laterInterChild;

  final TextEditingController controller;

  const SearchAppBarWidget({
    Key? key,
    this.theme = TitleSearchTheme.black,
    this.onSubmitted,
    this.onChanged,
    this.laterInterChild,
    required this.controller,
  }) : super(key: key);

  @override
  TitleSearchState createState() => TitleSearchState();
}

class TitleSearchState extends State<SearchAppBarWidget> {
  TextEditingController controller = TextEditingController(text: "");

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
      case TitleSearchTheme.white:
        FocusScope.of(context).requestFocus(controllerFocus);
        break;
      case TitleSearchTheme.black:
        Routes.router.navigateTo(
          context,
          '/search/${jsonEncode({"text": value})}',
          transition: TransitionType.cupertino,
        );
        return true;
    }

    return widget.theme == TitleSearchTheme.black ? true : false;
  }

  void unFocus() {
    controllerFocus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: ClipRRect(
        borderRadius: const BorderRadius.all(
          Radius.circular(50),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                constraints: BoxConstraints(minHeight: 45),
                decoration: BoxDecoration(
                  color: TitleSearchColor(widget.theme).color,
                  border: Border.all(color: Theme.of(context).dividerTheme.color!.withOpacity(.3), width: 1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: widget.theme == TitleSearchTheme.white
                          ? TextField(
                              controller: controller,
                              focusNode: controllerFocus,
                              decoration: InputDecoration.collapsed(
                                border: InputBorder.none,
                                hintText: FlutterI18n.translate(context, "search.placeholder"),
                                hintStyle: TextStyle(
                                  color: TitleSearchColor(widget.theme).textColor!.withOpacity(.4),
                                ),
                              ),
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.search,
                              cursorColor: Theme.of(context).colorScheme.primary,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 15,
                                color: TitleSearchColor(widget.theme).textColor,
                              ),
                              // backgroundCursorColor: Colors.white,
                              onSubmitted: (data) {
                                if (widget.onSubmitted != null) {
                                  widget.onSubmitted!(data);
                                }
                              },
                              onChanged: (data) {
                                if (widget.onChanged != null) widget.onChanged!(data);
                              },
                            )
                          : I18nText(
                              "search.placeholder",
                              child: Text(
                                "",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: TitleSearchColor(widget.theme).textColor,
                                ),
                              ),
                            ),
                    ),
                    widget.laterInterChild ?? SizedBox()
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      onTap: () => _onSearch(),
    );
  }
}
