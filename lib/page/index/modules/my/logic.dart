import 'package:flutter/material.dart';
import 'package:flutter_tem/page/index/logic.dart';
import 'package:get/get.dart';

class MyLogic extends GetxController {
  final indexLogic = Get.find<IndexLogic>();
  RxBool isLoading = true.obs;
  RxString avatar = ''.obs;
  late final RxMap userInfo;

  @override
  void onInit() {
    super.onInit();
    userInfo = indexLogic.userInfo;
    initData();
  }

  Future<void> initData() async {
    debugPrint('我的页面初始化');
    isLoading.value = true;
    final data = await indexLogic.loadUserInfo();
    userInfo.value = data ?? {};
    isLoading.value = false;
  }
}
