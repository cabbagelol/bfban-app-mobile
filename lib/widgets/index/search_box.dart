/// 搜索框

import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:fluro/fluro.dart';

import 'package:bfban/router/router.dart';
import 'package:flutter_i18n/widgets/I18nText.dart';

enum titleSearchTheme {
  white,
  black,
}

class titleSearchColor {
  Color? color;
  Color? iconColor;
  Color? textColor;

  titleSearchColor(titleSearchTheme theme) {
    switch (theme) {
      case titleSearchTheme.black:
        color = Colors.black38;
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

  final Function? onSubmitted;

  final Function? onChanged;

  final Widget? child;

  final TextEditingController controller;

  titleSearch({
    Key? key,
    this.theme = titleSearchTheme.black,
    this.child,
    this.onSubmitted,
    this.onChanged,
    required this.controller,
  }) : super(key: key);

  @override
  searchState createState() => searchState();
}

class searchState extends State<titleSearch> {
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
      case titleSearchTheme.white:
        FocusScope.of(context).requestFocus(controllerFocus);
        break;
      case titleSearchTheme.black:
        Routes.router!.navigateTo(
          context,
          '/search/${jsonEncode({
                "id": value,
              })}',
          transition: TransitionType.cupertino,
        );
        return true;
    }

    return widget.theme == titleSearchTheme.black ? true : false;
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                color: titleSearchColor(widget.theme).color,
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.search,
                      color: titleSearchColor(widget.theme).iconColor,
                      size: 20,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      flex: 1,
                      child: widget.theme == titleSearchTheme.white
                          ? EditableText(
                              controller: controller,
                              focusNode: controllerFocus,
                              keyboardType: TextInputType.text,
                              cursorColor: const Color(0xff364e80),
                              cursorWidth: 3,
                              cursorRadius: const Radius.circular(100),
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black45,
                              ),
                              backgroundCursorColor: Colors.white,
                              onSubmitted: (data) => widget.onSubmitted!(data),
                              onChanged: (data) => widget.onChanged!(data),
                            )
                          : I18nText(
                              "search.placeholder",
                              child: Text(
                                "",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: titleSearchColor(widget.theme).textColor,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),

            // 尾部
            if (widget.child != null) widget.child!,
          ],
        ),
      ),
      onTap: () => _onSearch(),
    );
  }
}
