import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_tem/page/index/my/logic.dart';
import 'package:flutter_tem/routers/app_routes.dart';
import 'package:flutter_tem/routers/index.dart';
import 'package:flutter_tem/utils/storage/index.dart';
import 'package:get/get.dart';

class MySettingLogic extends GetxController {
  final myLogic = Get.find<MyLogic>();
  RxBool isLoading = true.obs;
  RxMap userInfo = RxMap();

  // 连续点击计数器
  int _clickCount = 0;
  DateTime? _lastClickTime;
  static const int _maxClickCount = 7; // 需要连续点击7次
  static const Duration _clickInterval = Duration(seconds: 2); // 2秒内点击有效

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
    final now = DateTime.now();

    // 如果距离上次点击超过规定时间，重置计数器
    if (_lastClickTime != null &&
        now.difference(_lastClickTime!) > _clickInterval) {
      _clickCount = 0;
    }

    _clickCount++;
    _lastClickTime = now;

    // 显示剩余点击次数提示
    if (_clickCount < _maxClickCount) {
      final remaining = _maxClickCount - _clickCount;
      EasyLoading.showToast('再点击 $remaining 次进入开发者选项');
    } else {
      // 达到次数，重置计数器并显示开发者选项
      _clickCount = 0;
      _showDeveloperOptions();
    }
  }

  /// 显示开发者选项弹窗
  void _showDeveloperOptions() {
    final TextEditingController apiUrlController = TextEditingController();

    // 获取当前 API 地址
    final currentApiUrl = dotenv.env['API_URL'] ?? '';
    apiUrlController.text = currentApiUrl;

    Get.dialog(
      AlertDialog(
        title: const Text('开发者选项'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '修改 API 地址',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '修改后将退出登录，下次请求将使用新地址',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: apiUrlController,
              decoration: const InputDecoration(
                labelText: 'API 地址',
                hintText: 'https://example.com/api',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            Text(
              '当前地址：$currentApiUrl',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              apiUrlController.dispose();
              Get.back();
            },
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              apiUrlController.dispose();
              _resetToDefaultApiUrl();
            },
            child: const Text('恢复默认'),
          ),
          ElevatedButton(
            onPressed: () {
              final newApiUrl = apiUrlController.text.trim();
              if (newApiUrl.isEmpty) {
                EasyLoading.showToast('请输入 API 地址');
                return;
              }
              apiUrlController.dispose();
              _changeApiUrl(newApiUrl);
            },
            child: const Text('确定'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// 修改 API 地址
  Future<void> _changeApiUrl(String newApiUrl) async {
    Get.back(); // 关闭弹窗

    // 保存新的 API 地址到 Storage
    await Storage.setString('custom_api_url', newApiUrl);

    EasyLoading.showToast('API 地址已修改，正在退出登录...');

    // 延迟退出登录，让用户看到提示
    Future.delayed(const Duration(seconds: 1), () async {
      await Storage.remove(StorageKeys.token);
      await Storage.remove(StorageKeys.userInfo);

      // 重启应用以使新的 API 地址生效
      Get.offAllNamed(AppRoutes.guide);
    });
  }

  /// 恢复默认 API 地址
  Future<void> _resetToDefaultApiUrl() async {
    Get.back(); // 关闭弹窗

    // 删除自定义的 API 地址
    await Storage.remove('custom_api_url');

    EasyLoading.showToast('已恢复默认地址，正在退出登录...');

    Future.delayed(const Duration(seconds: 1), () async {
      await Storage.remove(StorageKeys.token);
      await Storage.remove(StorageKeys.userInfo);

      // 重启应用
      Get.offAllNamed(AppRoutes.guide);
    });
  }
}
