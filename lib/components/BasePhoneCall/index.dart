import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

/// 电话拨打组件
class BasePhoneCall extends StatelessWidget {
  /// 电话号码
  final String phoneNumber;

  /// 显示的文本
  final String? text;

  /// 文本样式
  final TextStyle? style;

  /// 按钮类型 (图标或文本)
  final BasePhoneCallType type;

  /// 图标
  final IconData? icon;

  /// 图标大小
  final double? iconSize;

  const BasePhoneCall({
    required this.phoneNumber,
    super.key,
    this.text,
    this.style,
    this.type = BasePhoneCallType.text,
    this.icon = Icons.phone,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[\s-()]'), '');
    final displayText = text ?? formatPhoneNumber(cleanNumber);

    switch (type) {
      case BasePhoneCallType.icon:
        return IconButton(
          icon: Icon(icon, size: (iconSize ?? 24).w),
          onPressed: () => _makePhoneCall(context, cleanNumber),
        );
      case BasePhoneCallType.text:
        return GestureDetector(
          onTap: () => _makePhoneCall(context, cleanNumber),
          child: Text(
            displayText,
            style: style ??
                TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                  fontSize: 14.sp,
                ),
          ),
        );
      case BasePhoneCallType.button:
        return ElevatedButton(
          onPressed: () => _makePhoneCall(context, cleanNumber),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: (iconSize ?? 20).w),
              SizedBox(width: 8.w),
              Text(
                displayText,
                style: TextStyle(fontSize: 14.sp),
              ),
            ],
          ),
        );
    }
  }

  /// 拨打电话
  ///
  /// [context] 上下文
  /// [phoneNumber] 电话号码
  ///
  /// iOS: 直接拨打电话
  /// Android: 显示底部弹窗，二次确认后拨打
  static Future<void> _makePhoneCall(
    BuildContext context,
    String phoneNumber,
  ) async {
    // 清理电话号码（去除空格、横线等）
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[\s-()]'), '');

    if (Platform.isIOS) {
      // iOS 直接拨打电话
      await _launchPhoneCall(cleanNumber);
    } else {
      // Android 显示底部弹窗
      _showPhoneCallDialog(context, cleanNumber);
    }
  }

  /// 显示拨打电话的底部弹窗（iOS 风格）
  static void _showPhoneCallDialog(
    BuildContext context,
    String phoneNumber,
  ) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('拨打电话'),
        message: Text(
          phoneNumber,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _launchPhoneCall(phoneNumber);
            },
            child: Text(
              '拨打',
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            '取消',
            style: TextStyle(fontSize: 14.sp),
          ),
        ),
      ),
    );
  }

  /// 启动拨号应用
  static Future<void> _launchPhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        throw '无法拨打电话: $phoneNumber';
      }
    } catch (e) {
      debugPrint('拨打电话失败: $e');
    }
  }

  /// 拨打电话
  ///
  /// [context] 上下文
  /// [phoneNumber] 电话号码
  ///
  /// iOS: 直接拨打电话
  /// Android: 显示底部弹窗，二次确认后拨打
  static Future<void> makePhoneCall(
    BuildContext context,
    String phoneNumber,
  ) async {
    _makePhoneCall(context, phoneNumber);
  }

  /// 格式化电话号码显示
  ///
  /// [phoneNumber] 原始电话号码
  /// [format] 是否格式化，默认 false（不格式化，保持原样）
  ///
  /// 不格式化：13812345678
  /// 格式化：138 1234 5678
  static String formatPhoneNumber(String phoneNumber, {bool format = false}) {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[\s-()]'), '');

    // 如果不需要格式化，直接返回清理后的号码
    if (!format) {
      return cleanNumber;
    }

    // 格式化模式
    if (cleanNumber.length == 11) {
      // 中国手机号格式：138 1234 5678
      return '${cleanNumber.substring(0, 3)} ${cleanNumber.substring(3, 7)} ${cleanNumber.substring(7)}';
    } else if (cleanNumber.length == 10) {
      // 其他格式：(123) 456 7890
      return '(${cleanNumber.substring(0, 3)}) ${cleanNumber.substring(3, 6)} ${cleanNumber.substring(6)}';
    } else {
      return cleanNumber;
    }
  }
}

/// 电话拨打组件类型
enum BasePhoneCallType {
  /// 文本类型
  text,

  /// 图标类型
  icon,

  /// 按钮类型
  button,
}
