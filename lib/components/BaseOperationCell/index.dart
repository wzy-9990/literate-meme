import 'package:flutter/material.dart';
import 'package:flutter_tem/components/BaseInkWell/index.dart';

/// 操作单元格
///
/// - 支持输入模式与选择模式（整行可点，带水波纹）
/// - 左侧文案可自定义样式、必填星标
/// - 右侧输入框/选择结果可自定义样式，选择模式可自定义箭头
/// - 配合列表使用时可关闭底部分割线（用于最后一个）
class BaseOperationCell extends StatelessWidget {
  const BaseOperationCell({
    super.key,
    required this.label,
    this.required = false,
    this.labelStyle,
    this.requiredStyle,
    this.borderRadius,
    this.mode = BaseOperationCellMode.input,
    this.controller,
    this.hintText,
    this.onChanged,
    this.keyboardType,
    this.enabled = true,
    this.valueTextStyle,
    this.hintTextStyle,
    this.value,
    this.onSelect,
    this.arrowIcon,
    this.arrowIconData,
    this.arrowIconSize,
    this.arrowIconColor,
    this.valueMaxLines,
    this.labelMaxLines = 20,
    this.labelMaxWidth = 120,
    this.labelMinWidth = 120,
    this.rightWidget,
    this.contentPadding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.showBottomDivider = true,
    this.dividerIndent = 0,
    this.backgroundColor = Colors.white,
    this.maxLines = 1,
    this.textInputAction,
  });

  /// 左侧标题
  final String label;

  /// 是否必填（展示红色星标）
  final bool required;

  /// 标题样式
  final TextStyle? labelStyle;

  /// 星标样式
  final TextStyle? requiredStyle;

  /// 单元格圆角
  final BorderRadius? borderRadius;

  /// 展示模式：输入/选择
  final BaseOperationCellMode mode;

  /// 输入模式使用的 controller
  final TextEditingController? controller;

  /// 输入/选择时的占位提示
  final String? hintText;

  /// 输入回调
  final ValueChanged<String>? onChanged;

  /// 键盘类型
  final TextInputType? keyboardType;

  /// 是否可编辑
  final bool enabled;

  /// 选择模式下的展示文案
  final String? value;

  /// 选择模式点击回调
  final VoidCallback? onSelect;

  /// 选择模式右侧箭头（默认 chevron）
  final Widget? arrowIcon;

  /// 右侧箭头图标（仅选择模式，优先级低于 arrowIcon）
  final IconData? arrowIconData;

  /// 右侧箭头大小
  final double? arrowIconSize;

  /// 右侧箭头颜色
  final Color? arrowIconColor;

  /// 右侧文案最大行数（选择模式）
  final int? valueMaxLines;

  /// 左侧 label 最大行数
  final int labelMaxLines;

  /// 左侧 label 最大宽度
  final double labelMaxWidth;

  /// 左侧 label 最小宽度
  final double labelMinWidth;

  /// 自定义右侧内容（传入则覆盖默认输入/选择区域）
  final Widget? rightWidget;

  /// 右侧文案样式（输入文本或选择结果）
  final TextStyle? valueTextStyle;

  /// 右侧占位样式
  final TextStyle? hintTextStyle;

  /// 内边距
  final EdgeInsets contentPadding;

  /// 是否展示底部分割线
  final bool showBottomDivider;

  /// 分割线缩进
  final double dividerIndent;

  /// 背景色
  final Color backgroundColor;

  /// 输入最大行数
  final int? maxLines;

  /// 键盘动作为 TextInputAction
  final TextInputAction? textInputAction;

  bool get _isSelectMode => mode == BaseOperationCellMode.select;
  bool get _isInteractiveSelect => _isSelectMode && enabled && onSelect != null;

  @override
  Widget build(BuildContext context) {
    final labelTextStyle =
        labelStyle ?? const TextStyle(fontSize: 14, color: Colors.black87);
    final reqStyle = requiredStyle ??
        const TextStyle(fontSize: 14, color: Colors.red, height: 1.1);
    final valueStyle =
        valueTextStyle ?? const TextStyle(fontSize: 14, color: Colors.black87);
    final hintStyle = hintTextStyle ??
        const TextStyle(fontSize: 14, color: Colors.grey, height: 1.2);
    final effectiveHint =
        hintText ?? (_isSelectMode ? '请选择$label' : '请输入$label');

    final body = _buildBody(
        labelTextStyle, reqStyle, valueStyle, hintStyle, effectiveHint);

    return BaseInkWell(
      enableRipple: _isInteractiveSelect,
      onTap: _isInteractiveSelect ? onSelect : null,
      borderRadius: borderRadius,
      backgroundColor: backgroundColor,
      child: body,
    );
  }

  Widget _buildLabel(TextStyle style, TextStyle reqStyle) {
    return ConstrainedBox(
      constraints:
          BoxConstraints(maxWidth: labelMaxWidth, minWidth: labelMinWidth),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              label,
              style: style,
              maxLines: labelMaxLines,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          ),
          if (required) ...[
            const SizedBox(width: 2),
            Text('*', style: reqStyle),
          ],
        ],
      ),
    );
  }

  Widget _buildInput(
      TextStyle valueStyle, TextStyle hintStyle, String effectiveHint) {
    return TextField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      style: valueStyle,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        isCollapsed: true,
        border: InputBorder.none,
        hintText: effectiveHint,
        hintStyle: hintStyle,
        contentPadding: EdgeInsets.zero,
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildSelect(
      TextStyle valueStyle, TextStyle hintStyle, String effectiveHint) {
    final bool hasValue = (value ?? '').isNotEmpty;
    final int? maxLinesToUse = valueMaxLines;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Text(
            hasValue ? value! : effectiveHint,
            textAlign: TextAlign.right,
            style: hasValue ? valueStyle : hintStyle,
            maxLines: maxLinesToUse,
            overflow: maxLinesToUse == null
                ? TextOverflow.visible
                : TextOverflow.ellipsis,
            softWrap: true,
          ),
        ),
        const SizedBox(width: 2),
        if (_isInteractiveSelect)
          arrowIcon ??
              Icon(
                arrowIconData ?? Icons.chevron_right,
                size: arrowIconSize ?? 18,
                color: arrowIconColor ?? Colors.grey.shade500,
              ),
      ],
    );
  }

  Widget _buildBody(
    TextStyle labelTextStyle,
    TextStyle reqStyle,
    TextStyle valueStyle,
    TextStyle hintStyle,
    String effectiveHint,
  ) {
    Widget buildRight() {
      if (rightWidget != null) {
        return rightWidget!;
      }
      return _isSelectMode
          ? _buildSelect(valueStyle, hintStyle, effectiveHint)
          : _buildInput(valueStyle, hintStyle, effectiveHint);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: contentPadding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLabel(labelTextStyle, reqStyle),
              const SizedBox(width: 12),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: buildRight(),
                ),
              ),
            ],
          ),
        ),
        if (showBottomDivider)
          Divider(
            height: 1,
            thickness: 0.6,
            indent: dividerIndent,
            color: Colors.grey.shade300,
          ),
      ],
    );
  }
}

enum BaseOperationCellMode { input, select }

/// 一组操作单元格，自动处理首尾圆角和分割线
class BaseOperationCellGroup extends StatelessWidget {
  const BaseOperationCellGroup({
    super.key,
    required this.children,
    this.radius = 12,
    this.backgroundColor = Colors.white,
    this.padding = EdgeInsets.zero,
    this.dividerIndent,
  }) : assert(children.length > 0, 'children 不能为空');

  final List<BaseOperationCell> children;
  final double radius;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final double? dividerIndent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Column(
        children: List.generate(children.length, (index) {
          final child = children[index];
          final isFirst = index == 0;
          final isLast = index == children.length - 1;

          final BorderRadius effectiveRadius = child.borderRadius ??
              BorderRadius.only(
                topLeft: Radius.circular(isFirst ? radius : 0),
                topRight: Radius.circular(isFirst ? radius : 0),
                bottomLeft: Radius.circular(isLast ? radius : 0),
                bottomRight: Radius.circular(isLast ? radius : 0),
              );

          final bool showDivider = child.showBottomDivider && !isLast;

          return BaseOperationCell(
            label: child.label,
            required: child.required,
            labelStyle: child.labelStyle,
            requiredStyle: child.requiredStyle,
            borderRadius: effectiveRadius,
            mode: child.mode,
            controller: child.controller,
            hintText: child.hintText,
            onChanged: child.onChanged,
            keyboardType: child.keyboardType,
            enabled: child.enabled,
            valueTextStyle: child.valueTextStyle,
            hintTextStyle: child.hintTextStyle,
            value: child.value,
            onSelect: child.onSelect,
            arrowIcon: child.arrowIcon,
            arrowIconData: child.arrowIconData,
            arrowIconSize: child.arrowIconSize,
            arrowIconColor: child.arrowIconColor,
            rightWidget: child.rightWidget,
            valueMaxLines: child.valueMaxLines,
            contentPadding: child.contentPadding,
            showBottomDivider: showDivider,
            dividerIndent: dividerIndent ?? child.dividerIndent,
            backgroundColor: Colors.transparent, // 统一用 group 背景
            maxLines: child.maxLines,
            textInputAction: child.textInputAction,
          );
        }),
      ),
    );
  }
}
