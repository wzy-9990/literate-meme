# flutter_tem

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## WebView 封装说明

本项目已封装通用 WebView 页面，使用方法如下：

1. 在需要使用 WebView 的地方导入工具类：
   ```dart
   import 'package:flutter_tem/utils/webview_utils.dart';
   ```

2. 调用工具类方法打开 WebView 页面：
   ```dart
   WebViewUtils.openWebView(
     'https://example.com',
     title: '页面标题',
   );
   ```

WebView 功能特性：
- 支持页面加载进度显示
- 支持页面标题自动获取
- 支持下拉刷新
- 支持返回按键处理
- 支持更多操作菜单（刷新、在浏览器中打开、复制链接等）
- 支持 JavaScript 交互
- 支持错误处理
