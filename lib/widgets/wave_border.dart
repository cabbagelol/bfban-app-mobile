import 'dart:async';
import 'package:flutter/material.dart';

class WaveBorder extends StatefulWidget {
  final Widget? child; // 子控件
  final int count; // 波纹圈数
  final double? width; // 波纹直径
  final double? maxWidth; // 波纹扩散后最大直径
  final Color borderColor; // 波纹边框颜色
  final double borderWidth; // 波纹粗细
  final Duration duration; // 波纹扩散动画时长（毫秒）

  const WaveBorder({
    Key? key,
    this.child,
    this.count = 1,
    this.width,
    this.maxWidth,
    this.borderColor = Colors.white,
    this.borderWidth = 1,
    this.duration = const Duration(milliseconds: 5000),
  }) : super(key: key);

  @override
  _WaveBorderState createState() => _WaveBorderState();
}

class _WaveBorderState extends State<WaveBorder> with TickerProviderStateMixin {
  final List<AnimationController> _controllerList = []; // 动画控制器数组
  List<Widget> children = []; // 子组件数组（所有波纹 + child）

  @override
  void initState() {
    super.initState();

    // 配置动画和子控件
    configAnimation();
  }

  configAnimation() {
    for (int i = 0; i < widget.count; i++) {
      // 动画控制器
      var controller = AnimationController(
        vsync: this,
        duration: widget.duration,
      );
      // 控制器放数组里方便销毁
      _controllerList.add(controller);

      // 波纹放大比例
      double endScale = widget.maxWidth! / widget.width!;

      // 放大动画
      var scaleAnimation = Tween(
        begin: 1.0,
        end: endScale,
      ).animate(controller);

      // 透明动画
      var opacityAnimation = Tween(
        begin: 1.0,
        end: 0.0,
      ).animate(controller);

      // 添加波纹组件
      children.add(_borderWidget(scaleAnimation, opacityAnimation));

      // 每道波纹动画间隔
      int interval = widget.duration.inMilliseconds ~/ widget.count;

      Future.delayed(Duration(milliseconds: i * interval), () {
        // 执行动画
        if (mounted) {
          controller.repeat();
        }
      });
    }

    // 添加子控件child
    if (widget.child != null) {
      children.add(widget.child!);
    }
  }

  @override
  void dispose() {
    // 销毁动画控制器
    for (var controller in _controllerList) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: children,
    );
  }

  Widget _borderWidget(Animation<double> scaleAnimation, Animation<double> opacityAnimation) {
    return ScaleTransition(
      alignment: Alignment.center,
      scale: scaleAnimation,
      child: FadeTransition(
        opacity: opacityAnimation,
        child: Container(
          width: widget.width,
          height: widget.width,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(widget.width! / 2),
            border: Border.all(color: widget.borderColor, width: widget.borderWidth),
          ),
        ),
      ),
    );
  }
}