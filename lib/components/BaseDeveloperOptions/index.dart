import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tem/page/index/logic.dart';
import 'package:flutter_tem/routers/app_routes.dart';
import 'package:flutter_tem/utils/storage/index.dart';
import 'package:get/get.dart';

/// 开发者选项组件
///
/// 提供连续点击进入开发者选项的功能
/// 支持修改 API 地址和配置抓包代理
/// 生产环境自动禁用
class BaseDeveloperOptions {
  // 连续点击计数器
  int _clickCount = 0;
  DateTime? _lastClickTime;
  static const int _maxClickCount = 7; // 需要连续点击7次
  static const Duration _clickInterval = Duration(seconds: 2); // 2秒内点击有效

  /// 当前环境
  static const String _env =
      String.fromEnvironment('ENV', defaultValue: 'development');

  /// 是否为生产环境
  static bool get isProduction => _env == 'production';

  /// 处理版本号点击（开发者选项入口）
  void onTap() {
    // 生产环境不允许进入开发者选项
    if (isProduction) {
      return;
    }

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
    final TextEditingController proxyHostController = TextEditingController();
    final TextEditingController proxyPortController = TextEditingController();
    final RxBool enableProxy = false.obs;

    // 获取当前 API 地址
    final currentApiUrl = dotenv.env['API_URL'] ?? '';
    apiUrlController.text = currentApiUrl;

    // 加载保存的代理配置
    _loadProxyConfig().then((config) {
      enableProxy.value = config['enabled'] ?? false;
      proxyHostController.text = config['host'] ?? '';
      proxyPortController.text = config['port']?.toString() ?? '';
    });

    Get.dialog(
      AlertDialog(
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        title: Row(
          children: [
            Text('开发者选项', style: TextStyle(fontSize: 16.sp)),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                _env.toUpperCase(),
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          height: 350.h, // 设置最大高度，使用屏幕适配
          width: 300.w, // 设置宽度，防止内容过宽，使用屏幕适配
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // API 地址配置
                Text(
                  '1. 修改 API 地址',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '修改后将退出登录，下次请求将使用新地址',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 12.h),
                TextField(
                  controller: apiUrlController,
                  decoration: InputDecoration(
                    labelText: 'API 地址',
                    hintText: 'https://example.com/api',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    prefixIcon: const Icon(Icons.link),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                  ),
                  keyboardType: TextInputType.url,
                  style: TextStyle(fontSize: 12.sp),
                ),
                SizedBox(height: 8.h),
                Text(
                  '当前地址：$currentApiUrl',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey,
                  ),
                ),

                SizedBox(height: 12.h),
                Divider(height: 1.h),
                SizedBox(height: 12.h),

                // 抓包代理配置
                Text(
                  '2. 抓包代理配置',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '配置抓包代理后，所有请求将通过代理发送',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 12.h),

                // 启用代理开关
                Obx(() => SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        '启用代理',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      value: enableProxy.value,
                      onChanged: (value) {
                        enableProxy.value = value;
                      },
                      dense: true, // 让开关更紧凑
                      materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap, // 减小点击区域
                    )),

                SizedBox(height: 12.h),

                // 代理地址
                Obx(() => TextField(
                      controller: proxyHostController,
                      enabled: enableProxy.value,
                      decoration: InputDecoration(
                        labelText: '代理地址',
                        hintText: '例如：192.168.1.100',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        prefixIcon: const Icon(Icons.dns),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                      ),
                      keyboardType: TextInputType.url,
                      style: TextStyle(fontSize: 12.sp),
                    )),

                SizedBox(height: 12.h),

                // 代理端口
                Obx(() => TextField(
                      controller: proxyPortController,
                      enabled: enableProxy.value,
                      decoration: InputDecoration(
                        labelText: '代理端口',
                        hintText: '例如：8888',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        prefixIcon: const Icon(Icons.numbers),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: 12.sp),
                    )),

                SizedBox(height: 8.h),
                Text(
                  '提示：常用抓包工具端口 Charles(8888)、Fiddler(8888)、Proxyman(9090)',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  // 先移除焦点，避免关闭时访问已销毁的 controller
                  FocusManager.instance.primaryFocus?.unfocus();
                  // 延迟关闭，确保焦点完全释放
                  Future.delayed(const Duration(milliseconds: 100), () {
                    Get.back();
                    apiUrlController.dispose();
                    proxyHostController.dispose();
                    proxyPortController.dispose();
                  });
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                ),
                child: Text('取消', style: TextStyle(fontSize: 12.sp)),
              ),
              SizedBox(width: 8.w),
              TextButton(
                onPressed: () {
                  // 先移除焦点
                  FocusManager.instance.primaryFocus?.unfocus();
                  Future.delayed(const Duration(milliseconds: 100), () {
                    _resetToDefaultConfig();
                    apiUrlController.dispose();
                    proxyHostController.dispose();
                    proxyPortController.dispose();
                  });
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                ),
                child: Text('恢复默认', style: TextStyle(fontSize: 12.sp)),
              ),
              SizedBox(width: 8.w),
              ElevatedButton(
                onPressed: () {
                  final newApiUrl = apiUrlController.text.trim();
                  if (newApiUrl.isEmpty) {
                    EasyLoading.showToast('请输入 API 地址');
                    return;
                  }

                  // 验证代理配置
                  if (enableProxy.value) {
                    final proxyHost = proxyHostController.text.trim();
                    final proxyPort = proxyPortController.text.trim();
                    if (proxyHost.isEmpty || proxyPort.isEmpty) {
                      EasyLoading.showToast('请完整填写代理配置');
                      return;
                    }
                    final port = int.tryParse(proxyPort);
                    if (port == null || port < 1 || port > 65535) {
                      EasyLoading.showToast('端口号必须在 1-65535 之间');
                      return;
                    }
                  }

                  // 先移除焦点
                  FocusManager.instance.primaryFocus?.unfocus();
                  Future.delayed(const Duration(milliseconds: 100), () {
                    _applyConfig(
                      newApiUrl,
                      enableProxy.value,
                      proxyHostController.text.trim(),
                      proxyPortController.text.trim(),
                    );
                    apiUrlController.dispose();
                    proxyHostController.dispose();
                    proxyPortController.dispose();
                  });
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                ),
                child: Text('应用配置', style: TextStyle(fontSize: 12.sp)),
              ),
            ],
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// 加载代理配置
  Future<Map<String, dynamic>> _loadProxyConfig() async {
    final enabled = await Storage.getString(StorageKeys.proxyEnabled) != null
        ? await Storage.getBool(StorageKeys.proxyEnabled)
        : false;
    final host = await Storage.getString(StorageKeys.proxyHost);
    final port = await Storage.getInt(StorageKeys.proxyPort);

    return {
      'enabled': enabled,
      'host': host,
      'port': port,
    };
  }

  /// 应用配置
  Future<void> _applyConfig(
    String apiUrl,
    bool enableProxy,
    String proxyHost,
    String proxyPort,
  ) async {
    Get.back(); // 关闭弹窗

    // 保存 API 地址
    await Storage.setString(StorageKeys.customApiUrl, apiUrl);

    // 保存代理配置
    await Storage.setBool(StorageKeys.proxyEnabled, enableProxy);
    if (enableProxy) {
      await Storage.setString(StorageKeys.proxyHost, proxyHost);
      await Storage.setInt(StorageKeys.proxyPort, int.parse(proxyPort));
    } else {
      await Storage.remove(StorageKeys.proxyHost);
      await Storage.remove(StorageKeys.proxyPort);
    }

    EasyLoading.showToast('配置已保存，正在退出登录...');

    // 延迟退出登录，让用户看到提示
    Future.delayed(const Duration(seconds: 1), () async {
      await Storage.remove(StorageKeys.token);
      await Storage.remove(StorageKeys.userInfo);
      if (Get.isRegistered<IndexLogic>()) {
        Get.find<IndexLogic>().updateToken('');
      }

      // 重启应用以使新配置生效
      Get.offAllNamed(AppRoutes.guide);
    });
  }

  /// 恢复默认配置
  Future<void> _resetToDefaultConfig() async {
    Get.back(); // 关闭弹窗

    // 删除自定义配置
    await Storage.remove(StorageKeys.customApiUrl);
    await Storage.remove(StorageKeys.proxyEnabled);
    await Storage.remove(StorageKeys.proxyHost);
    await Storage.remove(StorageKeys.proxyPort);

    EasyLoading.showToast('已恢复默认配置，正在退出登录...');

    Future.delayed(const Duration(seconds: 1), () async {
      await Storage.remove(StorageKeys.token);
      await Storage.remove(StorageKeys.userInfo);
      if (Get.isRegistered<IndexLogic>()) {
        Get.find<IndexLogic>().updateToken('');
      }

      // 重启应用
      Get.offAllNamed(AppRoutes.guide);
    });
  }
}
