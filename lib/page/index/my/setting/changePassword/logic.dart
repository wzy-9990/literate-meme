import 'package:flutter_tem/page/index/my/logic.dart';
import 'package:flutter_tem/routers/app_routes.dart';
import 'package:flutter_tem/utils/base/base_logic.dart';
import 'package:flutter_tem/utils/storage/index.dart';
import 'package:get/get.dart';

class ChangePasswordLogic extends BaseLogic {
  final myLogic = Get.find<MyLogic>();
  RxMap userInfo = RxMap();

  @override
  void initData() {
    super.initData();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    await executeAsync(
      () async {
        await Future.delayed(const Duration(seconds: 1));
        dynamic storedInfo = await Storage.getMap(StorageKeys.userInfo);
        userInfo.value = storedInfo ?? {};
        return storedInfo;
      },
      showLoadingIndicator: true,
    );
  }

  Future<void> logout() async {
    await executeAsync(
      () async {
        await Storage.clear();
        return true;
      },
      onSuccess: (_) {
        Get.offAllNamed(AppRoutes.login);
      },
    );
  }

  void updateLastUserInfo() {
    Get.back(result: true);
  }

  Future<void> updateUserInfo(String name) async {
    await executeAsync(
      () async {
        int currentMilliseconds = DateTime.now().millisecondsSinceEpoch;
        dynamic storedInfo = await Storage.getMap(StorageKeys.userInfo);
        storedInfo['userName'] = '张三$currentMilliseconds';
        await Storage.setMap(StorageKeys.userInfo, storedInfo);
        await initData();
        await myLogic.initData();
        return true;
      },
      successMessage: '操作成功',
    );
  }
}
