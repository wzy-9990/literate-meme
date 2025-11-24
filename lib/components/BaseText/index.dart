import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tem/utils/modules/function/common.dart';

/// 统一的文本组件
///
/// - 默认对内容做空值处理：`CommonFunction.formaDataString`
/// - 金额模式：`formatAmount` + 动态字号（基准 20sp，长度越长越小）
class BaseText extends StatelessWidget {
  /// 要展示的内容
  final dynamic data;

  /// 是否按金额显示（自动格式化 + 动态字号）
  final bool isMoney;

  /// 金额模式的字体大小（作为基准，再按长度缩放）
  final double moneyBaseFontSize;

  /// 非金额场景是否也按长度自适应字号
  final bool autoFit;

  /// 透传 Text 相关属性
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final double? textScaleFactor;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;

  const BaseText(
    this.data, {
    super.key,
    this.isMoney = false,
    this.moneyBaseFontSize = 14,
    this.autoFit = false,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaleFactor,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  });

  @override
  Widget build(BuildContext context) {
    final String text = isMoney
        ? CommonFunction.formatAmount(data)
        : CommonFunction.formaDataString(data);

    TextStyle? effectiveStyle = style;
    if (isMoney) {
      final hasFontSize = style?.fontSize != null;
      final baseSize = style?.fontSize ?? moneyBaseFontSize;
      final adjustedSize =
          CommonFunction.getMoneyFontSize(baseSize, data).toDouble();
      final fontSize = hasFontSize ? adjustedSize : adjustedSize.sp;
      effectiveStyle =
          (style ?? const TextStyle()).copyWith(fontSize: fontSize);
    } else if (autoFit) {
      final baseSize = style?.fontSize ?? 14.sp;
      final adjustedSize =
          CommonFunction.getMoneyFontSize(baseSize, text).toDouble();
      effectiveStyle = (style ?? TextStyle(fontSize: baseSize))
          .copyWith(fontSize: adjustedSize);
    }

    return Text(
      text,
      style: effectiveStyle,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      // ignore: deprecated_member_use
      textScaleFactor: textScaleFactor,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
    );
  }
}
