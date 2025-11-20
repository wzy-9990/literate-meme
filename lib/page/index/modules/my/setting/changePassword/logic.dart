import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_tem/page/index/modules/my/logic.dart';
import 'package:flutter_tem/routers/app_routes.dart';
import 'package:flutter_tem/utils/storage/index.dart';
import 'package:get/get.dart';

class ChangePasswordLogic extends GetxController {
  final myLogic = Get.find<MyLogic>();

  RxBool isLoading = false.obs;
  RxMap userInfo = RxMap();
  @override
  void onInit() {
    super.onInit();
    initData();
  }

  void initData() {
    debugPrint('设置页面初始化');
    isLoading.value = true;
    Future.delayed(const Duration(seconds: 1), () async {
      isLoading.value = false;
      _loadUserInfo();
    });
  }

  void logout() async {
    await Storage.clear();
    await Get.offAllNamed(AppRoutes.login);
  }

  void updateLastUserInfo() {
    Get.back(result: true);
  }

  void _loadUserInfo() async {
    final dynamic storedName = await Storage.getMap(StorageKeys.userInfo);
    userInfo.value = storedName;
  }

  void updateUserInfo(String name) async {
    final int currentMilliseconds = DateTime.now().millisecondsSinceEpoch;
    final dynamic storedName = await Storage.getMap(StorageKeys.userInfo);
    storedName['userName'] = '张三$currentMilliseconds';
    await Storage.setMap(StorageKeys.userInfo, storedName);
    initData();
    myLogic.initData();
    EasyLoading.showToast('操作成功');
  }
}
