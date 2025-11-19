import 'package:flutter/material.dart';
import 'package:flutter_tem/components/BaseAppBar/index.dart';
import 'package:flutter_tem/page/index/home/logic.dart';
import 'package:flutter_tem/utils/dict/home.dart';
import 'package:get/get.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final logic = Get.find<HomeLogic>();
    return Scaffold(
      appBar: const BaseAppBar(
        title: '首页',
      ),
      body: Column(
        children: [
          ...directionTypeEnum.allItems.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                item['label'].toString(),
              ),
            );
          }),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              logic.openWebView();
            },
            child: const Text('打开 WebView 示例'),
          ),
          ElevatedButton(
            onPressed: () {
              logic.pullToRefreshView();
            },
            child: const Text('打开下拉刷新上拉加载'),
          ),
          ElevatedButton(
            onPressed: () {
              logic.imageExampleView();
            },
            child: const Text('打开 BaseImage 组件示例'),
          ),
          ElevatedButton(
            onPressed: () {
              logic.permissionExampleView();
            },
            child: const Text('打开权限工具示例'),
          ),
          ElevatedButton(
            onPressed: () {
              logic.uploadExampleView();
            },
            child: const Text('打开上传组件示例'),
          ),
          ElevatedButton(
            onPressed: () {
              logic.phoneCallExampleView();
            },
            child: const Text('打电话'),
          ),
        ],
      ),
    );
  }
}
