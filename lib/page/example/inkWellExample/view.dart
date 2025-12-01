import 'package:flutter/material.dart';
import 'package:flutter_tem/components/BaseToastLoading/index.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_tem/components/BaseToastLoading/index.dart';
import 'package:flutter_tem/components/BaseAppBar/index.dart';
import 'package:flutter_tem/components/BaseToastLoading/index.dart';
import 'package:flutter_tem/components/BaseInkWell/index.dart';
import 'package:flutter_tem/components/BaseToastLoading/index.dart';
import 'package:flutter_tem/config/styles/index.dart';
import 'package:flutter_tem/components/BaseToastLoading/index.dart';

/// 水波纹组件示例页面
class InkWellExampleView extends StatelessWidget {
  const InkWellExampleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BaseAppBar(
        title: '水波纹组件示例',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 示例1：基础水波纹
            _buildSectionTitle('示例1：基础水波纹'),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              '点击查看默认水波纹效果',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            BaseInkWell(
              onTap: () => BaseToastLoading.showToast('基础水波纹点击'),
              padding: const EdgeInsets.all(AppSpacing.base),
              backgroundColor: AppColors.surface,
              child: const Row(
                children: [
                  Icon(Icons.touch_app, color: AppColors.primary),
                  SizedBox(width: AppSpacing.sm),
                  Text('点击我查看水波纹效果'),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // 示例2：圆角水波纹
            _buildSectionTitle('示例2：圆角水波纹'),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              '带圆角的水波纹效果',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            BaseInkWell(
              onTap: () => BaseToastLoading.showToast('圆角水波纹点击'),
              borderRadius: AppRadius.baseRadius,
              padding: const EdgeInsets.all(AppSpacing.base),
              backgroundColor: AppColors.primaryOpacity10,
              child: const Center(
                child: Text(
                  '圆角卡片样式',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // 示例3：卡片快捷方式
            _buildSectionTitle('示例3：卡片样式（快捷构造）'),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              '使用 BaseInkWell.card() 快捷创建',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            BaseInkWell.card(
              onTap: () => BaseToastLoading.showToast('卡片点击'),
              padding: const EdgeInsets.all(AppSpacing.base),
              backgroundColor: AppColors.surface,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.credit_card, color: AppColors.primary),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        '卡片标题',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    '这是一个使用卡片样式的水波纹组件，自动应用卡片圆角',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // 示例4：自定义颜色
            _buildSectionTitle('示例4：自定义水波纹颜色'),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              '自定义水波纹和高亮颜色',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: BaseInkWell(
                    onTap: () => BaseToastLoading.showToast('成功色水波纹'),
                    borderRadius: AppRadius.baseRadius,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    backgroundColor: AppColors.success,
                    splashColor: Colors.white.withOpacity(0.3),
                    child: const Center(
                      child: Text(
                        '成功',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: BaseInkWell(
                    onTap: () => BaseToastLoading.showToast('警告色水波纹'),
                    borderRadius: AppRadius.baseRadius,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    backgroundColor: AppColors.warning,
                    splashColor: Colors.white.withOpacity(0.3),
                    child: const Center(
                      child: Text(
                        '警告',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),

            // 示例5：禁用水波纹
            _buildSectionTitle('示例5：禁用水波纹'),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'enableRipple: false',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            BaseInkWell(
              onTap: () => BaseToastLoading.showToast('无水波纹点击'),
              enableRipple: false,
              borderRadius: AppRadius.baseRadius,
              padding: const EdgeInsets.all(AppSpacing.base),
              backgroundColor: AppColors.surface,
              child: const Center(
                child: Text('点击无水波纹效果'),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // 示例6：圆形按钮
            _buildSectionTitle('示例6：圆形按钮'),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              '使用 BaseInkWell.circle() 创建圆形按钮',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCircleButton(
                  icon: Icons.favorite,
                  color: AppColors.error,
                  onTap: () => BaseToastLoading.showToast('点赞'),
                ),
                _buildCircleButton(
                  icon: Icons.share,
                  color: AppColors.info,
                  onTap: () => BaseToastLoading.showToast('分享'),
                ),
                _buildCircleButton(
                  icon: Icons.download,
                  color: AppColors.success,
                  onTap: () => BaseToastLoading.showToast('下载'),
                ),
                _buildCircleButton(
                  icon: Icons.more_horiz,
                  color: AppColors.textSecondary,
                  onTap: () => BaseToastLoading.showToast('更多'),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),

            // 示例7：列表项
            _buildSectionTitle('示例7：列表项'),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              '常用于列表项点击',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.baseRadius,
              ),
              child: Column(
                children: [
                  _buildListItem(
                    icon: Icons.person,
                    title: '个人信息',
                    subtitle: '编辑你的个人资料',
                    onTap: () => BaseToastLoading.showToast('个人信息'),
                  ),
                  const Divider(height: 1),
                  _buildListItem(
                    icon: Icons.settings,
                    title: '设置',
                    subtitle: '应用设置和偏好',
                    onTap: () => BaseToastLoading.showToast('设置'),
                  ),
                  const Divider(height: 1),
                  _buildListItem(
                    icon: Icons.help,
                    title: '帮助与反馈',
                    subtitle: '获取帮助或提供反馈',
                    onTap: () => BaseToastLoading.showToast('帮助与反馈'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // 使用说明
            _buildUsageGuide(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return BaseInkWell.circle(
      onTap: onTap,
      backgroundColor: color.withOpacity(0.1),
      child: Container(
        width: 56,
        height: 56,
        alignment: Alignment.center,
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  Widget _buildListItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return BaseInkWell(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryOpacity10,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }

  Widget _buildUsageGuide() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.baseRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '组件特性',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildFeatureItem('✅ 自定义圆角半径'),
          _buildFeatureItem('✅ 可控制的水波纹效果'),
          _buildFeatureItem('✅ 自定义水波纹颜色'),
          _buildFeatureItem('✅ 支持长按、双击事件'),
          _buildFeatureItem('✅ 快捷构造函数（card、circle）'),
          _buildFeatureItem('✅ 灵活的内外边距设置'),
          _buildFeatureItem('✅ 使用项目样式系统'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
