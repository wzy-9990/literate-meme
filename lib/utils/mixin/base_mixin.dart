import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_tem/page/index/logic.dart';
import 'package:get/get.dart';

/// BaseMixin - 所有页面 Logic 的基础 Mixin
///
/// 统一管理所有页面的通用功能，包括：
/// - 登录后自动刷新
/// - 延迟加载控制
/// - 将来可能添加的其他通用功能（如埋点、性能监控等）
///
/// 使用方式：
/// ```dart
/// class YourLogic extends GetxController with BaseMixin {
///   @override
///   Future<void> onLoad() async {
///     // 你的加载逻辑（会在合适的时机自动调用）
///     await initData();
///   }
///
///   @override
///   Future<void> initData() async {
///     // 你的初始化逻辑（登录后会自动调用）
///   }
/// }
/// ```
///
/// 自定义行为：
/// ```dart
/// class YourLogic extends GetxController with BaseMixin {
///   @override
///   bool get enableAuthRefresh => false; // 禁用登录后自动刷新
///
///   @override
///   bool get autoLoadOnInit => true; // 在 onInit 时加载，而不是 onReady
///
///   @override
///   Duration get initialLoadDelay => Duration(milliseconds: 200); // 自定义延迟时间
/// }
/// ```
///
/// 优势：
/// - 统一管理：所有通用功能集中在一个地方
/// - 易于维护：修改或添加功能只需改这一个文件
/// - 自动继承：所有使用 BaseMixin 的页面自动获得新功能
/// - 灵活自定义：每个页面可以覆盖默认行为
mixin BaseMixin on GetxController {
  // ============================================================
  // 登录后自动刷新相关
  // ============================================================

  StreamSubscription<String>? _authTokenSub;
  bool _wasUnAuthed = false;

  /// 是否启用登录后自动刷新（默认启用）
  ///
  /// 可以在子类中覆盖此方法来禁用：
  /// ```dart
  /// @override
  /// bool get enableAuthRefresh => false;
  /// ```
  bool get enableAuthRefresh => true;

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

  // ============================================================
  // 延迟加载相关
  // ============================================================

  /// 是否在 onInit 里立即加载；false 时改为 onReady 首帧后再调
  ///
  /// 可以在子类中覆盖此方法改为立即加载：
  /// ```dart
  /// @override
  /// bool get autoLoadOnInit => true;
  /// ```
  bool get autoLoadOnInit => false;

  /// 首次加载前的额外延迟（避免路由动画期间触发）
  ///
  /// 可以在子类中覆盖此方法自定义延迟时间：
  /// ```dart
  /// @override
  /// Duration get initialLoadDelay => Duration(milliseconds: 200);
  /// ```
  Duration get initialLoadDelay => const Duration(milliseconds: 100);

  /// 是否跳过 onReady 的延迟加载（用于 Tab 顶级页面等场景）
  ///
  /// 可以在子类中覆盖此方法：
  /// ```dart
  /// @override
  /// bool get skipDelayedOnReady => true;
  /// ```
  bool get skipDelayedOnReady => false;

  // ============================================================
  // 生命周期方法
  // ============================================================

  /// 初始化标记，防止重复初始化
  bool _baseMixinInitialized = false;

  @override
  void onInit() {
    super.onInit();

    // 防止重复初始化
    if (_baseMixinInitialized) return;
    _baseMixinInitialized = true;

    // 登录刷新功能初始化
    if (enableAuthRefresh) {
      _setupAuthListener();
    }

    // 延迟加载功能 - 使用 Future.microtask 避免同步调用
    if (autoLoadOnInit) {
      Future.microtask(() => onLoad());
    }
  }

  @override
  void onReady() {
    super.onReady();

    // 延迟加载功能
    if (!autoLoadOnInit && !skipDelayedOnReady) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (initialLoadDelay > Duration.zero) {
          await Future.delayed(initialLoadDelay);
        }
        await onLoad();
      });
    }
  }

  @override
  void onClose() {
    _authTokenSub?.cancel();
    super.onClose();
  }

  // ============================================================
  // 子类需要实现的方法
  // ============================================================

  /// 页面加载逻辑（子类可以覆盖）
  ///
  /// 此方法会在合适的时机自动调用：
  /// - 如果 autoLoadOnInit = false（默认）：在 onReady 延迟后调用
  /// - 如果 autoLoadOnInit = true：在 onInit 时立即调用
  ///
  /// 示例：
  /// ```dart
  /// @override
  /// Future<void> onLoad() async {
  ///   await initData();
  /// }
  /// ```
  Future<void> onLoad() async {
    // 默认实现：空方法，子类可以覆盖
  }

  /// 初始化数据逻辑（子类可以覆盖）
  ///
  /// 此方法会在以下情况被调用：
  /// - 登录成功后自动调用（如果 enableAuthRefresh = true）
  /// - 通常在 onLoad() 中手动调用
  ///
  /// 示例：
  /// ```dart
  /// @override
  /// Future<void> initData() async {
  ///   // 加载页面数据
  ///   await loadUserInfo();
  /// }
  /// ```
  Future<void> initData() async {
    // 默认实现：空方法，子类可以覆盖
  }
}
