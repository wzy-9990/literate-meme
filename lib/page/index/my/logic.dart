import 'package:flutter_tem/utils/base/base_logic.dart';
import 'package:flutter_tem/utils/storage/index.dart';
import 'package:get/get.dart';

class MyLogic extends BaseLogic {
  RxString avatar = "".obs;
  RxMap userInfo = RxMap();

  @override
  void initData() {
    super.initData();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    await executeAsync(
      () async {
        // 模拟获取用户信息延迟
        await Future.delayed(const Duration(seconds: 1));

        // 从存储中获取用户信息
        dynamic storedInfo = await Storage.getMap(StorageKeys.userInfo);
        userInfo.value = storedInfo ?? {};

        return storedInfo;
      },
      showLoadingIndicator: true,
    );
  }
}
