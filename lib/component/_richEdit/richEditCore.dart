import 'package:bfban/utils/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_rte/flutter_rte.dart';

class RichEditCore extends StatefulWidget {
  String? data;

  bool? expandFullHeight;

  RichEditCore({
    Key? key,
    this.data = "",
    this.expandFullHeight = true,
  }) : super(key: key);

  @override
  State<RichEditCore> createState() => RichEditCoreState();
}

class RichEditCoreState extends State<RichEditCore> {
  final UrlUtil _urlUtil = UrlUtil();

  late HtmlEditorController controller;
  late FocusNode myFocusNode;

  String controllerContent = "";

  @override
  void didChangeDependencies() {
    controller = HtmlEditorController(
      toolbarOptions: HtmlToolbarOptions(
        toolbarPosition: ToolbarPosition.custom,
        toolbarType: ToolbarType.nativeGrid,
        gridViewHorizontalSpacing: 0,
        gridViewVerticalSpacing: 3,
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
          const InsertButtons(link: true),
        ],
        // backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      editorOptions: HtmlEditorOptions(
        initialText: widget.data ?? "",
        minHeight: 300,
        padding: const EdgeInsets.symmetric(horizontal: 0),
        hintStyle: TextStyle(
          color: Theme.of(context).textTheme.displayMedium!.color!.withOpacity(.5),
          fontWeight: FontWeight.normal,
        ),
        hint: FlutterI18n.translate(context, "app.richedit.placeholder"),
      ),
      stylingOptions: HtmlStylingOptions(
        textColorLight: Theme.of(context).textTheme.bodyMedium!.color!,
        textColorDark: Theme.of(context).textTheme.bodyMedium!.color!,
      ),
      callbacks: Callbacks(
        onChangeContent: (value) {
          controllerContent = value.toString();
        },
      ),
    );
    controller.toolbarOptions.fixedToolbar = true;
    controller.toolbarOptions.customButtonGroups = [
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

    Future.delayed(const Duration(seconds: 1)).then((value) {
      controller.setFocus();
    });
    super.didChangeDependencies();
  }

  /// [Event]
  /// 打开媒体插入
  void _openMediaPage() {
    _urlUtil.opEnPage(context, "/account/media/insert").then((value) {
      if (value.toString().isNotEmpty) {
        controller.insertLink(value, value, false);
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: HtmlEditor(
            expandFullHeight: widget.expandFullHeight! ?? false,
            controller: controller,
          ),
        ),
        const Divider(height: 1),
        Container(
          color: Theme.of(context).unselectedWidgetColor.withOpacity(.8),
          child: ToolbarWidget(
            controller: controller,
          ),
        ),
      ],
    );
  }
}
