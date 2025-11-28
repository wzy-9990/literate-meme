import 'package:flutter/material.dart';
import 'package:flutter_tem/components/BaseAppBar/index.dart';
import 'package:flutter_tem/components/BaseLoading/index.dart';
import 'package:flutter_tem/page/index/modules/my/setting/logic.dart';
import 'package:flutter_tem/utils/logic/base/mixin/page_visibility_mixin.dart';
import 'package:get/get.dart';

class MySettingView extends StatelessWidget {
  const MySettingView({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<MySettingLogic>();

    // ⭐ 使用 PageVisibilityWrapper 包裹，启用页面可见性监听
    return PageVisibilityWrapper(
      controller: logic,
      child: Scaffold(
      appBar: const BaseAppBar(title: '设置'),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 16),
              // 页面可见性测试提示
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.visibility, color: Colors.blue[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '页面可见性测试',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '✅ 已启用 PageVisibilityMixin',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '📍 查看控制台日志观察生命周期',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Center(child: Text('这里是设置页面')),
              Obx(
                () {
                  return Text(logic.userInfo['userName'].toString());
                },
              ),
              ElevatedButton(
                onPressed: () {
                  logic.updateUserInfo('1927611258292748290');
                },
                child: const Text('更新用户信息'),
              ),
              ElevatedButton(
                onPressed: () {
                  logic.changePassword();
                },
                child: const Text('修改密码'),
              ),
              ElevatedButton(
                child: const Text('退出'),
                onPressed: () async {
                  logic.logout();
                },
              ),
              const SizedBox(height: 30),
              // 版本号区域（连续点击7次进入开发者选项）
              GestureDetector(
                onTap: logic.onVersionTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '版本号 v1.0.0',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Obx(
            () {
              return logic.isLoading.value
                  ? const BaseLoading()
                  : const SizedBox.shrink();
            },
          )
        ],
      ),
      ),
    ); // PageVisibilityWrapper
  }
}
