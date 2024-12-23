import 'package:bfban/utils/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_rte/flutter_rte.dart';

import '../../pages/media/Insert.dart';

class RichEditCore extends StatefulWidget {
  final String? data;

  final bool? expandFullHeight;

  const RichEditCore({
    super.key,
    this.data = "",
    this.expandFullHeight = true,
  });

  @override
  State<RichEditCore> createState() => RichEditCoreState();
}

class RichEditCoreState extends State<RichEditCore> {
  late HtmlEditorController controller;

  late FocusNode myFocusNode;

  String controllerContent = "";

  bool isHtmlEditVisible = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 1)).then((v) {
      setState(() {
        isHtmlEditVisible = true;
        controller.setFocus();
      });
    });
  }

  @override
  void didChangeDependencies() {
    String initialText = widget.data.toString().replaceAll("<br>", "\n");
    controller = HtmlEditorController(
      processNewLineAsBr: false,
      processOutputHtml: true,
      toolbarOptions: HtmlToolbarOptions(
        toolbarPosition: ToolbarPosition.custom,
        toolbarType: ToolbarType.nativeScrollable,
        buttonColor: Theme.of(context).colorScheme.primaryContainer,
        backgroundColor: Theme.of(context).primaryColor,
        gridViewHorizontalSpacing: 0,
        gridViewVerticalSpacing: 3,
        separatorWidget: VerticalDivider(),
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
          // const InsertButtons(link: true),
          OtherButtons(),
        ],
      ),
      editorOptions: HtmlEditorOptions(
        initialText: initialText,
        shouldEnsureVisible: true,
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
        onInit: () {
          controllerContent = widget.data.toString();
        },
        onChangeContent: (value) {
          controllerContent = value.toString().replaceAll("<br></p>", "</p><br>");
        },
      ),
    );
    controller.toolbarOptions.fixedToolbar = true;
    controller.toolbarOptions.customButtonGroups = [
      CustomButtonGroup(
        index: 2,
        buttons: [
          CustomToolbarButton(
            icon: Icons.link,
            action: () => _openUrlPage(),
            isSelected: false,
          ),
          CustomToolbarButton(
            icon: Icons.file_present,
            action: () => _openMediaPage(),
            isSelected: false,
          ),
        ],
      ),
    ];

    super.didChangeDependencies();
  }

  /// [Event]
  /// 插入链接
  void _openUrlPage() async {
    var proceed = await controller.toolbarOptions.onButtonPressed?.call(ButtonType.link, null, null) ?? true;
    if (proceed) {
      await controller.removeLink();

      final text = TextEditingController(text: "");
      final url = TextEditingController(text: "");
      final urlFocus = FocusNode();
      final formKey = GlobalKey<FormState>();
      var openNewTab = false;

      if (!mounted) return;
      showModalBottomSheet<void>(
        context: context,
        useSafeArea: true,
        isDismissible: true,
        isScrollControlled: false,
        showDragHandle: true,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              body: ListView(
                padding: EdgeInsets.all(20),
                children: [
                  Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: url,
                          focusNode: urlFocus,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.link),
                            border: OutlineInputBorder(),
                            hintText: 'http(s)://',
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r"^(https?://)?[^\s]+")),
                          ],
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a URL!';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Spacer(),
                      TextButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            var proceed = controller.toolbarOptions.linkInsertInterceptor?.call(text.text.isEmpty ? url.text : text.text, url.text, openNewTab) ?? true;
                            if (proceed.toString().isNotEmpty) {
                              controller.insertLink(
                                text.text.isEmpty ? url.text : text.text,
                                url.text,
                                openNewTab,
                              );
                            }
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text(FlutterI18n.translate(context, "basic.button.insert")),
                      )
                    ],
                  ),
                ),
              ),
            );
          });
        },
      );
    }
  }

  /// [Event]
  /// 打开媒体插入
  void _openMediaPage() {
    Future filterModal = showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isDismissible: true,
      isScrollControlled: false,
      showDragHandle: true,
      builder: (context) {
        return InsertMediaPage();
      },
    );

    filterModal.then((fileName) {
      if (fileName != null) {
        controller.insertHtml("<img src='$fileName'/>");
        controller.insertLink('(file)', fileName, false);
      }
      return fileName;
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
          child: AnimatedOpacity(
            opacity: isHtmlEditVisible ? 1 : 0,
            duration: Duration(milliseconds: 250),
            child: Visibility(
              visible: isHtmlEditVisible,
              maintainState: true,
              child: HtmlEditor(
                expandFullHeight: widget.expandFullHeight!,
                controller: controller,
              ),
            ),
          ),
        ),
        const Divider(height: 1),
        ToolbarWidget(
          controller: controller,
        ),
      ],
    );
  }
}
