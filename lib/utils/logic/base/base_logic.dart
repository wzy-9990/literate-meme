import 'package:flutter_tem/utils/logic/base/mixin/auth_refresh_mixin.dart';
import 'package:flutter_tem/utils/logic/base/mixin/delayed_initial_load_mixin.dart';
import 'package:get/get.dart';

/// BaseLogic - 简化的通用基类
///
/// - 统一延迟首屏加载：`DelayedInitialLoadMixin`（控制 onLoad 时机）
/// - 登录成功后自动刷新：`SimpleAuthRefreshMixin`
abstract class BaseLogic extends GetxController
    with SimpleAuthRefreshMixin, DelayedInitialLoadMixin {
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
