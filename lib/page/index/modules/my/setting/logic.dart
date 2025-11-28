import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_tem/components/BaseDeveloperOptions/index.dart';
import 'package:flutter_tem/page/index/logic.dart';
import 'package:flutter_tem/routers/app_routes.dart';
import 'package:flutter_tem/routers/index.dart';
import 'package:get/get.dart';

class MySettingLogic extends GetxController {
  final indexLogic = Get.find<IndexLogic>();
  RxBool isLoading = true.obs;
  late final RxMap userInfo;

  // 开发者选项
  final developerOptions = BaseDeveloperOptions();

  @override
  void onInit() {
    super.onInit();
    initData();
  }

  void initData() async {
    userInfo = indexLogic.userInfo;
    isLoading.value = false;
  }

  void logout() async {
    indexLogic.logout();
  }

  void changePassword() async {
    await NavigationUtils.toNamed(
      AppRoutes.myChangePassword,
      callback: (result) async {
        updateUserInfo(result as String);
      },
    );
  }

  void updateUserInfo(String name) async {
    isLoading.value = true;
    await indexLogic.loadUserInfo(id: name);
    isLoading.value = false;
    EasyLoading.showToast('操作成功');
  }

  /// 处理版本号点击（开发者选项入口）
  void onVersionTap() {
    developerOptions.onTap();
  }
}
