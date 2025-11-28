import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_tem/components/BaseDeveloperOptions/index.dart';
import 'package:flutter_tem/page/index/logic.dart';
import 'package:flutter_tem/routers/app_routes.dart';
import 'package:flutter_tem/routers/index.dart';
import 'package:flutter_tem/utils/logic/base/base_logic.dart';
import 'package:get/get.dart';

class MySettingLogic extends BaseLogic {
  final indexLogic = Get.find<IndexLogic>();
  RxBool isLoading = true.obs;

  // 使用 getter 直接引用 indexLogic.userInfo，保持响应式
  RxMap get userInfo => indexLogic.userInfo;

  // 开发者选项
  final developerOptions = BaseDeveloperOptions();

  @override
  Future<void> onLoad() async {
    // userInfo 已经通过 getter 引用，无需赋值
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
