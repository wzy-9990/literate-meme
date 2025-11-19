import 'package:flutter/material.dart';
import 'package:flutter_tem/utils/storage/index.dart';
import 'package:get/get.dart';

class MyLogic extends GetxController {
  RxBool isLoading = true.obs;
  RxString avatar = ''.obs;
  RxMap userInfo = RxMap();

  initData() async {
    debugPrint('我的页面初始化');
    // 模拟获取用户信息
    Future.delayed(const Duration(seconds: 1), () async {
      isLoading.value = false;
      // 尝试从存储中获取用户信息
      await _loadUserInfo();
    });
  }

  _loadUserInfo() async {
    final dynamic storedName = await Storage.getMap(StorageKeys.userInfo);
    userInfo.value = storedName;
  }
}
