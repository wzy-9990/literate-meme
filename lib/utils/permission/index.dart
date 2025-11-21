import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

/// 权限工具类
///
/// 提供统一的权限请求、检查、引导功能
///
/// ⚠️ Android 13+ (API 33+) 重要变更：
/// - Permission.storage (READ/WRITE_EXTERNAL_STORAGE) 已废弃
/// - 使用新的分段权限：
///   - Permission.photos - 访问图片和照片
///   - Permission.videos - 访问视频
///   - Permission.audio - 访问音频文件
///   - Permission.manageExternalStorage - 管理所有文件（需特殊审核）
///
/// 📝 建议：
/// - 优先使用应用专属目录（getApplicationDocumentsDirectory），无需权限
/// - 只在需要访问媒体库或共享存储时才请求相应权限
/// - 避免使用 manageExternalStorage，除非确实需要访问所有文件
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
      case Permission.videos:
        return '视频';
      case Permission.audio:
        return '音频';
      case Permission.manageExternalStorage:
        return '文件管理';
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
      case Permission.calendarWriteOnly:
        return '日历（写入）';
      case Permission.calendarFullAccess:
        return '日历（读写）';
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
      try {
        final result = await permission.request();
        // 移除权限提示（如果存在）
        _tipOverlayEntry?.remove();
        _tipOverlayEntry = null;
        return result.isGranted || result.isLimited;
      } catch (e) {
        // 移除权限提示（如果存在）
        _tipOverlayEntry?.remove();
        _tipOverlayEntry = null;
        rethrow;
      }
    }

    if (status.isPermanentlyDenied) {
      // 移除权限提示（如果存在）
      _tipOverlayEntry?.remove();
      _tipOverlayEntry = null;

      await _showPermissionDeniedDialog(
        permissionType: getPermissionName(permission),
      );
      return false;
    }

    // 移除权限提示（如果存在）
    _tipOverlayEntry?.remove();
    _tipOverlayEntry = null;

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
      try {
        final result = await permission.request();

        // 移除权限提示
        _tipOverlayEntry?.remove();
        _tipOverlayEntry = null;

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
      } catch (e) {
        // 移除权限提示
        _tipOverlayEntry?.remove();
        _tipOverlayEntry = null;
        rethrow;
      }
    }

    if (status.isPermanentlyDenied && showDeniedDialog) {
      // 移除权限提示
      _tipOverlayEntry?.remove();
      _tipOverlayEntry = null;

      await _showPermissionDeniedDialog(
        permissionType: getPermissionName(permission),
      );
      return false;
    }

    // 移除权限提示
    _tipOverlayEntry?.remove();
    _tipOverlayEntry = null;

    return false;
  }

  /// 显示权限用途提示（顶部悬浮）
  static OverlayEntry? _tipOverlayEntry;

  static void _showPermissionTip({
    required String permissionType,
    required String message,
  }) {
    if (Platform.isAndroid) {
      // 移除之前的提示（如果存在）
      _tipOverlayEntry?.remove();
      _tipOverlayEntry = null;

      // 创建新的 OverlayEntry
      final overlayContext = Get.overlayContext;
      if (overlayContext != null) {
        _tipOverlayEntry = OverlayEntry(
          builder: (context) => Positioned(
            top: MediaQuery.of(context).padding.top + 10.w,
            left: 20.w,
            right: 20.w,
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: () => _tipOverlayEntry?.remove(),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.r, vertical: 10.r),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$permissionType权限使用说明',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(height: 2.w),
                      Text(
                        message,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        Overlay.of(overlayContext).insert(_tipOverlayEntry!);
      }
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

    // 统一使用 iOS 风格的弹窗
    return Get.dialog(
      CupertinoAlertDialog(
        title: Text('需要$permissionType权限'),
        content: Text(guidanceText),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
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
  ///
  /// Android 13+ (API 33+) 需要使用新的媒体权限
  /// 根据 Android 版本自动选择合适的权限
  static Future<bool> requestStorage({String? tip}) async {
    if (Platform.isAndroid) {
      // Android 13+ 使用新的媒体权限（photos 包含图片访问）
      // 对于一般的文件保存，建议使用应用专属目录，不需要权限
      // 如果需要访问媒体文件，使用 photos/videos/audio 权限
      return requestPermissionWithTip(
        Permission.photos,
        tipMessage: tip ?? '需要访问相册以保存图片',
      );
    } else if (Platform.isIOS) {
      return requestPermissionWithTip(
        Permission.photos,
        tipMessage: tip ?? '需要访问相册以保存图片',
      );
    }

    return false;
  }

  /// 通知权限快捷方法
  static Future<bool> requestNotification({String? tip}) async {
    return requestPermissionWithTip(
      Permission.notification,
      tipMessage: tip ?? '需要通知权限以接收消息提醒',
    );
  }

  /// 视频权限快捷方法（Android 13+）
  static Future<bool> requestVideos({String? tip}) async {
    return requestPermissionWithTip(
      Permission.videos,
      tipMessage: tip ?? '需要访问视频以保存或选择视频',
    );
  }

  /// 音频权限快捷方法（Android 13+）
  static Future<bool> requestAudio({String? tip}) async {
    return requestPermissionWithTip(
      Permission.audio,
      tipMessage: tip ?? '需要访问音频文件',
    );
  }

  /// 管理外部存储权限（慎用，需要 Google Play 审核）
  ///
  /// Android 11+ 如果需要访问所有文件，需要此权限
  /// 注意：Google Play 对此权限有严格审核要求
  static Future<bool> requestManageExternalStorage({String? tip}) async {
    if (Platform.isAndroid) {
      return requestPermissionWithTip(
        Permission.manageExternalStorage,
        tipMessage: tip ?? '需要管理所有文件的权限',
      );
    }
    return false;
  }

  /// 请求媒体库权限（照片+视频）
  ///
  /// 适用于需要同时访问照片和视频的场景
  static Future<Map<Permission, bool>> requestMediaLibrary({
    String? tip,
  }) async {
    final permissions = [Permission.photos, Permission.videos];
    final results = <Permission, bool>{};

    // 显示权限用途说明
    if (tip != null && tip.isNotEmpty) {
      _showPermissionTip(
        permissionType: '媒体库',
        message: tip,
      );
    }

    for (final permission in permissions) {
      final status = await permission.status;
      if (status.isGranted || status.isLimited) {
        results[permission] = true;
      } else if (status.isDenied) {
        final result = await permission.request();
        results[permission] = result.isGranted || result.isLimited;
      } else {
        results[permission] = false;
      }
    }

    // 移除权限提示
    _tipOverlayEntry?.remove();
    _tipOverlayEntry = null;

    return results;
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
