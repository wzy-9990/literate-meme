import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tem/components/BaseInkWell/index.dart';
import 'package:flutter_tem/config/styles/colors.dart';
import 'package:flutter_tem/config/styles/radius.dart';

/// 基础按钮组件
///
/// 支持：主题/常规/文本/镂空/渐变，圆角可单独配置，内置点击节流（500ms）
class BaseButton extends StatelessWidget {
  static int _lastTapTs = 0;

  final BaseButtonType type;
  final Color? backgroundColor;
  final Color? borderColor;
  final List<Color>? gradientColors;
  final Alignment? gradientBegin;
  final Alignment? gradientEnd;
  final List<double>? gradientStops;
  final double borderWidth;
  final double width;
  final double height;
  final VoidCallback? onTap;
  final String text;
  final double fontSize;
  final Color? textColor;
  final FontWeight fontWeight;
  final Widget? child;
  final double topLeftRadius;
  final double topRightRadius;
  final double bottomLeftRadius;
  final double bottomRightRadius;
  final bool enableRipple;
  final Color? splashColor;

  const BaseButton({
    super.key,
    this.type = BaseButtonType.primary,
    this.backgroundColor,
    this.borderColor,
    this.gradientColors,
    this.gradientBegin,
    this.gradientEnd,
    this.gradientStops,
    this.borderWidth = 1,
    this.width = 80,
    this.height = 40,
    this.onTap,
    this.text = '按钮',
    this.fontSize = 14,
    this.textColor,
    this.fontWeight = FontWeight.w500,
    this.child,
    this.enableRipple = true,
    this.splashColor,
    double borderRadius = AppRadius.button,
    double? topLeftRadius,
    double? topRightRadius,
    double? bottomLeftRadius,
    double? bottomRightRadius,
  })  : topLeftRadius = topLeftRadius ?? borderRadius,
        topRightRadius = topRightRadius ?? borderRadius,
        bottomLeftRadius = bottomLeftRadius ?? borderRadius,
        bottomRightRadius = bottomRightRadius ?? borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = _resolveColors();
    final size = _resolveSize();
    final decoration = _buildDecoration(colors);
    final rippleColor = _resolveRippleColor();

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: decoration,
        child: BaseInkWell(
          borderRadius: _borderRadius,
          backgroundColor: Colors.transparent,
          onTap: _handleTap,
          enableRipple: enableRipple,
          splashColor: rippleColor,
          highlightColor: Colors.transparent,
          child: Container(
            width: size.width.w,
            height: size.height.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(borderRadius: _borderRadius),
            child: child ?? _buildText(colors.border),
          ),
        ),
      ),
    );
  }

  void _handleTap() {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastTapTs > 500) {
      _lastTapTs = now;
      onTap?.call();
    }
  }

  BorderRadius get _borderRadius => BorderRadius.only(
        topLeft: Radius.circular(topLeftRadius.w),
        topRight: Radius.circular(topRightRadius.w),
        bottomLeft: Radius.circular(bottomLeftRadius.w),
        bottomRight: Radius.circular(bottomRightRadius.w),
      );

  _ButtonColors _resolveColors() {
    const primaryColor = AppColors.primary;
    final border = borderColor ??
        (type == BaseButtonType.ghost ? AppColors.textSecondary : primaryColor);
    final bg = backgroundColor ?? primaryColor;
    return _ButtonColors(
      border: border,
      background: type == BaseButtonType.info ? Colors.grey.shade200 : bg,
      text: textColor,
    );
  }

  _ButtonSize _resolveSize() {
    if (type == BaseButtonType.normal || type == BaseButtonType.ghost) {
      return _ButtonSize(
        width: width - borderWidth * 2,
        height: height - borderWidth * 2,
      );
    }
    return _ButtonSize(width: width, height: height);
  }

  Color _resolveRippleColor() {
    if (splashColor != null) return splashColor!;
    if (type == BaseButtonType.normal || type == BaseButtonType.ghost) {
      return Colors.grey.withOpacity(0.5);
    }
    if (type == BaseButtonType.text) {
      return Colors.grey.withOpacity(0.3);
    }
    return Colors.white.withOpacity(0.5);
  }

  BoxDecoration _buildDecoration(_ButtonColors colors) {
    switch (type) {
      case BaseButtonType.primary:
        return BoxDecoration(
          color: colors.background,
          borderRadius: _borderRadius,
        );
      case BaseButtonType.info:
        return BoxDecoration(
          color: colors.background,
          borderRadius: _borderRadius,
        );
      case BaseButtonType.outline:
        return BoxDecoration(
          color: AppColors.primaryOpacity10,
          borderRadius: _borderRadius,
          border: Border.all(color: colors.border, width: borderWidth.w),
        );
      case BaseButtonType.gradient:
        return BoxDecoration(
          gradient: LinearGradient(
            begin: gradientBegin ?? const Alignment(-0.86, -0.51),
            end: gradientEnd ?? const Alignment(0.86, 0.51),
            colors: gradientColors ??
                const [
                  Color(0xFFFE6601),
                  Color(0xFFFEA801),
                ],
            stops: gradientStops ?? const [0.54, 1.0],
          ),
          borderRadius: _borderRadius,
        );
      case BaseButtonType.text:
        return const BoxDecoration();
      case BaseButtonType.normal:
        return BoxDecoration(
          color: const Color.fromRGBO(1, 1, 1, 0.001),
          borderRadius: _borderRadius,
          border: Border.all(color: colors.border, width: borderWidth.w),
        );
      case BaseButtonType.ghost:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: _borderRadius,
          border: Border.all(color: colors.border, width: borderWidth.w),
        );
    }
  }

  Widget _buildText(Color fallbackBorderColor) {
    Color colorToUse;
    if (textColor != null) {
      colorToUse = textColor!;
    } else if (type == BaseButtonType.text) {
      colorToUse = AppColors.textSecondary;
    } else if (type == BaseButtonType.normal ||
        type == BaseButtonType.outline ||
        type == BaseButtonType.ghost) {
      colorToUse = fallbackBorderColor;
    } else if (type == BaseButtonType.info) {
      colorToUse = AppColors.textPrimary;
    } else {
      colorToUse = Colors.white;
    }

    return Center(
      child: Text(
        text,
        style: TextStyle(
          height: 0.8,
          color: colorToUse,
          fontSize: fontSize.sp,
          fontWeight: fontWeight,
        ),
      ),
    );
  }
}

class _ButtonColors {
  final Color border;
  final Color background;
  final Color? text;

  _ButtonColors({
    required this.border,
    required this.background,
    required this.text,
  });
}

class _ButtonSize {
  final double width;
  final double height;

  _ButtonSize({required this.width, required this.height});
}

enum BaseButtonType {
  primary, // 主题
  info, // 信息色（灰底黑字）
  normal, // 常规
  ghost, // 边框+文字中性色
  text, // 文本
  outline, // 镂空
  gradient, // 渐变
}
