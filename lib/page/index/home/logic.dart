import 'package:flutter/material.dart';
import 'package:flutter_tem/routers/app_routes.dart';
import 'package:flutter_tem/routers/index.dart';
import 'package:get/get.dart';

class HomeLogic extends GetxController {
  void initData() {
    debugPrint('首页页面初始化');
  }

  void openWebView() {
    NavigationUtils.toNamed(AppRoutes.webView, arguments: {
      'url': 'https://manager-test.pinduola.cn/manager/index.html#/login',
      'title': '看下',
    });
  }

  void pullToRefreshView() {
    NavigationUtils.toNamed(AppRoutes.example, arguments: {
      'url': 'https://manager-test.pinduola.cn/manager/index.html#/login',
      'title': '看下',
    });
  }

  void imageExampleView() {
    NavigationUtils.toNamed(AppRoutes.imageExample);
  }

  void permissionExampleView() {
    NavigationUtils.toNamed(AppRoutes.permissionExample);
  }

  void uploadExampleView() {
    NavigationUtils.toNamed(AppRoutes.uploadExample);
  }
}
