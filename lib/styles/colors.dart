import 'package:flutter/material.dart';

/// 应用颜色定义
/// 集中管理所有颜色常量，便于统一调整和维护
class AppColors {
  AppColors._();

  // ==================== 主题色 ====================

  /// 主题色 - 橙色
  static const Color primary = Color(0xFFFE6601);

  /// 主题色浅色变体
  static const Color primaryLight = Color(0xFFFF8534);

  /// 主题色深色变体
  static const Color primaryDark = Color(0xFFE55A00);

  // ==================== 功能色 ====================

  /// 成功色 - 绿色
  static const Color success = Color(0xFF52C41A);

  /// 警告色 - 黄色
  static const Color warning = Color(0xFFFAAD14);

  /// 错误色 - 红色
  static const Color error = Color(0xFFF5222D);

  /// 信息色 - 蓝色
  static const Color info = Color(0xFF1890FF);

  // ==================== 中性色 ====================

  /// 标题/重要文字 - 深灰
  static const Color textPrimary = Color(0xFF333333);

  /// 正文/次要文字 - 中灰
  static const Color textSecondary = Color(0xFF666666);

  /// 辅助文字 - 浅灰
  static const Color textTertiary = Color(0xFF999999);

  /// 占位文字/禁用文字 - 更浅灰
  static const Color textPlaceholder = Color(0xFFCCCCCC);

  // ==================== 背景色 ====================

  /// 页面背景色
  static const Color background = Color(0xFFF6F6F6);

  /// 卡片/组件背景色
  static const Color surface = Color(0xFFFFFFFF);

  /// 分割线颜色
  static const Color divider = Color(0xFFEEEEEE);

  /// 边框颜色
  static const Color border = Color(0xFFDDDDDD);

  // ==================== 特殊颜色 ====================

  /// 蒙层背景色
  static const Color overlay = Color(0x80000000); // 50% 透明黑色

  /// 阴影颜色
  static const Color shadow = Color(0x1A000000); // 10% 透明黑色

  // ==================== 透明度变体 ====================

  /// 主题色 10% 透明度（用于背景）
  static Color get primaryOpacity10 => primary.withOpacity(0.1);

  /// 主题色 20% 透明度
  static Color get primaryOpacity20 => primary.withOpacity(0.2);

  /// 主题色 50% 透明度
  static Color get primaryOpacity50 => primary.withOpacity(0.5);
}

/// BaseColor - 保持向后兼容
/// @Deprecated('使用 AppColors 替代')
class BaseColor {
  BaseColor._();

  /// 主题色
  /// @Deprecated('使用 AppColors.primary 替代')
  static const Color main = AppColors.primary;
}
