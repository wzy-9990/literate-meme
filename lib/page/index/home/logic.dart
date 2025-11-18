import 'package:flutter/material.dart';
import 'package:flutter_tem/routers/app_routes.dart';
import 'package:flutter_tem/routers/index.dart';
import 'package:get/get.dart';

class HomeLogic extends GetxController {
  void initData() {
    debugPrint('首页页面初始化');
  }

  openWebView() {
    NavigationUtils.toNamed(AppRoutes.example, arguments: {
      'url': 'https://manager-test.pinduola.cn/manager/index.html#/login',
      'title': '看下',
    });
  }
}
