import 'package:flutter/material.dart';
import 'package:flutter_tem/components/BasePhoneCall/index.dart';
import 'package:flutter_tem/routers/app_routes.dart';
import 'package:flutter_tem/routers/index.dart';
import 'package:flutter_tem/utils/modules/dict/home.dart';
import 'package:get/get.dart';

class HomeLogic extends GetxController {
  /// 当前选中的方向（默认取枚举 add_points 对应的值，否则为 1）
  final RxInt selectedDirection =
      ((directionTypeEnum['add_points']?['value'] as int)).obs;

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

  void phoneCallExampleView() {
    BasePhoneCall.makePhoneCall(Get.context!, '138-1234-5678');
  }

  void appIconExampleView() {
    NavigationUtils.toNamed(AppRoutes.appIconExample);
  }

  void updateDirection(int value) {
    selectedDirection.value = value;
  }
}
