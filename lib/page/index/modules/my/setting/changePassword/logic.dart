import 'package:flutter_tem/page/index/logic.dart';
import 'package:flutter_tem/utils/mixin/base_mixin.dart';
import 'package:get/get.dart';

class ChangePasswordLogic extends GetxController with BaseMixin {
  final indexLogic = Get.find<IndexLogic>();
  RxBool isLoading = true.obs;

  // 使用 getter 直接引用 indexLogic.userInfo，保持响应式
  RxMap get userInfo => indexLogic.userInfo;

  @override
  Future<void> onLoad() async {
    await initData();
  }

  @override
  Future<void> initData() async {
    // 登录后会自动调用此方法刷新数据
    // userInfo 已经通过 getter 引用，无需赋值
    isLoading.value = false;
  }

  void updateLastUserInfo() {
    Get.back(result: '1915336487400169473');
  }
}
