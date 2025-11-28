import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tem/page/index/logic.dart';
import 'package:get/get.dart';

/// 登录后自动刷新 Mixin
///
/// 使用方法：
/// ```dart
/// class MyPageLogic extends GetxController with AuthRefreshMixin {
///   @override
///   Future<void> onAuthRefresh() async {
///     // 登录后要执行的刷新逻辑
///     await loadData();
///   }
/// }
/// ```
mixin AuthRefreshMixin on GetxController {
  StreamSubscription<String>? _authTokenSub;
  bool _wasUnAuthed = false;

  /// 登录后自动刷新的回调方法
  ///
  /// 子类需要重写此方法，实现具体的刷新逻辑
  Future<void> onAuthRefresh();

  /// 是否启用登录后自动刷新（默认启用）
  ///
  /// 如果某些页面不需要此功能，可以重写此方法返回 false
  bool get enableAuthRefresh => true;

  @override
  void onInit() {
    super.onInit();
    if (enableAuthRefresh) {
      _setupAuthListener();
    }
  }

  void _setupAuthListener() {
    if (Get.isRegistered<IndexLogic>()) {
      final indexLogic = Get.find<IndexLogic>();
      _wasUnAuthed = !indexLogic.isLoggedIn;

      _authTokenSub = indexLogic.token.listen((token) {
        final isCurrentlyUnAuthed = token.isEmpty;

        // 检测到从未登录变为已登录（登录成功）
        if (_wasUnAuthed && !isCurrentlyUnAuthed) {
          debugPrint('🔄 [$runtimeType] 检测到登录状态变化：未登录 -> 已登录，自动刷新数据');

          // 延迟执行，确保状态更新完成
          Future.delayed(const Duration(milliseconds: 100), () {
            onAuthRefresh();
          });
        }

        _wasUnAuthed = isCurrentlyUnAuthed;
      });
    }
  }

  @override
  void onClose() {
    _authTokenSub?.cancel();
    super.onClose();
  }
}

/// 简单页面登录刷新 Mixin
///
/// 适用于只需要调用 initData() 方法的简单场景
///
/// 使用方法：
/// ```dart
/// class MyPageLogic extends GetxController with SimpleAuthRefreshMixin {
///   void initData() {
///     // 加载数据的逻辑
///   }
/// }
/// ```
mixin SimpleAuthRefreshMixin on GetxController {
  StreamSubscription<String>? _authTokenSub;
  bool _wasUnAuthed = false;

  /// 初始化数据的方法（子类需要实现）
  void initData();

  /// 是否启用登录后自动刷新（默认启用）
  bool get enableAuthRefresh => true;

  @override
  void onInit() {
    super.onInit();
    if (enableAuthRefresh) {
      _setupAuthListener();
    }
  }

  void _setupAuthListener() {
    if (Get.isRegistered<IndexLogic>()) {
      final indexLogic = Get.find<IndexLogic>();
      _wasUnAuthed = !indexLogic.isLoggedIn;

      _authTokenSub = indexLogic.token.listen((token) {
        final isCurrentlyUnAuthed = token.isEmpty;

        // 检测到从未登录变为已登录（登录成功）
        if (_wasUnAuthed && !isCurrentlyUnAuthed) {
          debugPrint('🔄 [$runtimeType] 检测到登录成功，自动调用 initData()');

          // 延迟执行，确保状态更新完成
          Future.delayed(const Duration(milliseconds: 100), () {
            initData();
          });
        }

        _wasUnAuthed = isCurrentlyUnAuthed;
      });
    }
  }

  @override
  void onClose() {
    _authTokenSub?.cancel();
    super.onClose();
  }
}
