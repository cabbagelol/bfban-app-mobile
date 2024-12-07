import 'package:bfban/component/_loading/index.dart';
import 'package:bfban/data/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';

import '../../provider/translation_provider.dart';
import '../../utils/index.dart';

class HtmlTextTranslator extends StatefulWidget {
  final String content;

  const HtmlTextTranslator({
    Key? key,
    required this.content,
  }) : super(key: key);

  @override
  State<HtmlTextTranslator> createState() => _HtmlTextTranslatorState();
}

class _HtmlTextTranslatorState extends State<HtmlTextTranslator> {
  final UrlUtil _urlUtil = UrlUtil();

  // 使用的模块
  int selectModeTranslatorIndex = 2;

  // 结果
  // 翻译文本
  String translation = "";

  // 翻译请求指示器
  bool load = false;

  // 模式是否准备好
  bool modeReadyLoad = false;

  /// [Event]
  /// 打开翻译器配置
  _opEnPublicTranslator(BuildContext context) {
    _urlUtil.opEnPage(context, "/profile/translator");
  }

  @override
  void initState() {
    onReady();
    super.initState();
  }

  void onReady() async {
    setState(() {
      modeReadyLoad = true;
    });

    setState(() {
      modeReadyLoad = false;
      eventUtil.emit("html-image-update-widget", {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PublicApiTranslationProvider>(
      builder: (BuildContext context, data, Widget? child) {
        if (!data.isSwitch && !modeReadyLoad) return const SizedBox();

        return Column(
          children: [
            if (translation.isNotEmpty) const Divider(),
            if (translation.isNotEmpty) Html(data: translation),
            if (data.currentPublicTranslatorItem.type != PublicTranslatorType.none)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          child: const Icon(Icons.translate, size: 15),
                          onTap: () => _opEnPublicTranslator(context),
                        ),
                        const SizedBox(width: 2),
                        const Icon(Icons.arrow_right_alt, size: 15),
                        const SizedBox(width: 2),
                        SizedBox(
                          height: 20,
                          child: DropdownButton(
                            underline: const SizedBox(),
                            menuMaxHeight: 200,
                            dropdownColor: Theme.of(context).bottomAppBarTheme.color,
                            style: Theme.of(context).dropdownMenuTheme.textStyle,
                            value: data.currentPublicTranslatorItem.currentToLang,
                            items: Map.from(data.currentPublicTranslatorItem.allToLang).entries.map((i) {
                              return DropdownMenuItem(
                                value: i.key,
                                child: Text(i.value.toString()),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                data.currentPublicTranslatorItem.currentToLang = value.toString();
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 4),
                        TextButton(
                          onPressed: () async {
                            if (data.currentPublicTranslatorItem.allToLang.isEmpty || data.userTrList.isEmpty || data.currentPublicTranslatorItem.type == PublicTranslatorType.none) return;
                            if (load || widget.content.isEmpty) return;

                            setState(() {
                              load = true;
                            });

                            // 翻译开始！
                            String targetContent = await data.currentPublicTranslatorItem.tr(
                              widget.content,
                              data.currentPublicTranslatorItem.currentToLang,
                            );

                            setState(() {
                              translation = targetContent;
                            });

                            Future.delayed(const Duration(microseconds: 300), () {
                              eventUtil.emit("html-image-update-widget", {});
                            });

                            setState(() {
                              load = false;
                            });
                          },
                          style: ButtonStyle(
                            padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 2, vertical: 1)),
                            //设置按钮的大小
                            minimumSize: WidgetStateProperty.all(const Size(2, 2)),
                          ),
                          child: load
                              ? Container(
                                  margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 2),
                                  width: 10,
                                  height: 10,
                                  child: const LoadingWidget(strokeWidth: 1),
                                )
                              : const Text('翻译'),
                        )
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 0),
                      child: Opacity(
                        opacity: .3,
                        child: Text("Mode: ${data.selectActivate}"),
                      ),
                    )
                  ],
                ),
              )
            else
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  children: [
                    GestureDetector(
                      child: const Icon(Icons.translate, size: 15),
                      onTap: () => _opEnPublicTranslator(context),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.arrow_right_alt, size: 15),
                    const SizedBox(width: 2),
                    Icon(Icons.error_outline, size: 15, color: Theme.of(context).colorScheme.error),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
