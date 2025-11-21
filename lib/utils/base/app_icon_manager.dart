import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_dynamic_icon/flutter_dynamic_icon.dart';
import 'package:flutter_tem/config/styles/app_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App 图标管理工具
class AppIconManager {
  // Android 原生 MethodChannel
  static const MethodChannel _androidChannel =
      MethodChannel('com.pinkala.driver/app_icon');

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

      if (Platform.isAndroid) {
        // Android 使用自定义 MethodChannel
        await _androidChannel
            .invokeMethod('changeIcon', {'iconName': iconName});
        debugPrint('Android 图标已切换: $iconName');
        return true;
      } else if (Platform.isIOS) {
        // iOS 使用 flutter_dynamic_icon 插件
        final iconToSet =
            iconName == AppIconConfig.defaultIcon ? null : iconName;
        await FlutterDynamicIcon.setAlternateIconName(iconToSet);
        debugPrint('iOS 图标已切换: $iconName');
        return true;
      }

      return false;
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
      if (Platform.isAndroid) {
        // Android 使用自定义 MethodChannel
        final iconName =
            await _androidChannel.invokeMethod<String>('getCurrentIcon');
        return iconName ?? AppIconConfig.defaultIcon;
      } else if (Platform.isIOS) {
        // iOS 使用 flutter_dynamic_icon 插件
        final iconName = await FlutterDynamicIcon.getAlternateIconName();
        return iconName ?? AppIconConfig.defaultIcon;
      }
      return AppIconConfig.defaultIcon;
    } catch (e) {
      debugPrint('获取当前图标失败: $e');
      return AppIconConfig.defaultIcon;
    }
  }

  /// 检查是否支持动态图标
  static Future<bool> isSupported() async {
    try {
      if (Platform.isAndroid) {
        // Android 使用自定义 MethodChannel
        final supported =
            await _androidChannel.invokeMethod<bool>('isSupported');
        return supported ?? false;
      } else if (Platform.isIOS) {
        // iOS 使用 flutter_dynamic_icon 插件
        return await FlutterDynamicIcon.supportsAlternateIcons;
      }
      return false;
    } catch (e) {
      debugPrint('检查动态图标支持失败: $e');
      return false;
    }
  }

  /// 恢复默认图标
  static Future<bool> restoreDefaultIcon() async {
    return await changeIcon(AppIconConfig.defaultIcon);
  }

  /// 获取自动切换开关状态
  static bool getAutoSwitchEnabled() {
    try {
      final envValue = dotenv.env['AUTO_ICON_SWITCH'];
      if (envValue == null) return false;
      return envValue.toLowerCase() == 'true';
    } catch (e) {
      return false;
    }
  }

  /// 获取上次检查日期
  static Future<String?> getLastCheckDate() async {
    // 使用 shared_preferences 存储最后检查日期
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('last_icon_check_date');
    } catch (e) {
      return null;
    }
  }

  /// 设置上次检查日期
  static Future<void> setLastCheckDate(String date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_icon_check_date', date);
    } catch (e) {
      // 忽略错误
    }
  }

  /// 检查并执行自动图标切换
  static Future<void> checkAndSwitchIcon() async {
    // 检查环境变量，如果禁用则直接返回
    if (!getAutoSwitchEnabled()) {
      return;
    }

    final today = DateTime.now();
    final todayString = '${today.year}-${today.month}-${today.day}';
    final lastCheck = await getLastCheckDate();

    // 如果今天还没检查过，检查是否需要切换
    if (lastCheck != todayString) {
      // 先获取当前图标和应该显示的图标
      final currentIcon = await getCurrentIconName();
      final targetIcon = AppIconConfig.getCurrentIcon();

      // 只有当图标需要变化时才切换（避免不必要的切换导致返回桌面）
      if (currentIcon != targetIcon) {
        debugPrint('自动切换图标: $currentIcon -> $targetIcon');
        await changeIcon(targetIcon);
      } else {
        debugPrint('图标无需切换，当前已是: $currentIcon');
      }

      await setLastCheckDate(todayString);
    }
  }

  /// 手动触发图标切换
  static Future<void> manualSwitchIcon() async {
    await changeIconByDate();
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month}-${today.day}';
    await setLastCheckDate(todayString);
  }

  /// 重置服务状态
  static Future<void> reset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('last_icon_check_date');
    } catch (e) {
      // 忽略错误
    }
  }
}
