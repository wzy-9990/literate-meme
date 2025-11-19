import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

/// 打电话工具类
class PhoneCallUtil {
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
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _launchPhoneCall(phoneNumber);
            },
            child: const Text('拨打'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('取消'),
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

  /// 格式化电话号码显示
  ///
  /// 例如：13812345678 -> 138 1234 5678
  static String formatPhoneNumber(String phoneNumber) {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[\s-()]'), '');

    if (cleanNumber.length == 11) {
      // 中国手机号格式：138 1234 5678
      return '${cleanNumber.substring(0, 3)} ${cleanNumber.substring(3, 7)} ${cleanNumber.substring(7)}';
    } else if (cleanNumber.length == 10) {
      // 其他格式：(123) 456-7890
      return '(${cleanNumber.substring(0, 3)}) ${cleanNumber.substring(3, 6)}-${cleanNumber.substring(6)}';
    } else {
      return phoneNumber;
    }
  }
}
