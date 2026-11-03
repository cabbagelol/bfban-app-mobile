import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../../pages/media/Insert.dart';
import '../_html/html.dart';
import 'visual_editor_controller.dart';

/**
 * 纯 Flutter 原生可视化所见即所得富文本编辑器组件 (WYSIWYG)
 * 完全对齐 bfban_website/front/src/components/textarea/v2 功能规范
 * 彻底消除在输入区显示原始 HTML 标签的问题，所见即所得，支持内嵌到各表单卡片中
 */
class RichEditCore extends StatefulWidget {
  // 初始或绑定的 HTML 数据内容
  final String? data;

  // 是否占满全屏或卡片高度（全屏页面传 true，表单内嵌传 false）
  final bool expandFullHeight;

  // 最小显示高度（内嵌表单时生效）
  final double minHeight;

  // 最大字符限制
  final int maxlength;

  // 是否显示字数限制提示栏
  final bool showMaxlengthLabel;

  // 输入占位提示文案
  final String? placeholder;

  // 内容变动回调，输出标准 HTML
  final ValueChanged<String>? onChange;

  // 全屏展开按钮回调（若为空则不显示全屏按钮）
  final VoidCallback? onFullscreen;

  const RichEditCore({
    super.key,
    this.data = "",
    this.expandFullHeight = false,
    this.minHeight = 160.0,
    this.maxlength = 5000,
    this.showMaxlengthLabel = true,
    this.placeholder,
    this.onChange,
    this.onFullscreen,
  });

  @override
  State<RichEditCore> createState() => RichEditCoreState();
}

class RichEditCoreState extends State<RichEditCore> {
  // 可视化富文本控制器
  late VisualRichTextController controller;

  // 输入框焦点节点
  late FocusNode focusNode;

  // 是否处于实时渲染预览模式
  bool isPreviewMode = false;

  // 当前对外部提供的 HTML 文本 Getter
  String get controllerContent => controller.toHtml();

  @override
  void initState() {
    super.initState();
    controller = VisualRichTextController(initialHtml: widget.data ?? "");
    focusNode = FocusNode();

    controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant RichEditCore oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当外部传入数据更新且与当前内容不一致时（如选择快捷回复模板），自动同步到可视化模型
    if (widget.data != null &&
        widget.data != oldWidget.data &&
        widget.data != controller.toHtml()) {
      controller.setHtml(widget.data!);
    }
  }

  @override
  void dispose() {
    controller.removeListener(_onControllerChanged);
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (widget.onChange != null) {
      widget.onChange!(controller.toHtml());
    }
    setState(() {});
  }

  /**
   * 打开插入链接对话框
   */
  void _openLinkDialog() {
    TextSelection selection = controller.selection;
    String selectedText = "";
    if (selection.start >= 0 && selection.end > selection.start) {
      selectedText = controller.text.substring(selection.start, selection.end);
    }

    TextEditingController textCtrl = TextEditingController(text: selectedText);
    TextEditingController urlCtrl = TextEditingController(text: "https://");
    GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.link, size: 20),
              SizedBox(width: 8),
              Text("插入超链接", style: TextStyle(fontSize: 16)),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: textCtrl,
                  decoration: const InputDecoration(
                    labelText: "链接文本",
                    hintText: "显示文本",
                  ),
                  validator: (val) {
                    if (val == null || val
                        .trim()
                        .isEmpty) {
                      return "请输入显示文本";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: urlCtrl,
                  decoration: const InputDecoration(
                    labelText: "目标地址 (URL)",
                    hintText: "https://example.com",
                  ),
                  validator: (val) {
                    if (val == null || val
                        .trim()
                        .isEmpty) {
                      return "请输入链接地址";
                    }
                    if (!val.startsWith("http://") && !val.startsWith("https://")) {
                      return "必须以 http:// 或 https:// 开头";
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("取消"),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  controller.insertLink(textCtrl.text.trim(), urlCtrl.text.trim());
                  Navigator.pop(context);
                }
              },
              child: const Text("插入"),
            ),
          ],
        );
      },
    );
  }

  /**
   * 打开插入图片底部弹窗
   */
  void _openImageModal() {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.link),
                  title: const Text("输入图片网络地址"),
                  subtitle: const Text("直接插入在线图片 URL"),
                  onTap: () {
                    Navigator.pop(context);
                    _openImageUrlDialog();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.perm_media_outlined),
                  title: const Text("从媒体库或本地上传选择"),
                  subtitle: const Text("选择应用内存储或上传新图像"),
                  onTap: () {
                    Navigator.pop(context);
                    _openMediaLibraryPicker();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openImageUrlDialog() {
    TextEditingController urlCtrl = TextEditingController(text: "https://");
    GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("插入图片链接", style: TextStyle(fontSize: 16)),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: urlCtrl,
              decoration: const InputDecoration(
                labelText: "图片地址 (URL)",
                hintText: "https://...jpg/png",
              ),
              validator: (val) {
                if (val == null || val
                    .trim()
                    .isEmpty) {
                  return "请输入图片地址";
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("取消"),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  controller.addImage(urlCtrl.text.trim());
                  Navigator.pop(context);
                }
              },
              child: const Text("添加"),
            ),
          ],
        );
      },
    );
  }

  void _openMediaLibraryPicker() {
    Future filterModal = showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isDismissible: true,
      isScrollControlled: false,
      showDragHandle: true,
      builder: (context) {
        return const InsertMediaPage();
      },
    );

    filterModal.then((fileName) {
      if (fileName != null && fileName
          .toString()
          .isNotEmpty) {
        controller.addImage(fileName.toString());
      }
    });
  }

  /**
   * 打开常用表情选择弹窗
   */
  void _openEmoteModal() {
    final List<Map<String, String>> commonEmotes = [
      {"name": "smile", "char": "😊"},
      {"name": "joy", "char": "😂"},
      {"name": "grinning", "char": "😀"},
      {"name": "grin", "char": "😁"},
      {"name": "rolling-on-the-floor-laughing", "char": "🤣"},
      {"name": "sweat-smile", "char": "😅"},
      {"name": "laughing", "char": "😆"},
      {"name": "wink", "char": "😉"},
      {"name": "yum", "char": "😋"},
      {"name": "sunglasses", "char": "😎"},
      {"name": "heart-eyes", "char": "😍"},
      {"name": "kissing-heart", "char": "😘"},
      {"name": "thinking-face", "char": "🤔"},
      {"name": "neutral-face", "char": "😐"},
      {"name": "expressionless", "char": "😑"},
      {"name": "smirk", "char": "😏"},
      {"name": "unamused", "char": "😒"},
      {"name": "thumbsup", "char": "👍"},
      {"name": "thumbsdown", "char": "👎"},
      {"name": "clap", "char": "👏"},
      {"name": "pray", "char": "🙏"},
      {"name": "fire", "char": "🔥"},
      {"name": "100", "char": "💯"},
      {"name": "tada", "char": "🎉"},
      {"name": "heart", "char": "❤️"},
      {"name": "game", "char": "🎮"},
      {"name": "shield", "char": "🛡️"},
      {"name": "warning", "char": "⚠️"},
      {"name": "check", "char": "✅"},
      {"name": "cross", "char": "❌"},
    ];

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          height: 320,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text("选择常用表情",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: commonEmotes.length,
                  itemBuilder: (context, index) {
                    final item = commonEmotes[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        Navigator.pop(context);
                        controller.insertEmote(item['name']!);
                      },
                      child: Center(
                        child: Text(
                          item["char"]!,
                          style: const TextStyle(fontSize: 26),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /**
   * 打开缩语语法 (CS) 插入弹窗
   */
  void _openContractedSyntaxModal() {
    String selectedType = "player";
    TextEditingController valCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("插入缩语语法 (CS)", style: TextStyle(fontSize: 16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("选择语法类型：",
                      style: TextStyle(fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 6),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: selectedType,
                    items: const [
                      DropdownMenuItem(
                          value: "player", child: Text("玩家名片 {player:名称}")),
                      DropdownMenuItem(
                          value: "user", child: Text("@用户 {user:用户ID}")),
                      DropdownMenuItem(
                          value: "floor", child: Text("楼层跳转 {floor:楼层号}")),
                      DropdownMenuItem(
                          value: "router", child: Text("站内路由 {router:/路径}")),
                      DropdownMenuItem(
                          value: "privilege", child: Text("权限标识 {privilege:角色}")),
                      DropdownMenuItem(
                          value: "signature", child: Text("签名档图片 {signature:URL}")),
                      DropdownMenuItem(
                          value: "icon", child: Text("图标 {icon:名称}")),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedType = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: valCtrl,
                    decoration: InputDecoration(
                      labelText: "数值参数",
                      hintText: selectedType == "player"
                          ? "输入战地玩家ID"
                          : selectedType == "user"
                          ? "输入网站用户ID"
                          : selectedType == "router"
                          ? "/account/1"
                          : "参数内容",
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("取消"),
                ),
                FilledButton(
                  onPressed: () {
                    String value = valCtrl.text.trim();
                    if (value.isNotEmpty) {
                      controller.insertContractedSyntax(selectedType, value);
                    }
                    Navigator.pop(context);
                  },
                  child: const Text("插入"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required VoidCallback onPressed,
    String? tooltip,
    bool isActive = false,
    bool isEnabled = true,
  }) {
    Color? iconColor;
    if (!isEnabled) {
      iconColor = Theme
          .of(context)
          .disabledColor;
    } else if (isActive) {
      iconColor = Theme
          .of(context)
          .primaryColor;
    } else {
      iconColor = Theme
          .of(context)
          .iconTheme
          .color;
    }

    Widget button = InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: isEnabled ? onPressed : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? Theme
              .of(context)
              .primaryColor
              .withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip, child: button);
    }
    return button;
  }

  @override
  Widget build(BuildContext context) {
    int currentLength = controller
        .toHtml()
        .length;
    bool isOverLimit = currentLength > widget.maxlength;
    final SpanFormat currentFmt = controller.activeTypingFormat;

    Widget editorContentWidget = isPreviewMode
        ? Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      color: Theme
          .of(context)
          .cardTheme
          .color,
      child: controller
          .toHtml()
          .trim()
          .isEmpty
          ? Center(
        child: Text(
          "暂无预览内容",
          style: TextStyle(color: Theme
              .of(context)
              .disabledColor),
        ),
      )
          : ListView(
        shrinkWrap: !widget.expandFullHeight,
        physics: widget.expandFullHeight
            ? null
            : const NeverScrollableScrollPhysics(),
        children: [
          HtmlCore(
            data: controller.toHtml(),
            fontSize: 15,
          ),
        ],
      ),
    )
        : Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.expandFullHeight)
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                if (!focusNode.hasFocus) {
                  focusNode.requestFocus();
                }
              },
              child: Container(
                color: Theme
                    .of(context)
                    .cardTheme
                    .color,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  maxLines: null,
                  minLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  keyboardType: TextInputType.multiline,
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme
                        .of(context)
                        .textTheme
                        .bodyMedium
                        ?.color,
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: widget.placeholder ??
                        FlutterI18n.translate(context, "app.richedit.placeholder"),
                    hintStyle: TextStyle(
                      color: Theme
                          .of(context)
                          .textTheme
                          .displayMedium
                          ?.color
                          ?.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
            ),
          )
        else
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              if (!focusNode.hasFocus) {
                focusNode.requestFocus();
              }
            },
            child: Container(
              constraints: BoxConstraints(
                minHeight: widget.minHeight,
              ),
              color: Theme
                  .of(context)
                  .cardTheme
                  .color,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                maxLines: null,
                minLines: 4,
                expands: false,
                textAlignVertical: TextAlignVertical.top,
                keyboardType: TextInputType.multiline,
                style: TextStyle(
                  fontSize: 15,
                  color: Theme
                      .of(context)
                      .textTheme
                      .bodyMedium
                      ?.color,
                  height: 1.5,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  hintText: widget.placeholder ??
                      FlutterI18n.translate(context, "app.richedit.placeholder"),
                  hintStyle: TextStyle(
                    color: Theme
                        .of(context)
                        .textTheme
                        .displayMedium
                        ?.color
                        ?.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          ),

        // 附带图片可视化卡片列表
        if (controller.attachedImages.isNotEmpty) ...[
          const Divider(height: 1),
          Container(
            color: Theme
                .of(context)
                .cardTheme
                .color,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: controller.attachedImages.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final imgUrl = controller.attachedImages[index];
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        imgUrl,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(
                              width: 64,
                              height: 64,
                              color: Theme
                                  .of(context)
                                  .dividerColor,
                              child: const Icon(Icons.broken_image, size: 24),
                            ),
                      ),
                    ),
                    Positioned(
                      top: -4,
                      right: -4,
                      child: InkWell(
                        onTap: () => controller.removeImage(imgUrl),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(2),
                          child: const Icon(Icons.close,
                              size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ],
    );

    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize:
        widget.expandFullHeight ? MainAxisSize.max : MainAxisSize.min,
        children: [
          // 格式工具栏 (严格对齐 TipTap v2 工具栏排布)
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Theme
                  .of(context)
                  .bottomAppBarTheme
                  .color ??
                  Theme
                      .of(context)
                      .cardColor,
              border: Border(
                bottom: BorderSide(
                  color: Theme
                      .of(context)
                      .dividerColor
                      .withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              children: [
                // 撤销 / 重做
                _buildToolbarButton(
                  icon: Icons.undo,
                  tooltip: "撤销",
                  isEnabled: controller.canUndo,
                  onPressed: () => controller.undo(),
                ),
                _buildToolbarButton(
                  icon: Icons.redo,
                  tooltip: "重做",
                  isEnabled: controller.canRedo,
                  onPressed: () => controller.redo(),
                ),
                const VerticalDivider(width: 12, indent: 8, endIndent: 8),

                // 核心排版格式 (所见即所得，无 HTML 标签)
                _buildToolbarButton(
                  icon: Icons.format_bold,
                  tooltip: "加粗",
                  isActive: currentFmt.isBold,
                  onPressed: () => controller.toggleBold(),
                ),
                _buildToolbarButton(
                  icon: Icons.format_italic,
                  tooltip: "斜体",
                  isActive: currentFmt.isItalic,
                  onPressed: () => controller.toggleItalic(),
                ),
                _buildToolbarButton(
                  icon: Icons.format_underlined,
                  tooltip: "下划线",
                  isActive: currentFmt.isUnderline,
                  onPressed: () => controller.toggleUnderline(),
                ),
                _buildToolbarButton(
                  icon: Icons.format_strikethrough,
                  tooltip: "删除线",
                  isActive: currentFmt.isStrike,
                  onPressed: () => controller.toggleStrike(),
                ),
                const VerticalDivider(width: 12, indent: 8, endIndent: 8),

                // 列表与分割线
                _buildToolbarButton(
                  icon: Icons.format_list_bulleted,
                  tooltip: "无序列表",
                  onPressed: () => controller.toggleBulletList(),
                ),
                _buildToolbarButton(
                  icon: Icons.format_list_numbered,
                  tooltip: "有序列表",
                  onPressed: () => controller.toggleOrderedList(),
                ),
                _buildToolbarButton(
                  icon: Icons.horizontal_rule,
                  tooltip: "分割线",
                  onPressed: () => controller.insertHorizontalRule(),
                ),
                const VerticalDivider(width: 12, indent: 8, endIndent: 8),

                // 扩展插入组件
                _buildToolbarButton(
                  icon: Icons.link,
                  tooltip: "插入链接",
                  onPressed: _openLinkDialog,
                ),
                _buildToolbarButton(
                  icon: Icons.image_outlined,
                  tooltip: "插入图片",
                  onPressed: _openImageModal,
                ),
                _buildToolbarButton(
                  icon: Icons.emoji_emotions_outlined,
                  tooltip: "插入表情",
                  onPressed: _openEmoteModal,
                ),
                _buildToolbarButton(
                  icon: Icons.code,
                  tooltip: "缩语语法 (CS)",
                  onPressed: _openContractedSyntaxModal,
                ),
                const VerticalDivider(width: 12, indent: 8, endIndent: 8),

                // 预览与全屏模式切换
                _buildToolbarButton(
                  icon: isPreviewMode
                      ? Icons.edit_note
                      : Icons.visibility_outlined,
                  tooltip: isPreviewMode ? "返回可视化编辑" : "实时渲染预览",
                  isActive: isPreviewMode,
                  onPressed: () {
                    setState(() {
                      isPreviewMode = !isPreviewMode;
                    });
                  },
                ),
                if (widget.onFullscreen != null)
                  _buildToolbarButton(
                    icon: Icons.fullscreen,
                    tooltip: "全屏编辑",
                    onPressed: widget.onFullscreen!,
                  ),
              ],
            ),
          ),

          // 主体内容区（支持全屏自适应与表单内嵌自适应）
          if (widget.expandFullHeight)
            Expanded(child: editorContentWidget)
          else
            editorContentWidget,

          // 底部字数统计栏
          if (widget.showMaxlengthLabel) ...[
            const Divider(height: 1, thickness: 1),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              color: Theme
                  .of(context)
                  .scaffoldBackgroundColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (isPreviewMode)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color:
                        Theme
                            .of(context)
                            .primaryColor
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "预览模式",
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme
                              .of(context)
                              .primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    const SizedBox(),
                  Row(
                    children: [
                      Text(
                        "$currentLength",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isOverLimit
                              ? Colors.red
                              : currentLength > widget.maxlength * 0.8
                              ? Colors.orange
                              : Theme
                              .of(context)
                              .textTheme
                              .bodySmall
                              ?.color,
                        ),
                      ),
                      Text(
                        " / ${widget.maxlength}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme
                              .of(context)
                              .textTheme
                              .bodySmall
                              ?.color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
