/// 间距常量定义
/// 统一管理所有间距，保持设计一致性
class AppSpacing {
  AppSpacing._();

  /// 极小间距 - 4px
  static const double xs = 4.0;

  /// 小间距 - 8px
  static const double sm = 8.0;

  /// 中等间距 - 12px
  static const double md = 12.0;

  /// 默认间距 - 16px
  static const double base = 16.0;

  /// 大间距 - 24px
  static const double lg = 24.0;

  /// 超大间距 - 32px
  static const double xl = 32.0;

  /// 特大间距 - 48px
  static const double xxl = 48.0;

  // ==================== 页面间距 ====================

  /// 页面水平内边距
  static const double pageHorizontal = 16.0;

  /// 页面垂直内边距
  static const double pageVertical = 16.0;

  /// 页面顶部安全间距（状态栏下方）
  static const double pageTop = 0.0; // 使用 SafeArea 处理

  /// 页面底部安全间距（导航栏上方）
  static const double pageBottom = 0.0; // 使用 SafeArea 处理

  // ==================== 组件间距 ====================

  /// 卡片内边距
  static const double cardPadding = 16.0;

  /// 列表项内边距
  static const double listItemPadding = 16.0;

  /// 按钮内边距（水平）
  static const double buttonPaddingHorizontal = 24.0;

  /// 按钮内边距（垂直）
  static const double buttonPaddingVertical = 12.0;

  /// 输入框内边距
  static const double inputPadding = 12.0;

  // ==================== 间距倍数 ====================

  /// 获取指定倍数的间距
  static double multiple(double factor) => base * factor;
}
