import 'package:flutter_tem/page/index/logic.dart';
import 'package:flutter_tem/utils/base/delayed_initial_load_mixin.dart';
import 'package:get/get.dart';

class ChangePasswordLogic extends GetxController with DelayedInitialLoadMixin {
  final indexLogic = Get.find<IndexLogic>();
  RxBool isLoading = true.obs;
  late final RxMap userInfo;

  @override
  Future<void> onLoad() async {
    initData();
  }

  void initData() async {
    userInfo = indexLogic.userInfo;
    isLoading.value = false;
  }

  void updateLastUserInfo() {
    Get.back(result: '1915336487400169473');
  }
}
