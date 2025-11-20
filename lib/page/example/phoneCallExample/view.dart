import 'package:flutter/material.dart';
import 'package:flutter_tem/components/BaseAppBar/index.dart';
import 'package:flutter_tem/components/BasePhoneCall/index.dart';

/// 打电话示例页面
class PhoneCallExamplePage extends StatelessWidget {
  const PhoneCallExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BaseAppBar(title: '打电话示例'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 说明卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '平台差异说明',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPlatformInfo('iOS', '直接拨打电话'),
                  const SizedBox(height: 8),
                  _buildPlatformInfo('Android', '显示底部弹窗，二次确认后拨打'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 联系人列表
          const Text(
            '联系人列表',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          _buildContactCard(
            context,
            name: '张三',
            phone: '13812345678',
            icon: Icons.person,
            color: Colors.blue,
          ),
          const SizedBox(height: 12),

          _buildContactCard(
            context,
            name: '李四',
            phone: '138 1234 5678',
            icon: Icons.person_outline,
            color: Colors.green,
          ),
          const SizedBox(height: 12),

          _buildContactCard(
            context,
            name: '王五',
            phone: '138-1234-5678',
            icon: Icons.account_circle,
            color: Colors.orange,
          ),
          const SizedBox(height: 12),

          _buildContactCard(
            context,
            name: '赵六',
            phone: '(138) 1234-5678',
            icon: Icons.account_box,
            color: Colors.purple,
          ),
          const SizedBox(height: 20),

          // 功能演示
          const Text(
            '功能演示',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // 自定义拨号按钮
          ElevatedButton.icon(
            onPressed: () {
              BasePhoneCall.makePhoneCall(context, '10086');
            },
            icon: const Icon(Icons.phone),
            label: const Text('拨打客服电话 10086'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 12),

          // 紧急电话
          ElevatedButton.icon(
            onPressed: () {
              BasePhoneCall.makePhoneCall(context, '110');
            },
            icon: const Icon(Icons.emergency),
            label: const Text('拨打紧急电话 110'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建平台信息行
  Widget _buildPlatformInfo(String platform, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: platform == 'iOS' ? Colors.blue[100] : Colors.green[100],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            platform,
            style: TextStyle(
              color: platform == 'iOS' ? Colors.blue[900] : Colors.green[900],
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            description,
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  /// 构建联系人卡片
  Widget _buildContactCard(
    BuildContext context, {
    required String name,
    required String phone,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          BasePhoneCall.formatPhoneNumber(phone),
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.phone),
          color: Colors.green,
          iconSize: 28,
          onPressed: () {
            BasePhoneCall.makePhoneCall(context, phone);
          },
        ),
      ),
    );
  }
}
