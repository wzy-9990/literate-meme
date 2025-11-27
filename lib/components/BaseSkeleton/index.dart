import 'package:flutter/material.dart';
import 'package:skeleton_text/skeleton_text.dart';

/// 通用骨架屏组件
///
/// 基于 skeleton_text 封装，默认渲染一块可配置圆角的灰色占位。
/// 可搭配 [BaseSkeletonList] 快速生成多行骨架。
class BaseSkeleton extends StatelessWidget {
  const BaseSkeleton({
    super.key,
    this.height = 40,
    this.width,
    this.color,
    this.borderRadius = const BorderRadius.all(Radius.circular(15)),
    this.margin,
  });

  /// 高度（默认 40）
  final double height;

  /// 宽度（不传则自适应父级）
  final double? width;

  /// 占位颜色（默认灰色）
  final Color? color;

  /// 圆角（默认 15）
  final BorderRadiusGeometry borderRadius;

  /// 外边距
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final placeholderColor = color ?? Colors.grey[300]!;
    return Container(
      margin: margin,
      height: height,
      width: width,
      decoration: BoxDecoration(borderRadius: borderRadius),
      child: SkeletonAnimation(
        child: Container(
          decoration: BoxDecoration(
            color: placeholderColor,
            borderRadius: borderRadius,
          ),
        ),
      ),
    );
  }
}

/// 快速生成多行骨架列表
class BaseSkeletonList extends StatelessWidget {
  const BaseSkeletonList({
    super.key,
    this.itemCount = 3,
    this.itemHeight = 14,
    this.itemWidth,
    this.spacing = 12,
    this.color,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.padding = EdgeInsets.zero,
  });

  final int itemCount;
  final double itemHeight;
  final double? itemWidth;
  final double spacing;
  final Color? color;
  final BorderRadiusGeometry borderRadius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(itemCount, (index) {
          return Padding(
            padding:
                EdgeInsets.only(bottom: index == itemCount - 1 ? 0 : spacing),
            child: BaseSkeleton(
              height: itemHeight,
              width: itemWidth,
              color: color,
              borderRadius: borderRadius,
            ),
          );
        }),
      ),
    );
  }
}
