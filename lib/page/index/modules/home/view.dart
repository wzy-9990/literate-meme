import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tem/components/BaseActionSheet/index.dart';
import 'package:flutter_tem/components/BaseAppBar/index.dart';
import 'package:flutter_tem/components/BaseButton/index.dart';
import 'package:flutter_tem/components/BaseCascader/index.dart';
import 'package:flutter_tem/components/BaseCheckbox/index.dart';
import 'package:flutter_tem/components/BaseCupertinoAlertDialog/index.dart';
import 'package:flutter_tem/components/BaseDatePicker/index.dart';
import 'package:flutter_tem/components/BaseOperationCell/index.dart';
import 'package:flutter_tem/components/BaseRadio/index.dart';
import 'package:flutter_tem/components/BaseSkeleton/index.dart';
import 'package:flutter_tem/components/BaseTab/index.dart';
import 'package:flutter_tem/components/BaseText/index.dart';
import 'package:flutter_tem/page/index/modules/home/logic.dart';
import 'package:flutter_tem/utils/modules/dict/home.dart';
import 'package:get/get.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  void _showOperationSheet(BuildContext context) {
    final nameController = TextEditingController();
    String city = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SafeArea(
              top: false,
              child: Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                  top: 12,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Text(
                            '操作设置',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: BaseOperationCellGroup(
                        radius: 12,
                        backgroundColor: const Color(0xFFF7F7F7),
                        children: [
                          BaseOperationCell(
                            label: '姓名',
                            required: true,
                            hintText: '请输入姓名',
                            controller: nameController,
                            onChanged: (v) =>
                                Get.find<HomeLogic>().updateName(v),
                          ),
                          BaseOperationCell(
                            label: '城市',
                            mode: BaseOperationCellMode.select,
                            hintText: '请选择城市',
                            value: city,
                            onSelect: () {
                              setState(() {
                                city = city == '上海' ? '北京' : '上海';
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('取消'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Get.snackbar(
                                  '提交',
                                  '姓名：${nameController.text}，城市：${city.isEmpty ? '未选择' : city}',
                                );
                              },
                              child: const Text('保存'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

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
            const BaseSkeleton(),
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
                BaseButton(
                  text: '短字',
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  onTap: () => Get.snackbar('BaseButton', '短字'),
                ),
                BaseButton(
                  text: '较长一些的',
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  onTap: () => Get.snackbar('BaseButton', '较长一些'),
                ),
                BaseButton(
                  text: '超长按钮',
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  onTap: () => Get.snackbar('BaseButton', '超长文字'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Tab 示例'),
            Obx(() => BaseTab(
                  options: directionTypeEnum.allItems,
                  labelField: 'label',
                  valueField: 'value',
                  value: logic.tabValue.value,
                  onChanged: (v) => logic.updateTabValue(v),
                )),
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
            const SizedBox(height: 12),
            const Text('隐私协议（勾选框）'),
            Obx(() {
              final agreed = logic.privacyAgree.value;
              return BaseCheckboxGroup<int>(
                asButton: false,
                options: const [
                  {'label': '已阅读并同意隐私协议', 'value': 1},
                ],
                values: agreed ? const [1] : const [],
                valueField: 'value',
                labelField: 'label',
                iconSize: 22,
                iconOnly: false,
                removeChipBorder: true,
                disableInk: true,
                showLabel: true,
                onChanged: (list) => logic.updatePrivacyAgree(list.contains(1)),
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
            ElevatedButton(
              onPressed: () {
                logic.appIconExampleView();
              },
              child: const Text('App 图标切换'),
            ),
            const SizedBox(height: 20),
            const Text('Operation Cell 示例'),
            BaseOperationCellGroup(
              radius: 12,
              backgroundColor: Colors.white,
              children: [
                BaseOperationCell(
                  label: '姓名',
                  required: true,
                  value: logic.name.value,
                  controller: logic.nameController,
                  onChanged: logic.updateName,
                ),
                BaseOperationCell(
                  label: '城市',
                  mode: BaseOperationCellMode.select,
                  value: logic.selectValue.value,
                  onSelect: () => Get.snackbar('选择', '点击了城市选择'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _showOperationSheet(context),
              child: const Text('打开操作单元格弹窗'),
            ),
            const SizedBox(height: 12),
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
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final res = await showBaseDatePicker(
                  context,
                  title: '选择日期',
                  mode: BaseDatePickerMode.date,
                );
                if (res != null) {
                  Get.snackbar('日期', res.toString());
                }
              },
              child: const Text('测试 Date Picker'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final selected = await showBasePicker(
                  context,
                  title: '请选择方向',
                  options: directionTypeEnum.allItems,
                );
                if (selected != null) {
                  Get.snackbar('Picker', '选择了 ${selected['label']}');
                }
              },
              child: const Text('测试 Picker'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                showBaseCupertinoAlertDialog(
                  context,
                  title: '提示',
                  subtitle: '是否确认当前操作？',
                );
              },
              child: const Text('测试 CupertinoAlert'),
            ),
          ],
        ),
      ),
    );
  }
}
