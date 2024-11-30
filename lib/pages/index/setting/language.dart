/// 语言选择器
library;

import 'package:bfban/component/_loading/index.dart';
import 'package:flutter/material.dart';

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

import '/provider/translation_provider.dart';
import '/utils/index.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  LanguagePageState createState() => LanguagePageState();
}

class LanguagePageState extends State<LanguagePage> {
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
      httpDioValue: "app_web_site",
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
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        load = false;
      });
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
              padding: const EdgeInsets.all(16),
              onPressed: () {},
              icon: LoadingWidget(
                size: 20,
              ),
            )
          else if (!load && currentPageSelectLang != langProvider!.currentLang)
            IconButton(
              onPressed: () => saveLocalLanguage(context),
              icon: const Icon(Icons.done),
            )
          else if (!load && currentPageSelectLang == langProvider!.currentLang)
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Icon(Icons.warning, size: 15, color: Colors.yellow),
                IconButton(
                  onPressed: () => saveLocalLanguage(context),
                  icon: const Icon(Icons.download),
                ),
              ],
            ),
        ],
        leading: Builder(
          builder: (BuildContext context) {
            return BackButton(
              onPressed: () {
                if (load == false) Navigator.of(context).pop();
              },
            );
          },
        ),
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
                  style: Theme.of(context).listTileTheme.titleTextStyle!.copyWith(fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize),
                ),
                subtitle: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    if (lang["members"] != null && lang["members"].isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 3,
                        children: lang["members"].map<Widget>((i) {
                          return Text(i["name"]);
                        }).toList(),
                      )
                    else
                      const Text("N/A")
                  ],
                ),
                secondary: Wrap(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                        child: Text(lang["name"]),
                      ),
                    ),
                  ],
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
