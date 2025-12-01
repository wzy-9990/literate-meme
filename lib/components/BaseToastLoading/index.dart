import 'package:flutter_easyloading/flutter_easyloading.dart';

/// Toast 和 Loading 统一管理组件
///
/// 使用引用计数管理 loading 状态，避免多个请求之间的冲突
/// 统一封装 EasyLoading，提供类型安全的 API
class BaseToastLoading {
  static int _loadingCount = 0;
  static EasyLoadingStatus? _currentStatus;

  /// 显示 loading（引用计数 +1）
  ///
  /// 多个请求并发时会共享一个 loading 显示
  /// ```dart
  /// BaseToastLoading.show();  // count = 1
  /// BaseToastLoading.show();  // count = 2
  /// BaseToastLoading.dismiss(); // count = 1，loading 仍显示
  /// BaseToastLoading.dismiss(); // count = 0，loading 关闭
  /// ```
  static void show({String? status}) {
    _loadingCount++;
    _currentStatus = EasyLoadingStatus.show;

    if (_loadingCount == 1) {
      // 只有第一个请求才真正显示 loading
      EasyLoading.show(status: status ?? '加载中...');
    }
  }

  /// 关闭 loading（引用计数 -1）
  ///
  /// 只有当所有请求都完成时（计数归零）才真正关闭 loading
  static void dismiss() {
    if (_loadingCount > 0) {
      _loadingCount--;
    }

    if (_loadingCount == 0 && _currentStatus == EasyLoadingStatus.show) {
      // 所有请求都完成了，关闭 loading
      EasyLoading.dismiss();
      _currentStatus = null;
    }
  }

  /// 只在当前显示的是 loading 时才关闭（不关闭 toast/success）
  ///
  /// 用于 API 拦截器等场景，避免意外关闭业务层的 toast
  static void dismissIfLoading() {
    if (_currentStatus == EasyLoadingStatus.show) {
      dismiss();
    }
  }

  /// 强制关闭所有 loading（慎用）
  ///
  /// 直接清空计数并关闭，可能导致其他请求的 loading 被意外关闭
  static void forceDissmiss() {
    _loadingCount = 0;
    _currentStatus = null;
    EasyLoading.dismiss();
  }

  /// 显示 Toast 提示
  ///
  /// 会重置 loading 状态，不受引用计数管理
  /// ```dart
  /// BaseToastLoading.showToast('操作成功');
  /// ```
  static void showToast(String msg) {
    _currentStatus = null; // Toast 不受 loading 计数管理
    EasyLoading.showToast(msg);
  }

  /// 显示成功提示
  ///
  /// 会重置 loading 状态，不受引用计数管理
  /// ```dart
  /// BaseToastLoading.showSuccess('保存成功');
  /// ```
  static void showSuccess(String msg) {
    _currentStatus = null;
    EasyLoading.showSuccess(msg);
  }

  /// 显示错误提示
  ///
  /// 会重置 loading 状态，不受引用计数管理
  /// ```dart
  /// BaseToastLoading.showError('操作失败');
  /// ```
  static void showError(String msg) {
    _currentStatus = null;
    EasyLoading.showError(msg);
  }

  /// 获取当前 loading 数量（用于调试）
  static int get loadingCount => _loadingCount;

  /// 是否正在显示 loading
  static bool get isLoading =>
      _loadingCount > 0 && _currentStatus == EasyLoadingStatus.show;
}
