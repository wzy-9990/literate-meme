import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tem/components/BaseButton/index.dart';
import 'package:flutter_tem/components/BaseInkWell/index.dart';
import 'package:flutter_tem/config/styles/colors.dart';
import 'package:flutter_tem/config/styles/radius.dart';

class BaseCheckboxOption<T> {
  final String label;
  final T value;

  const BaseCheckboxOption({required this.label, required this.value});
}

/// 多选组，支持按钮模式（BaseButton）或普通复选框模式
class BaseCheckboxGroup<T> extends StatelessWidget {
  /// 支持 BaseCheckboxOption<T> 或 Map（需包含 label/value）
  final List<dynamic> options;
  final List<T> values;
  final ValueChanged<List<T>>? onChanged;
  final ValueChanged<Map<String, dynamic>>? onChangedWithItem;
  final bool asButton;
  final double spacing;
  final double runSpacing;
  final String valueField;
  final String labelField;
  final BaseButtonType selectedButtonType;
  final BaseButtonType unselectedButtonType;
  final double? buttonWidth;
  final double? buttonHeight;
  final bool buttonEnableRipple;
  final double? buttonFontSize;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;
  final double iconSize;
  final bool iconOnly;
  final bool removeChipBorder;
  final bool disableInk;
  final bool showLabel;
  final BaseButton Function(
    bool selected,
    BaseCheckboxOption<T> option,
    Map<String, dynamic>? raw,
  )? buttonBuilder;

  const BaseCheckboxGroup({
    required this.options,
    super.key,
    this.values = const [],
    this.onChanged,
    this.onChangedWithItem,
    this.asButton = false,
    this.spacing = 12,
    this.runSpacing = 8,
    this.valueField = 'value',
    this.labelField = 'label',
    this.selectedButtonType = BaseButtonType.outline,
    this.unselectedButtonType = BaseButtonType.info,
    this.buttonWidth,
    this.buttonHeight,
    this.buttonEnableRipple = true,
    this.buttonFontSize,
    this.selectedTextColor,
    this.unselectedTextColor,
    this.iconSize = 18,
    this.iconOnly = false,
    this.removeChipBorder = false,
    this.disableInk = false,
    this.showLabel = true,
    this.buttonBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final parsedOptions = options.map<_CheckboxWrap<T>>((opt) {
      if (opt is BaseCheckboxOption<T>) {
        return _CheckboxWrap(
            option: opt, raw: {'label': opt.label, 'value': opt.value});
      }
      if (opt is Map && opt[valueField] != null) {
        return _CheckboxWrap(
          option: BaseCheckboxOption<T>(
            label: opt[labelField]?.toString() ?? '',
            value: opt[valueField] as T,
          ),
          raw: Map<String, dynamic>.from(opt),
        );
      }
      throw ArgumentError(
          'options 需为 BaseCheckboxOption 或包含 label/value 的 Map');
    }).toList();

    return Wrap(
      spacing: spacing.w,
      runSpacing: runSpacing.h,
      children: parsedOptions.map((opt) {
        final bool selected = values.contains(opt.option.value);
        return asButton
            ? (buttonBuilder != null
                ? buttonBuilder!(selected, opt.option, opt.raw)
                : BaseButton(
                    type: selected ? selectedButtonType : unselectedButtonType,
                    text: opt.option.label,
                    width: (buttonWidth ?? 80),
                    height: (buttonHeight ?? 40),
                    enableRipple: buttonEnableRipple,
                    fontSize: buttonFontSize ?? 14,
                    textColor:
                        selected ? selectedTextColor : unselectedTextColor,
                    onTap: () => _toggle(opt),
                  ))
            : _CheckboxChip(
                label: opt.option.label,
                selected: selected,
                iconSize: iconSize,
                removeBorder: removeChipBorder,
                disableInk: disableInk,
                iconOnly: iconOnly,
                showLabel: showLabel,
                onTap: () => _toggle(opt),
              );
      }).toList(),
    );
  }

  void _toggle(_CheckboxWrap<T> opt) {
    final current = [...values];
    if (current.contains(opt.option.value)) {
      current.remove(opt.option.value);
    } else {
      current.add(opt.option.value);
    }
    onChanged?.call(current);
    if (onChangedWithItem != null && opt.raw != null) {
      onChangedWithItem!(opt.raw!);
    }
  }
}

class _CheckboxChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final double iconSize;
  final bool iconOnly;
  final bool removeBorder;
  final bool disableInk;
  final bool showLabel;

  const _CheckboxChip({
    required this.label,
    required this.selected,
    required this.iconSize,
    required this.iconOnly,
    this.removeBorder = false,
    this.disableInk = false,
    this.showLabel = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primary = AppColors.primary;
    final bgColor = (removeBorder || iconOnly)
        ? Colors.transparent
        : (selected ? primary.withOpacity(0.1) : Colors.grey.shade200);
    final content = Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bgColor,
        border: removeBorder
            ? null
            : Border.all(
                color: selected ? primary : Colors.transparent,
                width: 1.w,
              ),
        borderRadius: BorderRadius.circular(AppRadius.button.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            selected ? Icons.check_box : Icons.check_box_outline_blank,
            size: iconSize.w,
            color: selected ? primary : Colors.grey,
          ),
          if (showLabel && !iconOnly) ...[
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                color: selected ? primary : AppColors.textPrimary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 14.sp,
              ),
            ),
          ],
        ],
      ),
    );

    if (disableInk) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        child: content,
      );
    }

    return BaseInkWell(
      borderRadius: BorderRadius.circular(AppRadius.button),
      onTap: onTap,
      backgroundColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: content,
    );
  }
}

class _CheckboxWrap<T> {
  final BaseCheckboxOption<T> option;
  final Map<String, dynamic>? raw;

  _CheckboxWrap({required this.option, this.raw});
}
