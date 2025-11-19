import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

/// 权限工具类
///
/// 提供统一的权限请求、检查、引导功能
class PermissionUtil {
  /// 根据 Permission 返回中文名称
  static String getPermissionName(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return '相机';
      case Permission.photos:
        return '相册';
      case Permission.storage:
        return '存储';
      case Permission.microphone:
        return '麦克风';
      case Permission.location:
        return '位置信息';
      case Permission.locationWhenInUse:
        return '位置信息（使用期间）';
      case Permission.locationAlways:
        return '位置信息（始终）';
      case Permission.notification:
        return '通知';
      case Permission.contacts:
        return '通讯录';
      case Permission.phone:
        return '电话';
      case Permission.sms:
        return '短信';
      case Permission.calendar:
        return '日历';
      case Permission.bluetooth:
        return '蓝牙';
      case Permission.bluetoothScan:
        return '蓝牙扫描';
      case Permission.bluetoothConnect:
        return '蓝牙连接';
      case Permission.bluetoothAdvertise:
        return '蓝牙广播';
      default:
        return '相关';
    }
  }

  /// 检查权限状态
  static Future<PermissionStatus> checkPermission(Permission permission) async {
    return await permission.status;
  }

  /// 检查并请求权限（简单版）
  ///
  /// 返回：true-已授权，false-未授权
  static Future<bool> requestPermission(Permission permission) async {
    final status = await permission.status;

    if (status.isGranted || status.isLimited) {
      return true;
    }

    if (status.isDenied) {
      final result = await permission.request();
      return result.isGranted || result.isLimited;
    }

    if (status.isPermanentlyDenied) {
      await _showPermissionDeniedDialog(
        permissionType: getPermissionName(permission),
      );
      return false;
    }

    return false;
  }

  /// 检查并请求权限（带提示版）
  ///
  /// [permission] 需要请求的权限
  /// [tipMessage] 权限用途说明
  /// [showDeniedDialog] 是否显示永久拒绝弹窗，默认 true
  static Future<bool> requestPermissionWithTip(
    Permission permission, {
    String? tipMessage,
    bool showDeniedDialog = true,
  }) async {
    final status = await permission.status;

    if (status.isGranted || status.isLimited) {
      return true;
    }

    // 显示权限用途说明
    if (tipMessage != null && tipMessage.isNotEmpty) {
      _showPermissionTip(
        permissionType: getPermissionName(permission),
        message: tipMessage,
      );
    }

    if (status.isDenied) {
      final result = await permission.request();

      // 如果请求后仍然被拒绝，检查是否需要引导用户去设置
      if (!result.isGranted && !result.isLimited) {
        // 在 iOS 上，如果用户之前拒绝过，系统可能不会再弹窗
        // 此时需要引导用户去设置中手动开启
        if (Platform.isIOS && showDeniedDialog) {
          final newStatus = await permission.status;
          // 如果状态仍然是 denied（说明系统没有弹窗或用户再次拒绝）
          if (newStatus.isDenied || newStatus.isPermanentlyDenied) {
            await _showPermissionDeniedDialog(
              permissionType: getPermissionName(permission),
            );
          }
        }
        return false;
      }

      return result.isGranted || result.isLimited;
    }

    if (status.isPermanentlyDenied && showDeniedDialog) {
      await _showPermissionDeniedDialog(
        permissionType: getPermissionName(permission),
      );
      return false;
    }

    return false;
  }

  /// 显示权限用途提示（顶部悬浮）
  static void _showPermissionTip({
    required String permissionType,
    required String message,
  }) {
    if (Platform.isAndroid) {
      EasyLoading.showToast(
        '$permissionType权限说明\n$message',
        duration: const Duration(seconds: 3),
        toastPosition: EasyLoadingToastPosition.top,
      );
    }
  }

  /// 权限被拒绝弹窗（引导用户去设置）
  static Future<void> _showPermissionDeniedDialog({
    required String permissionType,
  }) async {
    // 根据平台显示不同的引导文案
    final String guidanceText = Platform.isIOS
        ? '请在设置中启用$permissionType权限：\n设置 > Flutter Tem > $permissionType'
        : '请在设置中启用$permissionType权限以继续使用此功能';

    return Get.dialog(
      AlertDialog(
        title: Text('需要$permissionType权限'),
        content: Text(guidanceText),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: const Text('去设置'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// 批量请求权限
  ///
  /// 返回：Map<Permission, bool>
  static Future<Map<Permission, bool>> requestMultiplePermissions(
    List<Permission> permissions,
  ) async {
    final Map<Permission, bool> results = {};

    for (final permission in permissions) {
      final granted = await requestPermission(permission);
      results[permission] = granted;
    }

    return results;
  }

  /// 检查权限并执行回调
  ///
  /// [permission] 需要检查的权限
  /// [onGranted] 权限已授予时的回调
  /// [onDenied] 权限被拒绝时的回调（可选）
  static Future<void> checkAndExecute(
    Permission permission, {
    required VoidCallback onGranted,
    VoidCallback? onDenied,
    String? tipMessage,
  }) async {
    final granted = tipMessage != null
        ? await requestPermissionWithTip(permission, tipMessage: tipMessage)
        : await requestPermission(permission);

    if (granted) {
      onGranted();
    } else {
      onDenied?.call();
    }
  }

  /// 相机权限快捷方法
  static Future<bool> requestCamera({String? tip}) async {
    return requestPermissionWithTip(
      Permission.camera,
      tipMessage: tip ?? '需要访问相机以拍摄照片',
    );
  }

  /// 相册权限快捷方法
  static Future<bool> requestPhotos({String? tip}) async {
    return requestPermissionWithTip(
      Permission.photos,
      tipMessage: tip ?? '需要访问相册以选择照片',
    );
  }

  /// 位置权限快捷方法
  static Future<bool> requestLocation({String? tip}) async {
    return requestPermissionWithTip(
      Permission.location,
      tipMessage: tip ?? '需要访问位置信息以提供更好的服务',
    );
  }

  /// 麦克风权限快捷方法
  static Future<bool> requestMicrophone({String? tip}) async {
    return requestPermissionWithTip(
      Permission.microphone,
      tipMessage: tip ?? '需要访问麦克风以录制音频',
    );
  }

  /// 存储权限快捷方法
  static Future<bool> requestStorage({String? tip}) async {
    return requestPermissionWithTip(
      Permission.storage,
      tipMessage: tip ?? '需要访问存储以保存文件',
    );
  }

  /// 通知权限快捷方法
  static Future<bool> requestNotification({String? tip}) async {
    return requestPermissionWithTip(
      Permission.notification,
      tipMessage: tip ?? '需要通知权限以接收消息提醒',
    );
  }

  /// 调试权限状态（用于排查问题）
  static Future<void> debugPermissionStatus(Permission permission) async {
    final status = await permission.status;
    final permissionName = getPermissionName(permission);

    debugPrint('========== 权限调试信息 ==========');
    debugPrint('权限类型: $permissionName');
    debugPrint('当前状态: $status');
    debugPrint('isGranted: ${status.isGranted}');
    debugPrint('isDenied: ${status.isDenied}');
    debugPrint('isPermanentlyDenied: ${status.isPermanentlyDenied}');
    debugPrint('isLimited: ${status.isLimited}');
    debugPrint('isRestricted: ${status.isRestricted}');
    debugPrint('===============================');
  }
}
