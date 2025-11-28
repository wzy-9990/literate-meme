import 'package:flutter_tem/page/index/home/logic.dart';
import 'package:flutter_tem/page/index/message/logic.dart';
import 'package:flutter_tem/page/index/my/logic.dart';
import 'package:flutter_tem/utils/base/base_logic.dart';
import 'package:get/get.dart';

class IndexLogic extends BaseLogic {
  final currentIndex = 0.obs;
  final homeLogic = Get.find<HomeLogic>();
  final messageLogic = Get.find<MessageLogic>();
  final myLogic = Get.find<MyLogic>();

  @override
  void initData() {
    super.initData();
    homeLogic.initData();
  }

  void changeTab(int index) {
    currentIndex.value = index;
    if (currentIndex.value == 0) {
      homeLogic.initData();
    } else if (currentIndex.value == 1) {
      messageLogic.initData();
    } else if (currentIndex.value == 2) {
      myLogic.initData();
    }
  }
}
