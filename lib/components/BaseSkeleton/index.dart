import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    final double h = height.h;
    final double? w = width?.w;
    final EdgeInsetsGeometry? m = margin is EdgeInsets
        ? EdgeInsets.fromLTRB(
            (margin as EdgeInsets).left.w,
            (margin as EdgeInsets).top.h,
            (margin as EdgeInsets).right.w,
            (margin as EdgeInsets).bottom.h,
          )
        : margin;
    final BorderRadiusGeometry scaledRadius = borderRadius is BorderRadius
        ? BorderRadius.only(
            topLeft: (borderRadius as BorderRadius).topLeft * (1.r),
            topRight: (borderRadius as BorderRadius).topRight * (1.r),
            bottomLeft: (borderRadius as BorderRadius).bottomLeft * (1.r),
            bottomRight: (borderRadius as BorderRadius).bottomRight * (1.r),
          )
        : borderRadius;
    return Container(
      margin: m,
      height: h,
      width: w,
      decoration: BoxDecoration(borderRadius: scaledRadius),
      child: SkeletonAnimation(
        child: Container(
          decoration: BoxDecoration(
            color: placeholderColor,
            borderRadius: scaledRadius,
          ),
        ),
      ),
    );
  }
}
