/// 语言选择器

import 'package:bfban/provider/translation_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/_cell/cell.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:provider/provider.dart';

import '../../../utils/index.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({Key? key}) : super(key: key);

  @override
  _LanguagePageState createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  var langProvider;
  Locale? currentLang;

  List languages = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      setState(() {
        currentLang = FlutterI18n.currentLocale(context);
      });
    });

    getLanguageList();
  }

  /// [Response]
  /// 获取语言列表
  void getLanguageList () async {
    Response result = await Http.request(
      "conf/languages.json",
      typeUrl: "app_web_site",
      method: Http.GET,
    );

    if (result.data.toString().isNotEmpty) {
      setState(() {
        languages = result.data["child"];
      });
    }
  }

  /// [Event]
  /// 变动语言
  void setLanguage(context, String value) async {
    // changeLocale(context, value);
    currentLang = Locale(value);
    await FlutterI18n.refresh(context, currentLang);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
              label: translate("basic.function.auto.describe"),
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
                children: languages.map((lang) {
                  return RadioListTile<String>(
                    value: lang["fileName"].toString(),
                    onChanged: (value) {
                      setLanguage(context, value!);
                      // setLanguage(context, value!);
                    },
                    groupValue: currentLang?.languageCode,
                    title: Text(lang["label"].toString()),
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
