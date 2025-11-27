import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// iOS 风格弹窗封装
/// 支持自定义标题/内容/按钮文字及样式，支持单/多按钮
class BaseCupertinoAlertDialog extends StatelessWidget {
  const BaseCupertinoAlertDialog({
    super.key,
    required this.title,
    this.subtitle,
    this.titleStyle,
    this.subtitleStyle,
    this.actions,
    this.cancelText = '取消',
    this.confirmText = '确定',
    this.cancelTextStyle,
    this.confirmTextStyle,
    this.onCancel,
    this.onConfirm,
  });

  /// 标题
  final String title;

  /// 副标题/内容
  final String? subtitle;

  /// 标题样式
  final TextStyle? titleStyle;

  /// 副标题样式
  final TextStyle? subtitleStyle;

  /// 按钮列表
  final List<BaseCupertinoAction>? actions;

  /// 默认左/右按钮文字 & 样式
  final String cancelText;
  final String confirmText;
  final TextStyle? cancelTextStyle;
  final TextStyle? confirmTextStyle;

  /// 默认左/右按钮回调
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final List<BaseCupertinoAction> mergedActions =
        (actions == null || actions!.isEmpty)
            ? [
                BaseCupertinoAction(
                  text: cancelText,
                  isCancel: true,
                  textStyle: cancelTextStyle ??
                      TextStyle(
                        color: CupertinoColors.systemGrey,
                        fontSize: 14.sp,
                      ),
                  onPressed: onCancel ??
                      () {
                        Navigator.of(context).pop();
                      },
                ),
                BaseCupertinoAction(
                  text: confirmText,
                  isDefault: true,
                  textStyle: confirmTextStyle ??
                      TextStyle(
                        color: primary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                  onPressed: onConfirm ??
                      () {
                        Navigator.of(context).pop();
                      },
                ),
              ]
            : actions!;

    return CupertinoAlertDialog(
      title: Text(
        title,
        style: titleStyle ?? TextStyle(fontSize: 16.sp),
      ),
      content: subtitle == null
          ? null
          : Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text(
                subtitle!,
                style: subtitleStyle ?? TextStyle(fontSize: 14.sp),
              ),
            ),
      actions: mergedActions
          .map(
            (a) => CupertinoDialogAction(
              isDefaultAction: a.isDefault,
              isDestructiveAction: a.isDestructive,
              onPressed: a.onPressed ??
                  () {
                    Navigator.of(context).pop();
                  },
              child: Text(
                a.text,
                style: a.textStyle ??
                    TextStyle(
                      color: a.isCancel
                          ? CupertinoColors.systemGrey
                          : CupertinoColors.activeBlue,
                      fontSize: 14.sp,
                    ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class BaseCupertinoAction {
  final String text;
  final VoidCallback? onPressed;
  final bool isDefault;
  final bool isDestructive;
  final TextStyle? textStyle;
  final bool isCancel;

  const BaseCupertinoAction({
    required this.text,
    this.onPressed,
    this.isDefault = false,
    this.isDestructive = false,
    this.textStyle,
    this.isCancel = false,
  });
}

/// 便捷方法：展示弹窗
Future<T?> showBaseCupertinoAlertDialog<T>(
  BuildContext context, {
  required String title,
  String? subtitle,
  TextStyle? titleStyle,
  TextStyle? subtitleStyle,
  List<BaseCupertinoAction>? actions,
  String cancelText = '取消',
  String confirmText = '确定',
  TextStyle? cancelTextStyle,
  TextStyle? confirmTextStyle,
  VoidCallback? onCancel,
  VoidCallback? onConfirm,
}) {
  return showCupertinoDialog<T>(
    context: context,
    builder: (_) => BaseCupertinoAlertDialog(
      title: title,
      subtitle: subtitle,
      titleStyle: titleStyle,
      subtitleStyle: subtitleStyle,
      actions: actions,
      cancelText: cancelText,
      confirmText: confirmText,
      cancelTextStyle: cancelTextStyle,
      confirmTextStyle: confirmTextStyle,
      onCancel: onCancel,
      onConfirm: onConfirm,
    ),
  );
}
