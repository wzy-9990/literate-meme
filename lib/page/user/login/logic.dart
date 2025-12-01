import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_tem/api/modules/user.dart';
import 'package:flutter_tem/page/index/logic.dart';
import 'package:flutter_tem/routers/app_routes.dart';
import 'package:flutter_tem/utils/storage/index.dart';
import 'package:get/get.dart';

class LoginLogic extends GetxController {
  final indexLogic = Get.find<IndexLogic>();
  void initData() {
    debugPrint('首页页面初始化');
  }

  Future<void> loginButtonClick() async {
    final params = {
      'mobile': '17819849990',
      'loginType': '1',
      'verificationCode': '6666',
    };
    final data = await loginApi(params);
    final userData = await indexLogic.loadUserInfo();

    await Storage.setMap(StorageKeys.userInfo, userData);
    // 同步更新首页 token
    if (Get.isRegistered<IndexLogic>()) {
      indexLogic.updateToken(data['accessToken']?.toString());
    }
    EasyLoading.showToast('登录成功');
    Get.previousRoute.isEmpty
        ? Get.offAllNamed(AppRoutes.index)
        : Get.back(result: {'login': true, 'msg': '用户已完成登录'});
  }
}
