import 'package:flutter/material.dart';
import 'package:flutter_tem/components/BaseDoubleBackExitWrapper/index.dart';
import 'package:flutter_tem/page/index/home/view.dart';
import 'package:flutter_tem/page/index/logic.dart';
import 'package:flutter_tem/page/index/message/view.dart';
import 'package:flutter_tem/page/index/my/view.dart';
import 'package:get/get.dart';

class IndexView extends GetView<IndexLogic> {
  const IndexView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseDoubleBackExitWrapper(
      child: Obx(() {
        return Scaffold(
          body: IndexedStack(
            index: controller.currentIndex.value,
            children: const [
              HomeView(),
              MessageView(),
              MyView(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.changeTab,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
              BottomNavigationBarItem(icon: Icon(Icons.message), label: '消息'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
            ],
            // 样式已在全局主题中配置，无需重复设置
          ),
        );
      }),
    );
  }
}
