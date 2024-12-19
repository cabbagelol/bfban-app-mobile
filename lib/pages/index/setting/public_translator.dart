import 'package:bfban/component/_empty/index.dart';
import 'package:bfban/component/_html/htmlLink.dart';
import 'package:bfban/utils/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/elui.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

import '/data/index.dart';
import '/provider/translation_provider.dart';

class PublicTranslatorPage extends StatefulWidget {
  const PublicTranslatorPage({super.key});

  @override
  State<PublicTranslatorPage> createState() => _PublicTranslatorPageState();
}

class _PublicTranslatorPageState extends State<PublicTranslatorPage> {
  PublicApiTranslationProvider? publicApiTranslationProvider;

  // 镜像
  List<PublicTranslatorItem> mirror_trList = [];

  // 所有翻译API选项
  List<PublicTranslatorItem> trList = [
    PublicTranslatorItem(),
    PublicTranslatorDeeplItem(),
    PublicTranslatorYoudaoItem(),
    PublicTranslatorGoogleItem(),
  ];

  @override
  void initState() {
    publicApiTranslationProvider = Provider.of<PublicApiTranslationProvider>(context, listen: false);

    onReady();
    super.initState();
  }

  void onReady() async {
    String selectActivate = await publicApiTranslationProvider!.getSelectActivate();
    setState(() {
      mirror_trList = List.from(trList);
    });

    setState(() {
      // 更新激活模块名称
      if (publicApiTranslationProvider!.userTrList.isNotEmpty) publicApiTranslationProvider!.selectActivate = selectActivate;
    });
  }

  /// [Event]
  /// 保存
  void _onSave() {
    publicApiTranslationProvider!.onSave();

    EluiMessageComponent.success(context)(child: const Icon(Icons.done));
  }

  /// [Event]
  /// 添加
  void _onAddItem() {
    if (publicApiTranslationProvider!.userTrList.length >= trList.length - 1) return;

    PublicTranslatorBox item = PublicTranslatorBox();
    item.data = PublicTranslatorItem();
    item.index = item.data!.type.index;

    setState(() {
      if (item.data!.type.index != 0) mirror_trList.removeAt(trList.indexWhere((element) => element.type.index == item.data!.type.index));
      publicApiTranslationProvider!.userTrList.add(item);
    });
  }

  /// [Event]
  /// 删除
  void _onDeleItem(index, e) {
    setState(() {
      mirror_trList.add(e);
      publicApiTranslationProvider!.userTrList.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PublicApiTranslationProvider>(
      builder: (BuildContext context, data, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(FlutterI18n.translate(context, "app.setting.publicTranslator.title")),
            actions: [
              IconButton(
                padding: const EdgeInsets.all(16),
                onPressed: () {
                  _onAddItem();
                },
                icon: const Icon(Icons.add),
              ),
              const VerticalDivider(),
              IconButton(
                padding: const EdgeInsets.all(16),
                onPressed: () {
                  _onSave();
                },
                icon: const Icon(Icons.done),
              ),
            ],
          ),
          body: Column(
            children: [
              EluiCellComponent(
                title: FlutterI18n.translate(context, "app.setting.publicTranslator.switch"),
                label: FlutterI18n.translate(context, "app.setting.publicTranslator.switchDescription"),
                theme: EluiCellTheme(
                  titleColor: Theme.of(context).textTheme.titleMedium?.color,
                  labelColor: Theme.of(context).textTheme.displayMedium?.color,
                  linkColor: Theme.of(context).textTheme.titleMedium?.color,
                  backgroundColor: Theme.of(context).cardTheme.color,
                ),
                cont: Switch(
                  value: data.isSwitch,
                  onChanged: (bool value) {
                    data.isSwitch = value;
                  },
                ),
              ),
              Expanded(
                flex: 1,
                child: ListView(
                  children: [
                    if (data.userTrList.isNotEmpty && data.selectActivate.isNotEmpty)
                      EluiCellComponent(
                        title: "use '${data.selectActivate}' mode",
                      ),
                    if (data.userTrList.isNotEmpty)
                      Column(
                        children: data.userTrList.map((e) {
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 选项API类型
                                    Row(
                                      children: [
                                        Visibility(
                                          maintainState: true,
                                          maintainAnimation: true,
                                          maintainSize: true,
                                          visible: e.data!.type != PublicTranslatorType.none,
                                          child: Radio(
                                            value: e.data!.type.name,
                                            groupValue: data.selectActivate,
                                            onChanged: (value) {
                                              if (e.data!.type != PublicTranslatorType.none) {
                                                data.selectActivate = value.toString();
                                              }
                                            },
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(3),
                                              side: BorderSide(
                                                color: Theme.of(context).dividerTheme.color!,
                                                width: 1,
                                              ),
                                            ),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                              child: DropdownButton(
                                                isExpanded: true,
                                                underline: const SizedBox(),
                                                dropdownColor: Theme.of(context).bottomAppBarTheme.color,
                                                style: Theme.of(context).dropdownMenuTheme.textStyle,
                                                value: e.index,
                                                items: trList.map((trlistItem) {
                                                  return DropdownMenuItem(
                                                    value: trlistItem.type.index,
                                                    child: Text(trlistItem.type.name.toString()),
                                                  );
                                                }).toList(),
                                                onChanged: (index) {
                                                  if (data.userTrList.where((mirrorTrlistWhere) => mirrorTrlistWhere.index == index).isNotEmpty) {
                                                    EluiMessageComponent.error(context)(child: const Text("The current list uses the translation module"));
                                                    return;
                                                  }

                                                  setState(() {
                                                    e.data = trList.where((element) => element.type.index == index).first;
                                                    e.index = int.parse(index.toString());

                                                    // 当仅有一个模块时，赋予激活选择模块名称
                                                    if (e.data!.type != PublicTranslatorType.none && data.userTrList.length <= 1) {
                                                      data.selectActivate = e.data!.type.name;
                                                    }
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            int index = data.userTrList.indexWhere((element) => element.index == e.index);
                                            _onDeleItem(index, e.data);
                                          },
                                          icon: const Icon(Icons.delete),
                                        )
                                      ],
                                    ),
                                    // 密匙等
                                    Container(
                                      margin: const EdgeInsets.only(left: 30),
                                      child: Column(
                                        children: Map.of(e.data!.toMap).entries.map<Widget>((item) {
                                          return EluiInputComponent(
                                            value: item.value.toString(),
                                            placeholder: item.key.toString(),
                                            onChange: (itemValue) {
                                              setState(() {
                                                e.data?.toMap[item.key] = itemValue["value"];
                                              });
                                            },
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                    if (e.data!.type != PublicTranslatorType.none) const SizedBox(height: 10),
                                    if (e.data!.type != PublicTranslatorType.none)
                                      Container(
                                        margin: const EdgeInsets.only(left: 40),
                                        child: Wrap(
                                          children: [
                                            const Text("Support:"),
                                            HtmlLink(url: e.data!.support),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const Divider()
                            ],
                          );
                        }).toList(),
                      )
                    else
                      const EmptyWidget()
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
