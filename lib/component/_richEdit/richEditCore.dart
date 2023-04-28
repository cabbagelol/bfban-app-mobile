import 'package:bfban/utils/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_rte/flutter_rte.dart';

class RichEditCore extends StatefulWidget {
  String? data;

  RichEditCore({
    Key? key,
    this.data = "",
  }) : super(key: key);

  @override
  State<RichEditCore> createState() => RichEditCoreState();
}

class RichEditCoreState extends State<RichEditCore> {
  final UrlUtil _urlUtil = UrlUtil();

  late HtmlEditorController controller;

  String controllerContent = "";

  @override
  void didChangeDependencies() {
    controller = HtmlEditorController(
      toolbarOptions: HtmlToolbarOptions(
        toolbarPosition: ToolbarPosition.custom,
        toolbarType: ToolbarType.nativeGrid,
        defaultToolbarButtons: [
          const ListButtons(listStyles: false),
          const FontButtons(
            bold: true,
            italic: false,
            underline: false,
            clearFormatting: false,
            strikethrough: false,
            superscript: false,
            subscript: false,
          ),
          const InsertButtons(),
        ],
        // backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      editorOptions: HtmlEditorOptions(
        hintStyle: TextStyle(color: Theme.of(context).textTheme.displayMedium!.color!.withOpacity(.5)),
        hint: FlutterI18n.translate(context, "app.richedit.placeholder"),
      ),
      stylingOptions: HtmlStylingOptions(
        textColorLight: Theme.of(context).textTheme.bodyMedium!.color!,
        textColorDark: Theme.of(context).textTheme.bodyMedium!.color!,
      ),
      callbacks: Callbacks(
        onChangeContent: (value) {
          if (value!.isEmpty) return;
          controllerContent = value.toString();
          logger.i(controllerContent);
        },
      ),
    );

    controller
      ..toolbarOptions.customButtonGroups = [
        CustomButtonGroup(
          index: 3,
          buttons: [
            CustomToolbarButton(
              icon: Icons.image,
              action: () => _openMediaPage(),
              isSelected: false,
            ),
          ],
        ),
      ];
    super.didChangeDependencies();
  }

  /// [Event]
  /// 打开媒体插入
  void _openMediaPage() {
    _urlUtil.opEnPage(context, "/account/media/insert").then((value) {
      if (value.toString().isNotEmpty) {
        logger.i(value);
        controller.insertLink(value, value, false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Theme.of(context).appBarTheme.backgroundColor!.withOpacity(.8),
          child: ToolbarWidget(
            controller: controller,
          ),
        ),
        Divider(height: 1),
        Expanded(
          child: HtmlEditor(
            minHeight: 300,
            expandFullHeight: true,
            initialValue: widget.data,
            controller: controller,
          ),
          flex: 1,
        ),
      ],
    );
  }
}
