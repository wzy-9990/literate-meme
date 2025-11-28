import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

/// 所有Logic的基类，提供通用功能
abstract class BaseLogic extends GetxController {
  /// 页面加载状态
  final RxBool isLoading = false.obs;

  /// 是否已初始化
  final RxBool isInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('${runtimeType} - onInit');
    initData();
  }

  @override
  void onReady() {
    super.onReady();
    debugPrint('${runtimeType} - onReady');
  }

  @override
  void onClose() {
    debugPrint('${runtimeType} - onClose');
    super.onClose();
  }

  /// 初始化数据，子类重写此方法
  void initData() {
    isInitialized.value = true;
  }

  /// 显示加载状态
  void showLoading([String? message]) {
    isLoading.value = true;
    if (message != null) {
      EasyLoading.show(status: message);
    }
  }

  /// 隐藏加载状态
  void hideLoading() {
    isLoading.value = false;
    EasyLoading.dismiss();
  }

  /// 显示成功提示
  void showSuccess(String message) {
    EasyLoading.showSuccess(message);
  }

  /// 显示错误提示
  void showError(String message) {
    EasyLoading.showError(message);
  }

  /// 显示Toast
  void showToast(String message) {
    EasyLoading.showToast(message);
  }

  /// 统一的错误处理
  void handleError(dynamic error, [String? customMessage]) {
    hideLoading();
    String errorMsg = customMessage ?? '操作失败，请稍后重试';

    if (error != null) {
      debugPrint('${runtimeType} - Error: $error');
      // 可以根据error类型做不同处理
      if (error is String) {
        errorMsg = error;
      }
    }

    showError(errorMsg);
  }

  /// 执行异步操作的通用方法
  Future<T?> executeAsync<T>(
    Future<T> Function() operation, {
    String? loadingMessage,
    String? successMessage,
    bool showLoadingIndicator = false,
    Function(T data)? onSuccess,
    Function(dynamic error)? onError,
  }) async {
    try {
      if (showLoadingIndicator) {
        showLoading(loadingMessage);
      }

      final result = await operation();

      if (showLoadingIndicator) {
        hideLoading();
      }

      if (successMessage != null) {
        showSuccess(successMessage);
      }

      onSuccess?.call(result);
      return result;
    } catch (error) {
      if (showLoadingIndicator) {
        hideLoading();
      }

      if (onError != null) {
        onError(error);
      } else {
        handleError(error);
      }
      return null;
    }
  }
}
