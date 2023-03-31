import 'package:bfban/component/_empty/index.dart';
import 'package:bfban/component/_html/html.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../widgets/detail/cheaters_card_types.dart';

enum HtmlWidgetFontSize {
  Large,
  Default,
  Small,
}

class HtmlWidget extends StatefulWidget {
  String? content;
  HtmlWidgetFontSize? size;
  List sizeConfig = [];
  Widget? quote;

  HtmlWidget({
    Key? key,
    this.content,
    HtmlWidgetFontSize? size = HtmlWidgetFontSize.Default,
    this.quote,
  }) : super(key: key) {}

  @override
  State<HtmlWidget> createState() => _HtmlWidgetState();
}

class _HtmlWidgetState extends State<HtmlWidget> {
  final CardUtil _detailApi = CardUtil();

  Future? futureBuilder;

  List htmlStyle = [];

  List dropdownSizeType = [
    {"name": "Large", "value": "0"},
    {"name": "Default", "value": "1"},
    {"name": "Small", "value": "2"},
  ];

  List dropdownRenderingMethods = [
    {"name": "Code", "value": "0"},
    {"name": "Render", "value": "1"},
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    futureBuilder = onReady();
    super.didChangeDependencies();
  }

  Future onReady() async {
    htmlStyle = [
      {
        "img": Style(color: Theme.of(context).primaryColorDark, padding: const EdgeInsets.symmetric(vertical: 5)),
        "p": Style(
          fontSize: FontSize(12),
          color: Theme.of(context).textTheme.subtitle1!.color,
        ),
      },
      {
        "img": Style(color: Theme.of(context).primaryColorDark, padding: const EdgeInsets.symmetric(vertical: 5)),
        "p": Style(
          fontSize: FontSize(15),
          color: Theme.of(context).textTheme.subtitle1!.color,
        ),
      },
      {
        "img": Style(color: Theme.of(context).primaryColorDark, padding: const EdgeInsets.symmetric(vertical: 5)),
        "p": Style(
          fontSize: FontSize(20),
          color: Theme.of(context).textTheme.subtitle1!.color,
        ),
      }
    ];
    return htmlStyle;
  }

  dynamic dropdownSizeTypeSelectedValue = "1";
  dynamic dropdownRenderingSelectedValue = "1";

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: futureBuilder,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return Offstage(
                offstage: widget.content == "",
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor, width: 1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Column(
                    children: [
                      [
                        Text(widget.content.toString()),
                        HtmlCore(
                          data: widget.content,
                          style: htmlStyle[int.parse(dropdownSizeTypeSelectedValue)],
                        )
                      ][int.parse(dropdownRenderingSelectedValue)],
                      const Divider(height: 1),
                      SizedBox(
                        height: 20,
                        child: Row(
                          children: [
                            const Expanded(
                              child: SizedBox(width: 1),
                            ),
                            DropdownButton(
                              underline: Container(),
                              style: const TextStyle(fontSize: 12),
                              items: dropdownSizeType.map<DropdownMenuItem<String>>((e) {
                                return DropdownMenuItem(
                                  value: e["value"],
                                  onTap: () {},
                                  child: Text(e["name"]),
                                );
                              }).toList(),
                              value: dropdownSizeTypeSelectedValue,
                              onChanged: (selected) {
                                setState(() {
                                  dropdownSizeTypeSelectedValue = selected;
                                });
                              },
                            ),
                            const SizedBox(
                              width: 20,
                              height: 8,
                              child: VerticalDivider(width: 1),
                            ),
                            DropdownButton(
                              underline: Container(),
                              style: const TextStyle(fontSize: 12),
                              items: dropdownRenderingMethods.map<DropdownMenuItem<String>>((e) {
                                return DropdownMenuItem(
                                  value: e["value"],
                                  onTap: () {},
                                  child: Text(e["name"]),
                                );
                              }).toList(),
                              value: dropdownRenderingSelectedValue,
                              onChanged: (selected) {
                                setState(() {
                                  dropdownRenderingSelectedValue = selected;
                                });
                              },
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
          }

          return const EmptyWidget();
        });
  }
}
