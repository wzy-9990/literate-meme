import 'package:flutter/material.dart';
import 'package:flutter_tem/utils/logic/base/base_logic.dart';

/// 页面可见性示例 Logic
///
/// 演示如何使用页面可见性监听（BaseLogic 已自动集成 PageVisibilityMixin）
class PageVisibilityExampleLogic extends BaseLogic {
  /// 模拟计数器
  int _counter = 0;
  int get counter => _counter;

  @override
  Future<void> onLoad() async {
    debugPrint('📍 onLoad - 页面首次加载');
  }

  @override
  void onShow() {
    super.onShow(); // 调用父类方法（会打印日志）
    debugPrint('👀 onShow - 页面显示，刷新数据');
    _refreshData();
  }

  @override
  void onHide() {
    super.onHide(); // 调用父类方法（会打印日志）
    debugPrint('🙈 onHide - 页面隐藏，暂停操作');
    _pauseOperations();
  }

  /// 模拟刷新数据
  void _refreshData() {
    _counter++;
    debugPrint('🔄 刷新数据，计数器：$_counter');
    update(); // 更新视图
  }

  /// 模拟暂停操作
  void _pauseOperations() {
    debugPrint('⏸️  暂停操作');
  }

  /// 手动跳转到详情页（测试页面隐藏）
  void navigateToDetail() {
    debugPrint('🚀 跳转到详情页');
    // Get.toNamed(AppRoutes.detail);
  }
}
