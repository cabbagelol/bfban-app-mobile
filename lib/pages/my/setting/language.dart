/// 语言选择器

import 'package:bfban/provider/translation_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/_cell/cell.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:provider/provider.dart';

import '../../../utils/index.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({Key? key}) : super(key: key);

  @override
  _LanguagePageState createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  LocalizationDelegate? localizationDelegate;

  List langList = [
    {"name": "zh_Hant", "label": "繁体中文", "uri": "/lang/app/zh_Hans.json", "main": true, "members": []},
    {"name": "zh_Hans", "label": "简体中文", "uri": "/lang/app/zh_Hans.json", "main": true, "members": []},
    // {"name": "en_US", "label": "English", "members": []}
  ];

  @override
  void initState() {
    super.initState();

    getLang();
  }

  /// [Response]
  /// 获取语言列表
  void getLang () async {
    Response result = await Http.request(
      "/conf/languages.json",
      typeUrl: "bfban_web_site_conf",
      method: Http.GET,
    );

    if (result.data) {
      setState(() {
        langList = result.data["child"];
      });
    }
  }

  /// [Event]
  /// 变动语言
  void setLang(context, String value) async {
    changeLocale(context, value);
  }

  @override
  Widget build(BuildContext context) {
    localizationDelegate = LocalizedApp.of(context).delegate;

    return Scaffold(
      appBar: AppBar(
        title: Text(translate("setting.language.title")),
      ),
      body: Consumer<TranslationProvider>(builder: (BuildContext context, data, Widget? child) {
        return ListView(
          children: [
            // 例子
            EluiCellComponent(
              title: translate("basic.function.auto.title"),
              label: translate("basic.function.auto.describe") + localizationDelegate!.currentLocale.toString(),
              theme: EluiCellTheme(
                titleColor: Theme.of(context).textTheme.subtitle1?.color,
                labelColor: Theme.of(context).textTheme.subtitle2?.color,
                linkColor: Theme.of(context).textTheme.subtitle1?.color,
                backgroundColor: Theme.of(context).cardTheme.color,
              ),
              cont: Switch(
                value: data.autoSwitchLang,
                onChanged: (bool value) {
                  data.autoSwitchLang = value;
                },
              ),
            ),
            // 语言列表
            Opacity(
              opacity: data.autoSwitchLang ? .3 : 1,
              child: Column(
                children: langList.map((e) {
                  return RadioListTile<String>(
                    value: e["name"].toString(),
                    onChanged: (value) {
                      setLang(context, value!);
                    },
                    groupValue: localizationDelegate!.currentLocale.toString(),
                    title: Text(e["label"].toString()),
                    selected: true,
                  );
                }).toList(),
              ),
            ),
          ],
        );
      }),
    );
  }
}
