import 'package:flutter/material.dart';
import 'package:flutter_tem/page/index/logic.dart';
import 'package:flutter_tem/utils/mixin/base_mixin.dart';
import 'package:get/get.dart';

class MyLogic extends BaseLogic {
  final indexLogic = Get.find<IndexLogic>();
  RxBool isLoading = true.obs;
  RxString avatar = ''.obs;

  // 使用 getter 直接引用 indexLogic.userInfo，保持响应式
  RxMap get userInfo => indexLogic.userInfo;

  @override
  bool get skipDelayedOnReady => true; // 由 IndexLogic 切换 Tab 时再触发 initData

  @override
  Future<void> onLoad() async {
    debugPrint('我的页面初始化');
    isLoading.value = true;
    await indexLogic.loadUserInfo();
    isLoading.value = false;
  }
}
