import 'package:flutter_tem/page/index/home/logic.dart';
import 'package:flutter_tem/page/index/logic.dart';
import 'package:flutter_tem/page/index/message/logic.dart';
import 'package:flutter_tem/page/index/my/logic.dart';
import 'package:get/get.dart';

class IndexBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => IndexLogic());
    Get.lazyPut(() => HomeLogic());
    Get.lazyPut(() => MessageLogic());
    Get.lazyPut(() => MyLogic());
  }
}
