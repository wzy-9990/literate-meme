
import 'package:flutter_tem/page/user/login/logic.dart';
import 'package:get/get.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.create(() => LoginLogic());
  }
}
