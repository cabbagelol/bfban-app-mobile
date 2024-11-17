import 'package:bfban/component/_empty/index.dart';
import 'package:bfban/component/_loading/index.dart';
import 'package:flutter/material.dart';

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_elui_plugin/elui.dart';
import 'package:provider/provider.dart';

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
  TranslationProvider? langProvider;

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
    if (!mounted) return;
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
        languages = result.data["child"] ??= [];
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
    super.build(context);
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
                      style: const TextStyle(fontSize: 25),
                    ),
                    const SizedBox(width: 10),
                    if (load)
                      LoadingWidget(
                        color: Theme.of(context).progressIndicatorTheme.color!,
                        size: 16,
                      ),
                  ],
                ),
              ),

              if (load)
                EluiTipComponent(
                  type: EluiTip.warning,
                  child: Text(FlutterI18n.translate(context, "app.guide.language.waitDownloadHint")),
                ),

              // 语言列表
              if (languages.isNotEmpty)
                Column(
                  children: languages.map((lang) {
                    return RadioListTile<String>(
                      value: lang["fileName"].toString(),
                      onChanged: (value) {
                        setLanguage(context, value!);
                      },
                      groupValue: langProvider!.currentLang,
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
                )
              else
                const EmptyWidget()
            ],
          );
        },
      ),
    );
  }
}
