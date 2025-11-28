import 'package:flutter_tem/utils/logic/base/mixin/auth_refresh_mixin.dart';
import 'package:flutter_tem/utils/logic/base/mixin/delayed_initial_load_mixin.dart';
import 'package:flutter_tem/utils/logic/base/mixin/page_visibility_mixin.dart';
import 'package:get/get.dart';

/// BaseLogic - 简化的通用基类
///
/// 自动集成的功能：
/// - 统一延迟首屏加载：`DelayedInitialLoadMixin`（控制 onLoad 时机）
/// - 登录成功后自动刷新：`SimpleAuthRefreshMixin`
/// - 页面可见性监听：`PageVisibilityMixin`（提供 onShow/onHide 回调）
///
/// 使用方式：
/// ```dart
/// class MyLogic extends BaseLogic {
///   @override
///   Future<void> onLoad() async {
///     // 页面首次加载（执行1次）
///   }
///
///   @override
///   void onShow() {
///     super.onShow(); // 可选：打印日志
///     // 页面显示时（包括返回，执行多次）
///     refreshData();
///   }
///
///   @override
///   void onHide() {
///     super.onHide(); // 可选：打印日志
///     // 页面隐藏时（跳转其他页面，执行多次）
///   }
/// }
/// ```
///
/// **注意**：需要在 View 层使用 `PageVisibilityWrapper` 包裹才能触发 onShow/onHide
abstract class BaseLogic extends GetxController
    with SimpleAuthRefreshMixin, DelayedInitialLoadMixin, PageVisibilityMixin {
  bool _authRefreshing = false;

  /// 默认不启用自动登录刷新，避免与外部主动刷新形成递归。
  /// 若需要，可在子类中覆盖为 true。
  @override
  bool get enableAuthRefresh => false;

  /// 提供 SimpleAuthRefreshMixin 要求的 initData，实现为调用 onLoad。
  @override
  void initData() {
    onLoad();
  }

  /// 登录成功后默认调用 onLoad，带简单的重入保护
  Future<void> onAuthRefresh() async {
    if (_authRefreshing) {
      return;
    }
    _authRefreshing = true;
    try {
      await onLoad();
    } finally {
      _authRefreshing = false;
    }
  }

  /// 默认在 onReady 后延迟加载
  @override
  bool get autoLoadOnInit => false;

  /// 默认延迟 100ms，避免路由动画期间触发
  @override
  Duration get initialLoadDelay => const Duration(milliseconds: 100);

  /// 子类需实现的加载/刷新逻辑
  @override
  Future<void> onLoad();
}
