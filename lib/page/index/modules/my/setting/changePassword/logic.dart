import 'package:flutter_tem/page/index/logic.dart';
import 'package:flutter_tem/utils/mixin/base_mixin.dart';
import 'package:flutter_tem/utils/mixin/delayed_initial_load_mixin.dart';
import 'package:get/get.dart';

class ChangePasswordLogic extends GetxController
    with DelayedInitialLoadMixin, BaseMixin {
  final indexLogic = Get.find<IndexLogic>();
  RxBool isLoading = true.obs;
  late final RxMap userInfo;

  @override
  Future<void> onLoad() async {
    initData();
  }

  @override
  void initData() async {
    // 登录后会自动调用此方法刷新数据
    userInfo = indexLogic.userInfo;
    isLoading.value = false;
  }

  void updateLastUserInfo() {
    Get.back(result: '1915336487400169473');
  }
}
