import 'package:flutter/material.dart';

/// 圆角半径常量定义
/// 统一管理所有圆角样式，保持设计一致性
class AppRadius {
  AppRadius._();

  // ==================== 圆角半径值 ====================

  /// 极小圆角 - 2px
  static const double xs = 2.0;

  /// 小圆角 - 4px
  static const double sm = 4.0;

  /// 中等圆角 - 8px
  static const double md = 8.0;

  /// 默认圆角 - 12px
  static const double base = 12.0;

  /// 大圆角 - 16px
  static const double lg = 16.0;

  /// 超大圆角 - 24px
  static const double xl = 24.0;

  /// 完全圆形
  static const double circle = 9999.0;

  // ==================== BorderRadius 对象 ====================

  /// 极小圆角
  static BorderRadius get xsRadius => BorderRadius.circular(xs);

  /// 小圆角
  static BorderRadius get smRadius => BorderRadius.circular(sm);

  /// 中等圆角
  static BorderRadius get mdRadius => BorderRadius.circular(md);

  /// 默认圆角
  static BorderRadius get baseRadius => BorderRadius.circular(base);

  /// 大圆角
  static BorderRadius get lgRadius => BorderRadius.circular(lg);

  /// 超大圆角
  static BorderRadius get xlRadius => BorderRadius.circular(xl);

  /// 完全圆形
  static BorderRadius get circleRadius => BorderRadius.circular(circle);

  // ==================== 组件圆角 ====================

  /// 按钮圆角
  static const double button = 8.0;

  /// 卡片圆角
  static const double card = 12.0;

  /// 输入框圆角
  static const double input = 8.0;

  /// 对话框圆角
  static const double dialog = 16.0;

  /// 底部弹窗圆角（仅顶部）
  static BorderRadius get bottomSheet => const BorderRadius.only(
        topLeft: Radius.circular(16.0),
        topRight: Radius.circular(16.0),
      );
}
