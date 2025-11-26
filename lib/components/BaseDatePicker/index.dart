import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum BaseDatePickerMode { date, time, dateTime }

/// 统一日期/时间选择器封装（iOS风格）
Future<DateTime?> showBaseDatePicker(
  BuildContext context, {
  DateTime? initial,
  DateTime? min,
  DateTime? max,
  BaseDatePickerMode mode = BaseDatePickerMode.date,
  String title = '请选择',
  String cancelText = '取消',
  String confirmText = '完成',
  double scale = 1.0,
}) async {
  final now = DateTime.now();
  final DateTime init = initial ?? now;
  final DateTime minimumDate = min ?? DateTime(1970, 1, 1);
  final DateTime maximumDate = max ?? DateTime(2100, 12, 31);
  DateTime current = init;

  return showCupertinoModalPopup<DateTime>(
    context: context,
    builder: (_) {
      return Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PickerHeader(
              title: title,
              cancelText: cancelText,
              confirmText: confirmText,
              onCancel: () => Navigator.of(context).pop(),
              onConfirm: () => Navigator.of(context).pop(current),
            ),
            const Divider(height: 1),
            SizedBox(
              height: 250,
              child: Transform.scale(
                scale: scale,
                child: CupertinoTheme(
                  data: CupertinoTheme.of(context).copyWith(
                    primaryColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: CupertinoDatePicker(
                    initialDateTime: init,
                    minimumDate: minimumDate,
                    maximumDate: maximumDate,
                    mode: _convertMode(mode),
                    use24hFormat: true,
                    onDateTimeChanged: (dt) => current = dt,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

CupertinoDatePickerMode _convertMode(BaseDatePickerMode mode) {
  switch (mode) {
    case BaseDatePickerMode.time:
      return CupertinoDatePickerMode.time;
    case BaseDatePickerMode.dateTime:
      return CupertinoDatePickerMode.dateAndTime;
    case BaseDatePickerMode.date:
    default:
      return CupertinoDatePickerMode.date;
  }
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
    return Container(
      color: Colors.white,
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onConfirm,
            child: Text(
              confirmText,
              style: TextStyle(
                color: primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
