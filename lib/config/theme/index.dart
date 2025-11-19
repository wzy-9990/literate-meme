import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tem/styles/index.dart';

/// 应用主题配置
class AppTheme {
  AppTheme._();

  /// 浅色主题
  static ThemeData get lightTheme {
    return ThemeData(
      // 主色调设置
      colorScheme: ColorScheme.fromSeed(
        seedColor: BaseColor.main,
        primary: BaseColor.main,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0, // 阴影高度
        surfaceTintColor: Colors.transparent, // 去除 Material 3 的 surface tint 效果
        scrolledUnderElevation: 0, // 滚动时不改变阴影
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent, // 状态栏透明
          statusBarIconBrightness: Brightness.dark, // 状态栏图标深色
        ),
      ),
      // BottomNavigationBar 主题配置较为有限，主要样式在组件中直接设置
      splashColor: Colors.transparent, // 全局禁用水波纹
      highlightColor: Colors.transparent, // 全局禁用高亮
      scaffoldBackgroundColor: const Color(0xFFF6F6F6),
    );
  }

  /// 深色主题（可选，暂时使用浅色主题）
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      // 主色调设置
      colorScheme: ColorScheme.fromSeed(
        seedColor: BaseColor.main,
        primary: BaseColor.main,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light, // 深色主题用浅色图标
        ),
      ),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      scaffoldBackgroundColor: const Color(0xFF121212),
    );
  }
}
