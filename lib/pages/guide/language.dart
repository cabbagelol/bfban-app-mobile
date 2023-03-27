import 'package:flutter/material.dart';

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_elui_plugin/elui.dart';
import 'package:provider/provider.dart';

import '../../provider/lang_provider.dart';
import '../../provider/translation_provider.dart';
import '../../utils/http.dart';
import '../../utils/provider.dart';

class GuideLanguagePage extends StatefulWidget {
  final Function? onChanged;

  const GuideLanguagePage({
    Key? key,
    this.onChanged,
  }) : super(key: key);

  @override
  State<GuideLanguagePage> createState() => _GuideLanguagePageState();
}

class _GuideLanguagePageState extends State<GuideLanguagePage> with AutomaticKeepAliveClientMixin {
  LangProvider? langProvider;

  bool load = false;

  List languages = [];

  @override
  bool get wantKeepAlive => true;

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
    widget.onChanged!();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<TranslationProvider>(
        builder: (BuildContext context, data, Widget? child) {
          return ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    FlutterI18n.translate(context, "app.setting.language.title"),
                    style: const TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (load)
                    ELuiLoadComponent(
                      type: "line",
                      lineWidth: 1,
                      color: Theme.of(context).textTheme.subtitle1!.color!,
                      size: 16,
                    ),
                ],
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
