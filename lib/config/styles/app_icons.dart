/// App 图标配置
///
/// 统一管理 iOS 和 Android 的图标切换配置
class AppIconConfig {
  /// 默认图标
  static const String defaultIcon = 'default';

  /// 春节图标（1月-2月）
  static const String springFestival = 'spring_festival';

  /// 劳动节图标（5月1日-5月3日）
  static const String laborDay = 'labor_day';

  /// 国庆节图标（10月1日-10月7日）
  static const String nationalDay = 'national_day';

  /// 圣诞节图标（12月24日-12月26日）
  static const String christmas = 'christmas';

  /// 所有可用图标列表
  static const List<String> availableIcons = [
    defaultIcon,
    springFestival,
    laborDay,
    nationalDay,
    christmas,
  ];

  /// 图标显示名称
  static const Map<String, String> iconNames = {
    defaultIcon: '默认图标',
    springFestival: '春节图标',
    laborDay: '劳动节图标',
    nationalDay: '国庆节图标',
    christmas: '圣诞节图标',
  };

  /// 图标对应的日期范围配置
  static final List<IconDateRule> dateRules = [
    // 春节（农历正月初一前后，这里简化为公历1-2月）
    const IconDateRule(
      iconName: springFestival,
      startMonth: 1,
      startDay: 1,
      endMonth: 2,
      endDay: 28,
    ),
    // 劳动节
    const IconDateRule(
      iconName: laborDay,
      startMonth: 5,
      startDay: 1,
      endMonth: 5,
      endDay: 3,
    ),
    // 国庆节
    const IconDateRule(
      iconName: nationalDay,
      startMonth: 10,
      startDay: 1,
      endMonth: 10,
      endDay: 7,
    ),
    // 圣诞节
    const IconDateRule(
      iconName: christmas,
      startMonth: 12,
      startDay: 24,
      endMonth: 12,
      endDay: 26,
    ),
  ];

  /// 根据当前日期获取应该使用的图标
  static String getIconForDate(DateTime date) {
    for (final rule in dateRules) {
      if (rule.isInRange(date)) {
        return rule.iconName;
      }
    }
    return defaultIcon;
  }

  /// 获取当前应该使用的图标
  static String getCurrentIcon() {
    return getIconForDate(DateTime.now());
  }
}

/// 图标日期规则
class IconDateRule {
  final String iconName;
  final int startMonth;
  final int startDay;
  final int endMonth;
  final int endDay;

  const IconDateRule({
    required this.iconName,
    required this.startMonth,
    required this.startDay,
    required this.endMonth,
    required this.endDay,
  });

  /// 判断给定日期是否在规则范围内
  bool isInRange(DateTime date) {
    final month = date.month;
    final day = date.day;

    // 简单的日期范围判断（不考虑跨年）
    if (startMonth == endMonth) {
      // 同一个月
      return month == startMonth && day >= startDay && day <= endDay;
    } else {
      // 跨月
      if (month == startMonth) {
        return day >= startDay;
      } else if (month == endMonth) {
        return day <= endDay;
      } else if (month > startMonth && month < endMonth) {
        return true;
      }
    }

    return false;
  }
}
