import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tem/components/BaseAppBar/index.dart';
import 'package:flutter_tem/components/BaseButton/index.dart';
import 'package:flutter_tem/components/BaseCascader/index.dart';
import 'package:flutter_tem/components/BaseCheckbox/index.dart';
import 'package:flutter_tem/components/BaseRadio/index.dart';
import 'package:flutter_tem/components/BaseText/index.dart';
import 'package:flutter_tem/page/index/modules/home/logic.dart';
import 'package:flutter_tem/utils/modules/dict/home.dart';
import 'package:get/get.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<HomeLogic>();

    return Scaffold(
      appBar: const BaseAppBar(
        title: '首页',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  type: BaseButtonType.info,
                  text: 'Info按钮',
                  onTap: () => Get.snackbar('BaseButton', '点击Info按钮'),
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
            const Text('单选（普通）'),
            Obx(() => BaseRadioGroup<int>(
                  options: directionTypeEnum.allItems,
                  value: logic.selectedDirection.value,
                  valueField: 'value',
                  labelField: 'label',
                  onChanged: (v) => logic.updateDirection(v),
                  onChangedWithItem: (item) {
                    Get.snackbar('单选', '选择了 ${item['label']}');
                  },
                )),
            const SizedBox(height: 12),
            const Text('单选（按钮组）'),
            Obx(() => BaseRadioGroup<int>(
                  asButton: true,
                  options: directionTypeEnum.allItems,
                  value: logic.selectedDirection.value,
                  valueField: 'value',
                  labelField: 'label',
                  onChanged: (v) => logic.updateDirection(v),
                  onChangedWithItem: (item) {
                    Get.snackbar('按钮组', '选择了 ${item['label']}');
                  },
                )),
            const SizedBox(height: 20),
            const Text('多选（按钮组）'),
            Obx(() => BaseCheckboxGroup<int>(
                  asButton: true,
                  options: directionTypeEnum.allItems,
                  values: logic.selectedDirectionMulti.toList(),
                  valueField: 'value',
                  labelField: 'label',
                  onChanged: (list) => logic.updateDirectionMulti(list),
                  onChangedWithItem: (item) {
                    Get.snackbar('多选', '选择了 ${item['label']}');
                  },
                )),
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
                );
                if (result != null) {
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
      ),
    );
  }
}
