import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_tem/routers/app_routes.dart';
import 'package:flutter_tem/utils/storage/index.dart';
import 'package:get/get.dart';

/// 开发者选项组件
///
/// 提供连续点击进入开发者选项的功能
/// 支持修改 API 地址和配置抓包代理
/// 生产环境自动禁用
class DeveloperOptions {
  // 连续点击计数器
  int _clickCount = 0;
  DateTime? _lastClickTime;
  static const int _maxClickCount = 7; // 需要连续点击7次
  static const Duration _clickInterval = Duration(seconds: 2); // 2秒内点击有效

  /// 当前环境
  static const String _env = String.fromEnvironment('ENV', defaultValue: 'development');

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
        title: Row(
          children: [
            const Text('开发者选项'),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _env.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // API 地址配置
              const Text(
                '1. 修改 API 地址',
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
              const SizedBox(height: 12),
              TextField(
                controller: apiUrlController,
                decoration: const InputDecoration(
                  labelText: 'API 地址',
                  hintText: 'https://example.com/api',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                  isDense: true,
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 8),
              Text(
                '当前地址：$currentApiUrl',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // 抓包代理配置
              const Text(
                '2. 抓包代理配置',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '配置抓包代理后，所有请求将通过代理发送',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),

              // 启用代理开关
              Obx(() => SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      '启用代理',
                      style: TextStyle(fontSize: 14),
                    ),
                    value: enableProxy.value,
                    onChanged: (value) {
                      enableProxy.value = value;
                    },
                  )),

              const SizedBox(height: 12),

              // 代理地址
              TextField(
                controller: proxyHostController,
                enabled: enableProxy.value,
                decoration: const InputDecoration(
                  labelText: '代理地址',
                  hintText: '例如：192.168.1.100',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.dns),
                  isDense: true,
                ),
                keyboardType: TextInputType.url,
              ),

              const SizedBox(height: 12),

              // 代理端口
              TextField(
                controller: proxyPortController,
                enabled: enableProxy.value,
                decoration: const InputDecoration(
                  labelText: '代理端口',
                  hintText: '例如：8888',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 8),
              const Text(
                '提示：常用抓包工具端口 Charles(8888)、Fiddler(8888)、Proxyman(9090)',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              apiUrlController.dispose();
              proxyHostController.dispose();
              proxyPortController.dispose();
              Get.back();
            },
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              apiUrlController.dispose();
              proxyHostController.dispose();
              proxyPortController.dispose();
              _resetToDefaultConfig();
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

              apiUrlController.dispose();
              _applyConfig(
                newApiUrl,
                enableProxy.value,
                proxyHostController.text.trim(),
                proxyPortController.text.trim(),
              );
              proxyHostController.dispose();
              proxyPortController.dispose();
            },
            child: const Text('应用配置'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// 加载代理配置
  Future<Map<String, dynamic>> _loadProxyConfig() async {
    final enabled = await Storage.getBool('proxy_enabled') ?? false;
    final host = await Storage.getString('proxy_host');
    final port = await Storage.getInt('proxy_port');

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
    await Storage.setString('custom_api_url', apiUrl);

    // 保存代理配置
    await Storage.setBool('proxy_enabled', enableProxy);
    if (enableProxy) {
      await Storage.setString('proxy_host', proxyHost);
      await Storage.setInt('proxy_port', int.parse(proxyPort));
    } else {
      await Storage.remove('proxy_host');
      await Storage.remove('proxy_port');
    }

    EasyLoading.showToast('配置已保存，正在退出登录...');

    // 延迟退出登录，让用户看到提示
    Future.delayed(const Duration(seconds: 1), () async {
      await Storage.remove(StorageKeys.token);
      await Storage.remove(StorageKeys.userInfo);

      // 重启应用以使新配置生效
      Get.offAllNamed(AppRoutes.guide);
    });
  }

  /// 恢复默认配置
  Future<void> _resetToDefaultConfig() async {
    Get.back(); // 关闭弹窗

    // 删除自定义配置
    await Storage.remove('custom_api_url');
    await Storage.remove('proxy_enabled');
    await Storage.remove('proxy_host');
    await Storage.remove('proxy_port');

    EasyLoading.showToast('已恢复默认配置，正在退出登录...');

    Future.delayed(const Duration(seconds: 1), () async {
      await Storage.remove(StorageKeys.token);
      await Storage.remove(StorageKeys.userInfo);

      // 重启应用
      Get.offAllNamed(AppRoutes.guide);
    });
  }
}
