import 'package:flutter/material.dart';

import 'rich_edit_core.dart';

/**
 * 富文本编辑器组件包裹类
 * 提供对齐 Web 端 TipTap v2 的纯 Flutter 可视化编辑能力，支持表单内嵌与独立卡片
 */
class RichEditWidget extends StatefulWidget {
  // 编辑器初始或绑定的 HTML 数据
  final String? data;

  // 是否占满全屏或卡片高度
  final bool expandFullHeight;

  // 最小显示高度（内嵌表单时生效）
  final double minHeight;

  // 最大字数限制
  final int maxlength;

  // 是否显示字数限制提示栏
  final bool showMaxlengthLabel;

  // 输入占位提示文案
  final String? placeholder;

  // 内容变动回调，输出标准 HTML
  final ValueChanged<String>? onChange;

  // 全屏展开编辑回调
  final VoidCallback? onFullscreen;

  const RichEditWidget({
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
  State<RichEditWidget> createState() => RichEditWidgetState();
}

class RichEditWidgetState extends State<RichEditWidget> {
  // 核心富文本编辑器 State Key
  final GlobalKey<RichEditCoreState> _coreKey = GlobalKey<RichEditCoreState>();

  /**
   * 获取当前编辑器生成的 HTML 内容
   */
  String get controllerContent =>
      _coreKey.currentState?.controllerContent ?? (widget.data ?? "");

  @override
  Widget build(BuildContext context) {
    return RichEditCore(
      key: _coreKey,
      data: widget.data,
      expandFullHeight: widget.expandFullHeight,
      minHeight: widget.minHeight,
      maxlength: widget.maxlength,
      showMaxlengthLabel: widget.showMaxlengthLabel,
      placeholder: widget.placeholder,
      onChange: widget.onChange,
      onFullscreen: widget.onFullscreen,
    );
  }
}
