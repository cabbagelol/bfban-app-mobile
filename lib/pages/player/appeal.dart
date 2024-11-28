import 'package:bfban/component/_loading/index.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/elui.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../../component/_customReply/customReply.dart';
import '../../component/_html/html.dart';
import '../../constants/api.dart';
import '../../data/index.dart';
import '../../utils/index.dart';

class AppealPage extends StatefulWidget {
  final String? personaId;

  AppealPage({Key? key, this.personaId}) : super(key: key);

  @override
  State<AppealPage> createState() => _AppealPageState();
}

class _AppealPageState extends State<AppealPage> {
  final UrlUtil _urlUtil = UrlUtil();

  final Storage _storage = Storage();

  final GlobalKey<FormState> _appealFormKey = GlobalKey<FormState>();

  /// 作弊者参数
  PlayerStatus playerStatus = PlayerStatus(
    load: true,
    data: PlayerStatusData(),
    parame: PlayerParame(
      history: true,
      personaId: "",
    ),
  );

  AppealStatus appealStatus = AppealStatus(
    load: false,
    parame: AppealParame(
      toPlayerId: '',
      appealType: 'moss',
      content: '',
      extendedLinks: AppealParameExtendedLinks(mossDownloadUrl: ''),
    ),
  );

  List appealType = [
    {'name': 'detail.appeal.deal.moss', 'value': 'moss'},
    {'name': 'detail.appeal.deal.farm', 'value': 'farm'},
    {'name': 'detail.appeal.deal.other', 'value': 'none'}
  ];

  @override
  void initState() {
    playerStatus.parame!.dbId = widget.personaId!;
    _getCheatersInfo();

    super.initState();
  }

  /// [Response]
  /// 获取作弊玩家 档案
  Future _getCheatersInfo() async {
    setState(() {
      playerStatus.load = true;
    });

    Response result = await Http.request(
      Config.httpHost["cheaters"],
      parame: playerStatus.parame!.toMap,
      method: Http.GET,
    );

    if (result.data["success"] == 1) {
      final d = result.data["data"];

      setState(() {
        playerStatus.data!.setData(d);
      });
    } else {
      EluiMessageComponent.error(context)(
        child: Text(result.data.code),
      );
    }

    setState(() {
      playerStatus.load = false;
    });

    return playerStatus.data!.toMap;
  }

  /// [Response]
  /// 提交申诉
  Future _onAppeal() async {
    try {
      FormState? reportFormKey = _appealFormKey.currentState;
      bool validate = reportFormKey!.validate();

      if (!validate) return;
      reportFormKey.save();

      setState(() {
        appealStatus.load = true;
      });

      Response result = await Http.request(
        Config.httpHost["cheaters"],
        parame: playerStatus.parame!.toMap,
        method: Http.GET,
      );

      dynamic d = result.data;

      if (result.data["success"] == 1) {
        EluiMessageComponent.success(context)(
          child: Text(FlutterI18n.translate(
            context,
            "appStatusCode.${d["code"].replaceAll(".", "_")}",
            translationParams: {"message": d["message"] ?? ""},
          )),
        );
      }

      setState(() {
        appealStatus.load = false;
      });
    } catch (err) {
      EluiMessageComponent.error(context)(child: Text(err.toString()));
    }
  }

  /// [Event]
  /// 打开编辑页面
  _opEnRichEdit({updateValue}) async {
    await _storage.set("richedit", value: updateValue ?? appealStatus.parame!.content.toString());

    Map data = await _urlUtil.opEnPage(context, "/richedit", transition: TransitionType.cupertino);

    /// 按下确认储存富文本编写的内容
    if (data["code"] == 1) {
      return data["html"];
    }

    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "detail.appeal.dealAppeal")),
        actions: <Widget>[
          playerStatus.load
              ? ElevatedButton(
                  onPressed: () {},
                  child: LoadingWidget(
                    size: 20,
                    color: Theme.of(context).progressIndicatorTheme.color!,
                  ),
                )
              : IconButton(
            padding: const EdgeInsets.all(16),
                  icon: const Icon(Icons.done),
                  onPressed: () => _onAppeal(),
                ),
        ],
      ),
      body: ListView(
        children: [
          Form(
            key: _appealFormKey,
            child: Column(
              children: [
                EluiCellComponent(
                  title: FlutterI18n.translate(context, "detail.appeal.info.player"),
                  cont: Text(playerStatus.data!.id.toString()),
                ),
                EluiCellComponent(
                  title: FlutterI18n.translate(context, "detail.appeal.info.originName"),
                  cont: Text(playerStatus.data!.originName.toString()),
                ),

                const Divider(),

                /// 申诉类型
                Column(
                  children: [
                    EluiCellComponent(
                      title: FlutterI18n.translate(context, "detail.appeal.deal.type"),
                    ),
                    DropdownButton(
                      isDense: false,
                      isExpanded: true,
                      underline: const SizedBox(),
                      dropdownColor: Theme.of(context).bottomAppBarTheme.color,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      style: Theme.of(context).dropdownMenuTheme.textStyle,
                      onChanged: (value) {
                        setState(() {
                          appealStatus.parame!.appealType = value as String;
                        });
                      },
                      value: appealStatus.parame!.appealType,
                      items: appealType.map<DropdownMenuItem<String>>((i) {
                        return DropdownMenuItem(
                          value: i["value"].toString(),
                          child: Text(FlutterI18n.translate(context, i["name"])),
                        );
                      }).toList(),
                    )
                  ],
                ),

                const Divider(),

                /// 第一人称链接
                if (['moss'].contains(appealStatus.parame!.appealType))
                  FormField(
                    builder: (FormFieldState field) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        color: field.isValid ? Colors.transparent : Theme.of(context).colorScheme.error.withOpacity(.2),
                        child: Column(
                          children: [
                            EluiCellComponent(
                              title: FlutterI18n.translate(context, "detail.appeal.deal.firstPersonRecording"),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 10),
                              child: EluiInputComponent(
                                value: appealStatus.parame!.extendedLinks!.videoLink,
                                placeholder: FlutterI18n.translate(context, "detail.appeal.deal.firstPersonRecording"),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    autovalidateMode: AutovalidateMode.disabled,
                    initialValue: appealStatus.parame!.extendedLinks!.videoLink,
                    onSaved: (value) {
                      setState(() {
                        appealStatus.parame!.extendedLinks!.videoLink = value as String?;
                      });
                    },
                    validator: (value) {
                      if (['moss'].contains(appealStatus.parame!.appealType) && (value as String).isEmpty) return "";
                      return null;
                    },
                  ),

                /// btr链接
                if (['moss', 'farm'].contains(appealStatus.parame!.appealType))
                  FormField(
                    builder: (FormFieldState field) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        color: field.isValid ? Colors.transparent : Theme.of(context).colorScheme.error.withOpacity(.2),
                        child: Column(
                          children: [
                            EluiCellComponent(
                              title: FlutterI18n.translate(context, "detail.appeal.deal.btrLink"),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 10),
                              child: EluiInputComponent(
                                value: appealStatus.parame!.extendedLinks!.btrLink,
                                placeholder: FlutterI18n.translate(context, "detail.appeal.deal.btrLink"),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    autovalidateMode: AutovalidateMode.disabled,
                    initialValue: appealStatus.parame!.extendedLinks!.btrLink,
                    onSaved: (value) {
                      setState(() {
                        appealStatus.parame!.extendedLinks!.btrLink = value as String?;
                      });
                    },
                    validator: (value) {
                      if (['moss', 'farm'].contains(appealStatus.parame!.appealType) && (value as String).isEmpty) return "";
                      return null;
                    },
                  ),

                /// moss文件
                if (['moss'].contains(appealStatus.parame!.appealType))
                  FormField(
                    builder: (FormFieldState field) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        color: field.isValid ? Colors.transparent : Theme.of(context).colorScheme.error.withOpacity(.2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            EluiCellComponent(
                              title: FlutterI18n.translate(context, "detail.appeal.deal.userGeneratedMossFile"),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 15),
                              child: Card(
                                child: Center(
                                  heightFactor: 3,
                                  child: Icon(
                                    Icons.file_upload,
                                    size: FontSize.xxLarge.value,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      );
                    },
                    autovalidateMode: AutovalidateMode.disabled,
                    initialValue: appealStatus.parame!.extendedLinks!.mossDownloadUrl,
                    onSaved: (value) {
                      setState(() {
                        appealStatus.parame!.extendedLinks!.mossDownloadUrl = value as String?;
                      });
                    },
                    validator: (value) {
                      if (['moss'].contains(appealStatus.parame!.appealType) && (value as String).isEmpty) return "";
                      return null;
                    },
                  ),

                /// 理由
                if (['moss', 'farm', 'none'].contains(appealStatus.parame!.appealType))
                  FormField(
                    builder: (FormFieldState field) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        color: field.isValid ? Colors.transparent : Theme.of(context).colorScheme.error.withOpacity(.2),
                        child: Column(
                          children: [
                            EluiCellComponent(
                              title: FlutterI18n.translate(context, "report.labels.description"),
                              cont: field.isValid
                                  ? null
                                  : Icon(
                                      Icons.help,
                                      color: Theme.of(context).colorScheme.error,
                                      size: 15,
                                    ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 15),
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Card(
                                clipBehavior: Clip.hardEdge,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3),
                                  side: BorderSide(
                                    color: field.isValid ? Theme.of(context).dividerColor : Theme.of(context).colorScheme.error,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    InkWell(
                                      child: Container(
                                        constraints: const BoxConstraints(minHeight: 100),
                                        child: Opacity(
                                          opacity: field.value.isNotEmpty ? 1 : .5,
                                          child: HtmlCore(data: field.value.isNotEmpty ? field.value : FlutterI18n.translate(context, "app.richedit.placeholder")),
                                        ),
                                      ),
                                      onTap: () async {
                                        String html = await _opEnRichEdit(updateValue: field.value);
                                        field.didChange(html);
                                      },
                                    ),
                                    const Divider(height: 1),
                                    CustomReplyWidget(
                                      type: CustomReplyType.general,
                                      onChange: (String selectTemp) {
                                        setState(() {
                                          appealStatus.parame!.content = selectTemp;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    initialValue: appealStatus.parame!.content,
                    onSaved: (value) {
                      setState(() {
                        appealStatus.parame!.content = value as String?;
                      });
                    },
                    validator: (value) {
                      if (['moss', 'farm', 'none'].contains(appealStatus.parame!.appealType) && (value as String).isEmpty) return "";
                      if (value.toString().length < 0 && value.toString().length > 5000) return "";
                      if (value.toString().isEmpty) return "";
                      return null;
                    },
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
