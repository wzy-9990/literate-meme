import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_tem/api/modules/user.dart';
import 'package:flutter_tem/routers/app_routes.dart';
import 'package:flutter_tem/utils/storage/index.dart';
import 'package:get/get.dart';

class LoginLogic extends GetxController {
  void initData() {
    debugPrint('首页页面初始化');
  }

  Future<void> loginButtonClick() async {
    var params = {
      'mobile': "17819849990",
      'loginType': "1",
      'verificationCode': '6666',
    };
    final data = await loginApi(params);

    await Storage.setString(StorageKeys.token, data['accessToken']);
    await Storage.setMap(StorageKeys.userInfo, data);
    EasyLoading.showToast('登录成功');
    Get.offAllNamed(AppRoutes.index);
  }
}
