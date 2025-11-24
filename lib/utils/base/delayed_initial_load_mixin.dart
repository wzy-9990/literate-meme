import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// 统一控制首轮加载时机的 Mixin
///
/// 用法：
/// - 淡入路由时避免抖动：`autoLoadOnInit => false`，设置 `initialLoadDelay` 为路由动画时长
/// - 需要立即加载：保持默认值
mixin DelayedInitialLoadMixin on GetxController {
  /// 是否在 onInit 里立即加载；false 时改为 onReady 首帧后再调
  bool get autoLoadOnInit => true;

  /// 首次加载前的额外延迟（避免路由动画期间触发）
  Duration get initialLoadDelay => const Duration(milliseconds: 100);

  /// 具体的加载逻辑
  Future<void> onLoad();

  @override
  void onInit() {
    super.onInit();
    if (autoLoadOnInit) {
      onLoad();
    }
  }

  @override
  void onReady() {
    super.onReady();
    if (!autoLoadOnInit) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (initialLoadDelay > Duration.zero) {
          await Future.delayed(initialLoadDelay);
        }
        await onLoad();
      });
    }
  }
}
