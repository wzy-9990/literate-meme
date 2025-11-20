import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_tem/routers/app_routes.dart';
import 'package:flutter_tem/routers/index.dart';
import 'package:flutter_tem/utils/storage/index.dart';
import 'package:get/get.dart';

/// 认证对话框组件
/// 用于在用户未登录或登录过期时显示对话框，引导用户登录
class BaseAuthDialog {
  static bool _isShowingAuthDialog = false;

  /// 显示认证对话框
  ///
  /// [isExpired] 是否为登录过期状态，如果为 null 则自动检测
  static Future<Map<String, dynamic>?> showAuthDialog({bool? isExpired}) async {
    if (_isShowingAuthDialog) return null;
    _isShowingAuthDialog = true;

    // 如果没有传入 isExpired 参数，则自动检测
    final bool checkIsExpired = isExpired ?? await baseCheckAuthStatus();

    final completer = Completer<Map<String, dynamic>?>();

    showCupertinoDialog(
      context: Get.context!,
      builder: (_) {
        return CupertinoAlertDialog(
          title: Text(checkIsExpired ? '登录已过期' : '未登录'),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              checkIsExpired ? '您的登录身份已过期，请重新登录。' : '您还未登录，请先登录。',
            ),
          ),
          actions: [
            if (!checkIsExpired)
              CupertinoDialogAction(
                child: const Text('取消'),
                onPressed: () {
                  Navigator.pop(Get.context!);
                  _isShowingAuthDialog = false;
                  completer.complete(null);
                },
              ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('去登录'),
              onPressed: () async {
                Navigator.pop(Get.context!);
                _isShowingAuthDialog = false;

                // 跳转登录页并等待返回结果
                final res = await NavigationUtils.toNamed(AppRoutes.login);
                if (res != null && res is Map<String, dynamic>) {
                  completer.complete(res);
                } else {
                  completer.complete(null);
                }
              },
            ),
          ],
        );
      },
    );

    return completer.future;
  }

  /// 检查用户认证状态
  ///
  /// 返回 true 表示用户已登录但令牌过期，false 表示用户未登录
  static Future<bool> baseCheckAuthStatus() async {
    final token = await Storage.getString(StorageKeys.token);
    return token != null && token.isNotEmpty;
  }

  /// 获取用户认证状态枚举
  ///
  /// 返回 BaseAuthStatus 表示用户的当前认证状态
  static Future<BaseAuthStatus> baseGetAuthStatus() async {
    final token = await Storage.getString(StorageKeys.token);
    if (token != null && token.isNotEmpty) {
      return BaseAuthStatus.expired; // 有token但需要重新验证（过期）
    } else {
      return BaseAuthStatus.notLoggedIn; // 无token，未登录
    }
  }
}

/// 用户认证状态枚举
enum BaseAuthStatus {
  /// 用户未登录
  notLoggedIn,

  /// 用户登录已过期
  expired,

  /// 用户正常登录
  loggedIn,
}
