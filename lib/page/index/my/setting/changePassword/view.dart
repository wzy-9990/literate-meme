import 'package:flutter/material.dart';
import 'package:flutter_tem/components/BaseLoading/index.dart';
import 'package:flutter_tem/page/index/my/setting/changePassword/logic.dart';
import 'package:get/get.dart';

class ChangePasswordView extends StatelessWidget {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final logic = Get.find<ChangePasswordLogic>();
    return Scaffold(
      appBar: AppBar(title: const Text('修改密码')),
      body: Stack(
        children: [
          const Text('修改密码'),
          ElevatedButton(
                onPressed: () {
                  logic.updateLastUserInfo();
                },
                child: const Text('刷新上级数据'),
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
