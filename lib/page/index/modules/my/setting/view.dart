import 'package:flutter/material.dart';
import 'package:flutter_tem/components/BaseAppBar/index.dart';
import 'package:flutter_tem/components/BaseLoading/index.dart';
import 'package:flutter_tem/page/index/modules/my/setting/logic.dart';
import 'package:get/get.dart';

class MySettingView extends StatelessWidget {
  const MySettingView({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final logic = Get.find<MySettingLogic>();
    return Scaffold(
      appBar: const BaseAppBar(title: '设置'),
      body: Stack(
        children: [
          Column(
            children: [
              const Center(child: Text('这里是设置页面')),
              Obx(
                () {
                  return Text(logic.userInfo['userName'].toString());
                },
              ),
              ElevatedButton(
                onPressed: () {
                  logic.updateUserInfo('1');
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
    );
  }
}
