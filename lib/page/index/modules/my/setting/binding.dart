// import 'package:flutter_tem/page/index/my/setting/logic.dart';
import 'package:flutter_tem/page/index/modules/my/setting/logic.dart';
import 'package:get/get.dart';

class MySettingBinding extends Bindings {
  @override
  void dependencies() {
    Get.create(() => MySettingLogic());
  }
}
