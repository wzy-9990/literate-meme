import 'package:flutter/material.dart';
import 'package:flutter_dynamic_icon/flutter_dynamic_icon.dart';
import 'package:flutter_tem/theme/app_icons.dart';

/// App 图标管理工具
class AppIconManager {
  /// 切换到指定图标
  ///
  /// [iconName] 图标名称，参考 AppIconConfig
  static Future<bool> changeIcon(String iconName) async {
    try {
      // 检查图标是否在可用列表中
      if (!AppIconConfig.availableIcons.contains(iconName)) {
        debugPrint('图标不存在: $iconName');
        return false;
      }

      // 如果是默认图标，传 null
      final iconToSet = iconName == AppIconConfig.defaultIcon ? null : iconName;

      // 切换图标
      await FlutterDynamicIcon.setAlternateIconName(iconToSet);
      debugPrint('图标已切换: $iconName');
      return true;
    } catch (e) {
      debugPrint('切换图标失败: $e');
      return false;
    }
  }

  /// 根据当前日期自动切换图标
  static Future<bool> changeIconByDate() async {
    final iconName = AppIconConfig.getCurrentIcon();
    debugPrint('根据日期切换图标: $iconName');
    return await changeIcon(iconName);
  }

  /// 获取当前图标名称
  static Future<String?> getCurrentIconName() async {
    try {
      final iconName = await FlutterDynamicIcon.getAlternateIconName();
      return iconName ?? AppIconConfig.defaultIcon;
    } catch (e) {
      debugPrint('获取当前图标失败: $e');
      return null;
    }
  }

  /// 检查是否支持动态图标
  static Future<bool> isSupported() async {
    try {
      return await FlutterDynamicIcon.supportsAlternateIcons ?? false;
    } catch (e) {
      debugPrint('检查动态图标支持失败: $e');
      return false;
    }
  }

  /// 恢复默认图标
  static Future<bool> restoreDefaultIcon() async {
    return await changeIcon(AppIconConfig.defaultIcon);
  }
}
