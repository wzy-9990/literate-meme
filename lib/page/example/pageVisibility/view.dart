import 'package:flutter/material.dart';
import 'package:flutter_tem/components/BaseAppBar/index.dart';
import 'package:flutter_tem/page/example/pageVisibility/logic.dart';
import 'package:flutter_tem/utils/logic/base/mixin/page_visibility_mixin.dart';
import 'package:get/get.dart';

/// 页面可见性示例页面
///
/// 演示页面显示/隐藏的生命周期监听
class PageVisibilityExamplePage extends GetView<PageVisibilityExampleLogic> {
  const PageVisibilityExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    // ⭐ 关键：使用 PageVisibilityWrapper 包裹整个页面
    return PageVisibilityWrapper(
      controller: controller,
      child: Scaffold(
        appBar: const BaseAppBar(title: '页面可见性示例'),
        body: Center(
          child: GetBuilder<PageVisibilityExampleLogic>(
            builder: (logic) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.visibility,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 24),
                const Text(
                  '页面可见性监听示例',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '页面显示次数：${logic.counter}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 32),
                _buildInfoCard(),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: logic.navigateToDetail,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('跳转测试（会触发 onHide）'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '生命周期说明：',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildLifecycleItem(
              '👀 onShow',
              '页面显示时触发（包括返回）',
            ),
            const SizedBox(height: 8),
            _buildLifecycleItem(
              '🙈 onHide',
              '页面隐藏时触发（跳转其他页面）',
            ),
            const SizedBox(height: 8),
            _buildLifecycleItem(
              '📍 onLoad',
              '页面首次加载时触发（只执行一次）',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLifecycleItem(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            description,
            style: TextStyle(
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }
}
