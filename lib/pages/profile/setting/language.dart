/// 语言选择器
import 'package:flutter/material.dart';

import 'package:bfban/provider/translation_provider.dart';
import 'package:flutter_elui_plugin/_cell/cell.dart';
import 'package:flutter_elui_plugin/_load/index.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

import '../../../provider/lang_provider.dart';
import '../../../utils/index.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({Key? key}) : super(key: key);

  @override
  _LanguagePageState createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  LangProvider? langProvider;

  bool load = false;

  List languages = [];

  @override
  void initState() {
    super.initState();

    langProvider = ProviderUtil().ofLang(context);

    if (langProvider!.currentLang.isEmpty) {
      Future.delayed(Duration.zero, () async {
        setState(() {
          langProvider!.currentLang = FlutterI18n.currentLocale(context)!.languageCode;
        });
      });
    }

    getLanguageList();
  }

  /// [Response]
  /// 获取语言列表
  void getLanguageList() async {
    setState(() {
      load = true;
    });

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

    setState(() {
      load = false;
    });
  }

  /// [Event]
  /// 变动语言
  void setLanguage(context, String value) async {
    if (load) return;

    setState(() {
      load = true;
    });
    await FlutterI18n.refresh(context, Locale(value));
    setState(() {
      langProvider!.currentLang = value;
      load = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "app.setting.language.title")),
        actions: [
          if (load)
            Container(
              height: 40,
              margin: EdgeInsets.only(right: 10),
              child: ELuiLoadComponent(
                type: "line",
                lineWidth: 2,
                color: Theme.of(context).textTheme.subtitle1!.color!,
                size: 25,
              ),
            ),
        ],
      ),
      body: Consumer<TranslationProvider>(
        builder: (BuildContext context, data, Widget? child) {
          return ListView(
            children: [
              // 语言列表
              Opacity(
                opacity: data.autoSwitchLang ? .3 : 1,
                child: Column(
                  children: languages.map((lang) {
                    return RadioListTile<String>(
                      value: lang["fileName"].toString(),
                      onChanged: (value) {
                        setLanguage(context, value as String);
                      },
                      groupValue: langProvider!.currentLang,
                      title: Text(lang["label"].toString()),
                      secondary: Card(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                          child: Text(lang["name"]),
                        ),
                      ),
                      selected: true,
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
