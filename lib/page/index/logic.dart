import 'package:flutter/material.dart';
import 'package:flutter_tem/page/index/modules/home/logic.dart';
import 'package:flutter_tem/page/index/modules/message/logic.dart';
import 'package:flutter_tem/page/index/modules/my/logic.dart';
import 'package:flutter_tem/utils/storage/index.dart';
import 'package:get/get.dart';

class IndexLogic extends GetxController {
  final currentIndex = 0.obs;
  final RxString token = ''.obs;

  final homeLogic = Get.find<HomeLogic>();
  MessageLogic? messageLogic;
  final myLogic = Get.find<MyLogic>();

  bool get isLoggedIn => token.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    initData();
    _loadToken();
  }

  void initData() {
    debugPrint('tab页面初始化');
    homeLogic.initData();
    // 消息页首屏不主动加载，等切换到消息时再加载
  }

  void changeTab(int index) {
    currentIndex.value = index;
    if (currentIndex.value == 0) {
      homeLogic.initData();
    } else if (currentIndex.value == 1) {
      messageLogic ??= Get.find<MessageLogic>();
      messageLogic!.initData();
    } else if (currentIndex.value == 2) {
      myLogic.initData();
    }
  }

  Future<void> _loadToken() async {
    token.value = await Storage.getString(StorageKeys.token) ?? '';
  }

  void updateToken(String? value) async {
    token.value = value ?? '';
    await Storage.setString(StorageKeys.token, value ?? '');
  }
}
