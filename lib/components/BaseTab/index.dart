import 'package:flutter/material.dart';
import 'package:flutter_tem/components/BaseInkWell/index.dart';
import 'package:flutter_tem/config/styles/colors.dart';

/// 基础 Tab 组件
/// 支持自定义选中/未选中样式，外部管理选中状态
class BaseTab extends StatelessWidget {
  const BaseTab({
    required this.options,
    required this.value,
    required this.onChanged,
    super.key,
    this.labelField = 'label',
    this.valueField = 'value',
    this.selectedTextStyle,
    this.unselectedTextStyle,
    this.selectedColor,
    this.unselectedColor,
    this.indicatorColor,
    this.indicatorHeight = 2,
    this.spacing = 16,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
    this.alignment = MainAxisAlignment.start,
    this.sticky = false,
  });

  /// 选项列表（BaseTabItem 或 Map，Map 需包含 label/value）
  final List<dynamic> options;

  /// Map 字段名
  final String labelField;
  final String valueField;

  /// 当前选中值
  final dynamic value;

  /// 选中回调
  final ValueChanged<dynamic> onChanged;

  /// 文字样式
  final TextStyle? selectedTextStyle;
  final TextStyle? unselectedTextStyle;

  /// 文字颜色（优先于 TextStyle 的 color）
  final Color? selectedColor;
  final Color? unselectedColor;

  /// 指示器颜色与高度
  final Color? indicatorColor;
  final double indicatorHeight;

  /// Tab 之间的间距与整体 padding
  final double spacing;
  final EdgeInsetsGeometry padding;

  /// 对齐方式
  final MainAxisAlignment alignment;

  /// 是否吸顶（仅提供包裹容器，具体由外部实现）
  final bool sticky;

  @override
  Widget build(BuildContext context) {
    final Color selectedClr =
        selectedColor ?? Theme.of(context).colorScheme.primary;
    final Color unselectedClr = unselectedColor ?? AppColors.textSecondary;
    final Color indicatorClr = indicatorColor ?? selectedClr;

    final parsed = options.map<_TabItemWrap>((opt) {
      if (opt is BaseTabItem) {
        return _TabItemWrap(
            label: opt.label,
            value: opt.value,
            raw: {'label': opt.label, 'value': opt.value});
      }
      if (opt is Map && opt[valueField] != null) {
        return _TabItemWrap(
          label: opt[labelField]?.toString() ?? '',
          value: opt[valueField],
          raw: Map<String, dynamic>.from(opt),
        );
      }
      throw ArgumentError('options 需为 BaseTabItem 或包含 label/value 的 Map');
    }).toList();

    final bool isExpandedLayout = alignment == MainAxisAlignment.spaceEvenly ||
        alignment == MainAxisAlignment.spaceAround ||
        alignment == MainAxisAlignment.spaceBetween ||
        alignment == MainAxisAlignment.center;

    final rowChildren = parsed.asMap().entries.map((entry) {
      final item = entry.value;
      final selected = item.value == value;
      final textStyle = (selected ? selectedTextStyle : unselectedTextStyle) ??
          TextStyle(
            color: selected ? selectedClr : unselectedClr,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          );

      final tabCore = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BaseInkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: () => onChanged(item.value),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Center(child: Text(item.label, style: textStyle)),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.only(top: 4),
            height: indicatorHeight,
            width: selected ? 20 : 0,
            decoration: BoxDecoration(
              color: selected ? indicatorClr : Colors.transparent,
              borderRadius: BorderRadius.circular(indicatorHeight),
            ),
          ),
        ],
      );

      if (isExpandedLayout) {
        return Expanded(child: tabCore);
      }

      return Padding(
        padding: EdgeInsets.only(
            right: entry.key == parsed.length - 1 ? 0 : spacing),
        child: tabCore,
      );
    }).toList();

    Widget row = Row(
      mainAxisAlignment: alignment,
      children: rowChildren,
    );

    // 非平分时允许横向滚动展示
    if (!isExpandedLayout) {
      row = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: row,
      );
    }

    return Padding(
      padding: padding,
      child: row,
    );
  }
}

class BaseTabItem {
  final String label;
  final dynamic value;

  const BaseTabItem({required this.label, required this.value});
}

class _TabItemWrap {
  final String label;
  final dynamic value;
  final Map<String, dynamic>? raw;

  _TabItemWrap({required this.label, required this.value, this.raw});
}
