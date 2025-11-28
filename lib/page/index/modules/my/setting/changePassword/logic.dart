import 'package:flutter_tem/page/index/logic.dart';
import 'package:flutter_tem/utils/logic/base/base_logic.dart';
import 'package:get/get.dart';

class ChangePasswordLogic extends BaseLogic {
  final indexLogic = Get.find<IndexLogic>();
  RxBool isLoading = true.obs;

  // 使用 getter 直接引用 indexLogic.userInfo，保持响应式
  RxMap get userInfo => indexLogic.userInfo;

  @override
  Future<void> onLoad() async {
    // 登录后会自动调用此方法刷新数据
    // userInfo 已经通过 getter 引用，无需赋值
    isLoading.value = false;
  }

  void updateLastUserInfo() {
    Get.back(result: '1915336487400169473');
  }
}
