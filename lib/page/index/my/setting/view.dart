import 'package:flutter/material.dart';
import 'package:flutter_tem/components/BaseLoading/index.dart';
import 'package:flutter_tem/page/index/my/setting/logic.dart';
import 'package:get/get.dart';

class MySettingView extends StatelessWidget {
  const MySettingView({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final logic = Get.find<MySettingLogic>();
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
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
