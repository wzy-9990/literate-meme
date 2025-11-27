import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tem/config/styles/index.dart';

/// 基础水波纹组件
///
/// 提供可自定义的点击水波纹效果
///
/// 使用示例：
/// ```dart
/// BaseInkWell(
///   onTap: () => debugPrint('点击'),
///   child: Text('点我有水波纹'),
/// )
/// ```
class BaseInkWell extends StatelessWidget {
  /// 子组件
  final Widget child;

  /// 点击回调
  final VoidCallback? onTap;

  /// 长按回调
  final VoidCallback? onLongPress;

  /// 双击回调
  final VoidCallback? onDoubleTap;

  /// 圆角半径
  /// 默认为 null（方形，无圆角）
  final BorderRadius? borderRadius;

  /// 是否启用水波纹效果
  /// 默认为 true
  final bool enableRipple;

  /// 水波纹颜色
  /// 默认为黑色 6% 透明度
  final Color? splashColor;

  /// 高亮颜色（按下时的颜色）
  /// 默认为透明
  final Color? highlightColor;

  /// 内边距
  final EdgeInsetsGeometry? padding;

  /// 外边距
  final EdgeInsetsGeometry? margin;

  /// 背景颜色
  /// 默认为透明
  final Color? backgroundColor;

  /// 是否填充父组件
  /// 默认为 false
  final bool expand;

  const BaseInkWell({
    required this.child,
    super.key,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.borderRadius,
    this.enableRipple = true,
    this.splashColor,
    this.highlightColor,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.expand = false,
  });

  /// 快捷构造函数 - 圆角卡片样式
  BaseInkWell.card({
    required this.child,
    super.key,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.enableRipple = true,
    this.splashColor,
    this.highlightColor,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.expand = false,
  }) : borderRadius = BorderRadius.all(Radius.circular(AppRadius.card.r));

  /// 快捷构造函数 - 圆形样式
  BaseInkWell.circle({
    required this.child,
    super.key,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.enableRipple = true,
    this.splashColor,
    this.highlightColor,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.expand = false,
  }) : borderRadius = BorderRadius.all(Radius.circular(AppRadius.circle.r));

  @override
  Widget build(BuildContext context) {
    // 默认圆角为 0（方形）
    final BorderRadius effectiveBorderRadius =
        borderRadius ?? BorderRadius.circular(0.r);

    // 默认水波纹颜色为黑色 6% 透明度
    final Color effectiveSplashColor =
        splashColor ?? Colors.black.withOpacity(0.06);

    // 默认高亮颜色为透明
    final Color effectiveHighlightColor = highlightColor ?? Colors.transparent;

    // 默认背景颜色为透明
    final Color effectiveBackgroundColor =
        backgroundColor ?? Colors.transparent;

    Widget inkWellWidget = Material(
      color: effectiveBackgroundColor,
      borderRadius: effectiveBorderRadius,
      child: InkWell(
        borderRadius: effectiveBorderRadius,
        onTap: onTap,
        onLongPress: onLongPress,
        onDoubleTap: onDoubleTap,
        splashColor: enableRipple ? effectiveSplashColor : Colors.transparent,
        highlightColor:
            enableRipple ? effectiveHighlightColor : Colors.transparent,
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );

    // 如果需要填充父组件
    if (expand) {
      inkWellWidget = SizedBox.expand(child: inkWellWidget);
    }

    // 如果有外边距，包裹 Container
    if (margin != null) {
      inkWellWidget = Container(
        margin: margin,
        child: inkWellWidget,
      );
    }

    return inkWellWidget;
  }
}
