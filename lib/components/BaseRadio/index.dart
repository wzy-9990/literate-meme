import 'package:flutter/material.dart';
import 'package:flutter_tem/components/BaseButton/index.dart';
import 'package:flutter_tem/components/BaseInkWell/index.dart';
import 'package:flutter_tem/config/styles/colors.dart';
import 'package:flutter_tem/config/styles/radius.dart';

/// 单选项数据
class BaseRadioOption<T> {
  final String label;
  final T value;

  const BaseRadioOption({required this.label, required this.value});
}

/// 单选组
///
/// [asButton] 为 true 时使用 BaseButton 风格的按钮组；否则使用普通文字+圆点。
class BaseRadioGroup<T> extends StatelessWidget {
  /// 支持传入 BaseRadioOption<T> 或 Map（需包含 label/value）
  final List<dynamic> options;
  final T? value;

  /// 返回选中项的 value；若需要完整 item 请用 onChangedWithItem
  final ValueChanged<T>? onChanged;
  final ValueChanged<Map<String, dynamic>>? onChangedWithItem;
  final bool asButton;
  final double spacing;
  final double runSpacing;
  final String valueField;
  final String labelField;

  const BaseRadioGroup({
    super.key,
    required this.options,
    this.value,
    this.onChanged,
    this.onChangedWithItem,
    this.asButton = false,
    this.spacing = 12,
    this.runSpacing = 8,
    this.valueField = 'value',
    this.labelField = 'label',
  });

  @override
  Widget build(BuildContext context) {
    final parsedOptions = options.map<_OptionWrap<T>>((opt) {
      if (opt is BaseRadioOption<T>) {
        return _OptionWrap(
            option: opt, raw: {'label': opt.label, 'value': opt.value});
      }
      if (opt is Map && opt[valueField] != null) {
        return _OptionWrap(
          option: BaseRadioOption<T>(
            label: opt[labelField]?.toString() ?? '',
            value: opt[valueField] as T,
          ),
          raw: Map<String, dynamic>.from(opt),
        );
      }
      throw ArgumentError('options 需为 BaseRadioOption 或包含 label/value 的 Map');
    }).toList();

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: parsedOptions.map((opt) {
        final bool selected = opt.option.value == value;
        return asButton
            ? BaseButton(
                type: selected ? BaseButtonType.outline : BaseButtonType.info,
                text: opt.option.label,
                onTap: () {
                  onChanged?.call(opt.option.value);
                  if (onChangedWithItem != null && opt.raw != null) {
                    onChangedWithItem!(opt.raw!);
                  }
                },
              )
            : _RadioChip(
                label: opt.option.label,
                selected: selected,
                onTap: () {
                  onChanged?.call(opt.option.value);
                  if (onChangedWithItem != null && opt.raw != null) {
                    onChangedWithItem!(opt.raw!);
                  }
                },
              );
      }).toList(),
    );
  }
}

class _RadioChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _RadioChip({
    required this.label,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primary = AppColors.primary;
    return BaseInkWell(
      borderRadius: BorderRadius.circular(AppRadius.button),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? primary.withOpacity(0.1) : Colors.grey.shade200,
          border: Border.all(
            color: selected ? primary : Colors.transparent,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? primary : Colors.grey,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? primary : AppColors.textPrimary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionWrap<T> {
  final BaseRadioOption<T> option;
  final Map<String, dynamic>? raw;

  _OptionWrap({required this.option, this.raw});
}
