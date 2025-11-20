// import 'package:flutter_tem/page/index/my/setting/logic.dart';
import 'package:flutter_tem/page/index/modules/my/setting/changePassword/logic.dart';
import 'package:get/get.dart';

class ChangePasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.create(() => ChangePasswordLogic());
  }
}
