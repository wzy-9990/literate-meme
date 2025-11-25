import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// iOS 风格 Picker 选择器（单列）
/// 支持传入字典列表（默认字段 label/value），返回选中的 Map
Future<Map<String, dynamic>?> showBasePicker(
  BuildContext context, {
  required List<Map<String, dynamic>> options,
  String labelField = 'label',
  String valueField = 'value',
  int initialIndex = 0,
  String title = '请选择',
  String cancelText = '取消',
  String confirmText = '完成',
  TextStyle? itemTextStyle,
  TextStyle? selectedTextStyle,
}) {
  if (options.isEmpty) return Future.value(null);
  final safeIndex = initialIndex.clamp(0, options.length - 1);
  int currentIndex = safeIndex;
  final controller = FixedExtentScrollController(initialItem: safeIndex);

  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return SafeArea(
        child: Container(
          margin: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PickerHeader(
                title: title,
                cancelText: cancelText,
                confirmText: confirmText,
                onCancel: () => Navigator.of(context).pop(),
                onConfirm: () =>
                    Navigator.of(context).pop(options[currentIndex]),
              ),
              const Divider(height: 1),
              SizedBox(
                height: 220,
                child: CupertinoPicker(
                  scrollController: controller,
                  magnification: 1.05,
                  squeeze: 1.1,
                  useMagnifier: true,
                  itemExtent: 44,
                  onSelectedItemChanged: (index) {
                    currentIndex = index;
                  },
                  children: options
                      .map((e) => Center(
                            child: _PickerItem(
                              label: e[labelField]?.toString() ?? '',
                              textStyle: itemTextStyle ??
                                  const TextStyle(
                                      fontSize: 16, color: Colors.black87),
                              selectedTextStyle: selectedTextStyle ??
                                  const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _PickerHeader extends StatelessWidget {
  const _PickerHeader({
    required this.title,
    required this.cancelText,
    required this.confirmText,
    required this.onCancel,
    required this.onConfirm,
  });

  final String title;
  final String cancelText;
  final String confirmText;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onCancel,
            child: const Text(
              '取消',
              style: TextStyle(color: CupertinoColors.systemGrey),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onConfirm,
            child: Text(
              confirmText,
              style: TextStyle(color: primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _PickerItem extends StatelessWidget {
  const _PickerItem({
    required this.label,
    required this.textStyle,
    required this.selectedTextStyle,
  });

  final String label;
  final TextStyle textStyle;
  final TextStyle selectedTextStyle;

  @override
  Widget build(BuildContext context) {
    final selected =
        DefaultTextStyle.of(context).style.fontWeight == FontWeight.w600;
    return Text(
      label,
      style: selected ? selectedTextStyle : textStyle,
    );
  }
}
