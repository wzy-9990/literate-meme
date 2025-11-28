import 'package:flutter_tem/utils/mixin/auth_refresh_mixin.dart';
import 'package:flutter_tem/utils/mixin/delayed_initial_load_mixin.dart';
import 'package:get/get.dart';

/// BaseMixin - 所有页面 Logic 的基础 Mixin
///
/// 统一管理所有页面的通用功能，包括：
/// - 登录后自动刷新（通过 SimpleAuthRefreshMixin）
/// - 延迟加载控制（通过 DelayedInitialLoadMixin）
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
///   void initData() {
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
mixin BaseMixin on GetxController
    with SimpleAuthRefreshMixin, DelayedInitialLoadMixin {
  /// 默认启用登录后自动刷新
  ///
  /// 可以在子类中覆盖此方法来禁用：
  /// ```dart
  /// @override
  /// bool get enableAuthRefresh => false;
  /// ```
  @override
  bool get enableAuthRefresh => true;

  /// 默认在 onReady 时加载（避免路由动画抖动）
  ///
  /// 可以在子类中覆盖此方法改为立即加载：
  /// ```dart
  /// @override
  /// bool get autoLoadOnInit => true;
  /// ```
  @override
  bool get autoLoadOnInit => false;

  /// 默认延迟 100ms 后加载
  ///
  /// 可以在子类中覆盖此方法自定义延迟时间：
  /// ```dart
  /// @override
  /// Duration get initialLoadDelay => Duration(milliseconds: 200);
  /// ```
  @override
  Duration get initialLoadDelay => const Duration(milliseconds: 100);

  /// 默认不跳过 onReady 的延迟加载
  ///
  /// 可以在子类中覆盖此方法（用于 Tab 顶级页面等场景）：
  /// ```dart
  /// @override
  /// bool get skipDelayedOnReady => true;
  /// ```
  @override
  bool get skipDelayedOnReady => false;

  /// 覆盖 onInit 以确保两个 mixin 的功能都能正常工作
  @override
  void onInit() {
    super.onInit();
    // 两个 mixin 都需要在 onInit 中初始化，需要确保都被调用
  }

  /// 覆盖 onClose 以确保两个 mixin 的清理都能正常执行
  @override
  void onClose() {
    // 两个 mixin 都需要在 onClose 中清理资源
    super.onClose();
  }

  /// 页面加载逻辑（子类需要实现）
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
  @override
  Future<void> onLoad() async {
    // 默认实现：空方法，子类可以覆盖
  }

  /// 初始化数据逻辑（子类需要实现）
  ///
  /// 此方法会在以下情况被调用：
  /// - 登录成功后自动调用（如果 enableAuthRefresh = true）
  /// - 通常在 onLoad() 中手动调用
  ///
  /// 示例：
  /// ```dart
  /// @override
  /// void initData() {
  ///   // 加载页面数据
  ///   loadUserInfo();
  /// }
  /// ```
  @override
  void initData() {
    // 默认实现：空方法，子类可以覆盖
  }
}
