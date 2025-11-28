import 'package:flutter_tem/api/modules/user.dart';
import 'package:flutter_tem/routers/app_routes.dart';
import 'package:flutter_tem/utils/base/base_logic.dart';
import 'package:flutter_tem/utils/storage/index.dart';
import 'package:get/get.dart';

class LoginLogic extends BaseLogic {
  @override
  void initData() {
    super.initData();
    // 登录页面初始化逻辑
  }

  Future<void> loginButtonClick() async {
    await executeAsync(
      () async {
        var params = {
          'mobile': "17819849990",
          'loginType': "1",
          'verificationCode': '6666',
        };
        final data = await loginApi(params);

        await Storage.setString(StorageKeys.token, data['accessToken']);
        await Storage.setMap(StorageKeys.userInfo, data);

        return data;
      },
      showLoadingIndicator: true,
      loadingMessage: '登录中...',
      successMessage: '登录成功',
      onSuccess: (data) {
        // 跳转到首页
        Get.offAllNamed(AppRoutes.index);
      },
    );
  }
}
