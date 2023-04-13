/// 语言选择器
import 'package:flutter/material.dart';

import 'package:flutter_elui_plugin/_load/index.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

import '../../../provider/translation_provider.dart';
import '../../../utils/index.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({Key? key}) : super(key: key);

  @override
  _LanguagePageState createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  TranslationProvider? langProvider;

  bool load = false;

  List languages = [];

  String currentPageSelectLang = "";

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

    setState(() {
      // 初始页面语言值
      currentPageSelectLang = langProvider!.currentLang;
    });

    getLanguageList();
  }

  /// [Response]
  /// 获取语言列表
  void getLanguageList() async {
    setState(() {
      load = true;
    });

    Response result = await Http.request(
      "config/languages.json",
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
  /// 改变当前页面选择的语言
  /// 未保存
  void setCurrentPageSelectLang(String value) {
    if (value.isEmpty) return;
    setState(() {
      currentPageSelectLang = value;
    });
  }

  /// [Event]
  /// 变动语言
  void saveLocalLanguage(BuildContext context) async {
    if (load && currentPageSelectLang == langProvider!.currentLang) return;

    setState(() {
      load = true;
    });
    await FlutterI18n.refresh(context, Locale(currentPageSelectLang));
    setState(() {
      langProvider!.currentLang = currentPageSelectLang;
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
            IconButton(
              onPressed: () {},
              icon: ELuiLoadComponent(
                type: "line",
                lineWidth: 2,
                color: Theme.of(context).textTheme.displayMedium!.color!,
                size: 20,
              ),
            )
          else if (!load && currentPageSelectLang != langProvider!.currentLang)
            IconButton(
              onPressed: () => saveLocalLanguage(context),
              icon: const Icon(Icons.done),
            ),
        ],
      ),
      body: Consumer<TranslationProvider>(
        builder: (BuildContext context, data, Widget? child) {
          return ListView(
            children: languages.map((lang) {
              return RadioListTile<String>(
                value: lang["fileName"].toString(),
                onChanged: (value) => setCurrentPageSelectLang(value as String),
                groupValue: currentPageSelectLang,
                title: Text(
                  lang["label"].toString(),
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium!.color,
                  ),
                ),
                secondary: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                    child: Text(lang["name"]),
                  ),
                ),
                selected: true,
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
