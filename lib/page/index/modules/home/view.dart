import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tem/components/BaseAppBar/index.dart';
import 'package:flutter_tem/components/BaseButton/index.dart';
import 'package:flutter_tem/components/BaseCascader/index.dart';
import 'package:flutter_tem/components/BaseText/index.dart';
import 'package:flutter_tem/page/index/modules/home/logic.dart';
import 'package:flutter_tem/utils/modules/dict/home.dart';
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
          Text(directionTypeEnum['add_points']?['name'].toString() ?? ''),
          ...directionTypeEnum.allItems.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                item['label'].toString(),
              ),
            );
          }),
          const BaseText('chess'),
          BaseText(20.sp),
          const BaseText(
            'chess',
          ),
          const Text('chess'),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              BaseButton(
                text: '主题按钮',
                onTap: () => Get.snackbar('BaseButton', '点击主题按钮'),
              ),
              BaseButton(
                type: BaseButtonType.outline,
                text: '镂空按钮',
                onTap: () => Get.snackbar('BaseButton', '点击镂空按钮'),
              ),
              BaseButton(
                type: BaseButtonType.text,
                text: '文本按钮',
                onTap: () => Get.snackbar('BaseButton', '点击文本按钮'),
              ),
              BaseButton(
                type: BaseButtonType.gradient,
                text: '渐变按钮',
                onTap: () => Get.snackbar('BaseButton', '点击渐变按钮'),
              ),
              BaseButton(
                type: BaseButtonType.normal,
                text: '常规按钮',
                onTap: () => Get.snackbar('BaseButton', '点击常规按钮'),
              ),
              BaseButton(
                type: BaseButtonType.ghost,
                text: '朴素按钮',
                onTap: () => Get.snackbar('BaseButton', '点击朴素按钮'),
              ),
            ],
          ),
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
          ElevatedButton(
            onPressed: () {
              logic.appIconExampleView();
            },
            child: const Text('App 图标切换'),
          ),
          ElevatedButton(
            onPressed: () async {
              final result = await showCascaderPicker(
                context,

                selectableLevels: {1, 2, 3},
                // initialSelectedIds: const [
                //   'all_country',
                //   '34_all_province'
                // ], // 杭州西湖区、拱墅区
              );
              if (result != null) {
                debugPrint(result.toString());
                final names = result
                    .map((e) =>
                        '${e['provinceName'] ?? ''} ${e['cityName'] ?? ''} ${e['districtName'] ?? ''}')
                    .join('\n');
                Get.snackbar('选择结果', names);
              }
            },
            child: const Text('测试 BaseCascader'),
          ),
        ],
      ),
    );
  }
}
