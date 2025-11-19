import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_tem/components/DeveloperOptions/index.dart';
import 'package:flutter_tem/page/index/my/logic.dart';
import 'package:flutter_tem/routers/app_routes.dart';
import 'package:flutter_tem/routers/index.dart';
import 'package:flutter_tem/utils/storage/index.dart';
import 'package:get/get.dart';

class MySettingLogic extends GetxController {
  final myLogic = Get.find<MyLogic>();
  RxBool isLoading = true.obs;
  RxMap userInfo = RxMap();

  // 开发者选项
  final developerOptions = DeveloperOptions();

  @override
  void onInit() {
    super.onInit();
    initData();
  }

  initData() {
    Future.delayed(const Duration(seconds: 1), () async {
      isLoading.value = false;
      await _loadUserInfo();
    });
  }

  void logout() async {
    await Storage.clear();
    Get.offAllNamed(AppRoutes.login);
  }

  changePassword() async {
    await NavigationUtils.toNamed(
      AppRoutes.myChangePassword,
      callback: (result) async {
        isLoading.value = true;
        await initData();
      },
    );
  }

  _loadUserInfo() async {
    dynamic storedName = await Storage.getMap(StorageKeys.userInfo);
    userInfo.value = storedName;
  }

  updateUserInfo(String name) async {
    int currentMilliseconds = DateTime.now().millisecondsSinceEpoch;
    dynamic storedName = await Storage.getMap(StorageKeys.userInfo);
    storedName['userName'] = '${name}$currentMilliseconds';
    await Storage.setMap(StorageKeys.userInfo, storedName);
    await initData();
    await myLogic.initData();
    EasyLoading.showToast('操作成功');
  }

  /// 处理版本号点击（开发者选项入口）
  void onVersionTap() {
    developerOptions.onTap();
  }
}
