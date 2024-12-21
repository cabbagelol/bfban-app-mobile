/// 语言选择器
library;

import 'package:bfban/component/_loading/index.dart';
import 'package:flutter/material.dart';

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

import '../../../component/_refresh/index.dart';
import '/provider/translation_provider.dart';
import '/utils/index.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  LanguagePageState createState() => LanguagePageState();
}

class LanguagePageState extends State<LanguagePage> {
  /// 列表
  final GlobalKey<RefreshState> _refreshKey = GlobalKey<RefreshState>();

  TranslationProvider? langProvider;

  bool updataLoading = false;

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
  Future getLanguageList() async {
    try {
      Response result = await Http.fetchJsonPData(
        "config/languages.json",
        httpDioValue: "app_web_site",
      );

      if (result.data.toString().isNotEmpty) {
        setState(() {
          languages = result.data["child"];
        });
      }
    } finally {}

    return true;
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
    await FlutterI18n.refresh(context, Locale(currentPageSelectLang));

    setState(() {
      updataLoading = true;
    });

    setState(() {
      // 重新赋值，会调用更新远程配置
      langProvider!.currentLang = currentPageSelectLang;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        updataLoading = false;
      });
    });
  }

  Future _onRefresh() async {
    await getLanguageList();

    _refreshKey.currentState?.controller.finishRefresh();
    _refreshKey.currentState?.controller.finishLoad();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "app.setting.language.title")),
        actions: [
          if (currentPageSelectLang != langProvider!.currentLang)
            IconButton(
              onPressed: () => saveLocalLanguage(context),
              icon: const Icon(Icons.done),
            )
        ],
        leading: Builder(
          builder: (BuildContext context) {
            return BackButton(
              onPressed: () {
                if (_refreshKey.currentState!.controller.controlFinishRefresh) Navigator.of(context).pop();
              },
            );
          },
        ),
      ),
      body: Refresh(
        key: _refreshKey,
        onRefresh: _onRefresh,
        child: Consumer<TranslationProvider>(
          builder: (BuildContext context, langData, Widget? child) {
            return ListView.separated(
              itemCount: languages.length,
              separatorBuilder: (context, index) => Divider(height: 1),
              itemBuilder: (context, index) {
                Map lang = languages[index];
                return RadioListTile<String>(
                  value: lang["fileName"].toString(),
                  onChanged: (value) => setCurrentPageSelectLang(value as String),
                  groupValue: currentPageSelectLang,
                  selectedTileColor: langData.currentLang == lang['fileName'] ? Theme.of(context).dividerColor.withOpacity(.05) : null,
                  title: Text(
                    lang["label"].toString(),
                    style: Theme.of(context).listTileTheme.titleTextStyle!.copyWith(fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize),
                  ),
                  subtitle: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      Icon(Icons.translate, size: 15),
                      if (lang["members"] != null && lang["members"].isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 3,
                          children: lang["members"].map<Widget>((i) {
                            return Text(i["name"]);
                          }).toList(),
                        )
                      else
                        const Text("N/A"),
                    ],
                  ),
                  secondary: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    children: [
                      if (lang["fileName"] == langProvider!.currentLang)
                        if (!updataLoading)
                          IconButton(
                            onPressed: () => saveLocalLanguage(context),
                            style: ButtonStyle(visualDensity: VisualDensity.compact),
                            icon: const Icon(Icons.refresh),
                          )
                        else
                          SizedBox(
                            width: 30,
                            child: LoadingWidget(
                              size: 16,
                            ),
                          ),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 15),
                          child: Text(lang["name"]),
                        ),
                      ),
                    ],
                  ),
                  selected: true,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
