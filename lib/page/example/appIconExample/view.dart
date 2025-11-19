import 'package:flutter/material.dart';
import 'package:flutter_tem/components/BaseAppBar/index.dart';
import 'package:flutter_tem/theme/app_icons.dart';
import 'package:flutter_tem/utils/app_icon_manager/index.dart';

/// App 图标切换示例页面
class AppIconExamplePage extends StatefulWidget {
  const AppIconExamplePage({super.key});

  @override
  State<AppIconExamplePage> createState() => _AppIconExamplePageState();
}

class _AppIconExamplePageState extends State<AppIconExamplePage> {
  String? _currentIcon;
  bool _isSupported = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkSupport();
    _loadCurrentIcon();
  }

  /// 检查是否支持动态图标
  Future<void> _checkSupport() async {
    final supported = await AppIconManager.isSupported();
    if (mounted) {
      setState(() {
        _isSupported = supported;
      });
    }
  }

  /// 加载当前图标
  Future<void> _loadCurrentIcon() async {
    final iconName = await AppIconManager.getCurrentIconName();
    if (mounted) {
      setState(() {
        _currentIcon = iconName;
      });
    }
  }

  /// 切换图标
  Future<void> _changeIcon(String iconName) async {
    setState(() {
      _isLoading = true;
    });

    final success = await AppIconManager.changeIcon(iconName);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已切换到：${AppIconConfig.iconNames[iconName]}')),
        );
        _loadCurrentIcon();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('切换图标失败')),
        );
      }
    }
  }

  /// 根据日期自动切换
  Future<void> _changeIconByDate() async {
    setState(() {
      _isLoading = true;
    });

    final success = await AppIconManager.changeIconByDate();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (success) {
        final currentIcon = AppIconConfig.getCurrentIcon();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已根据日期切换到：${AppIconConfig.iconNames[currentIcon]}'),
          ),
        );
        _loadCurrentIcon();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('切换图标失败')),
        );
      }
    }
  }

  /// 恢复默认图标
  Future<void> _restoreDefault() async {
    await _changeIcon(AppIconConfig.defaultIcon);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BaseAppBar(title: 'App 图标切换'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 支持状态卡片
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '设备支持状态',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              _isSupported ? Icons.check_circle : Icons.cancel,
                              color: _isSupported ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isSupported
                                  ? '支持动态图标切换'
                                  : '不支持动态图标切换',
                              style: TextStyle(
                                color: _isSupported ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        if (_currentIcon != null) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.apps, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(
                                '当前图标：${AppIconConfig.iconNames[_currentIcon]}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 快速切换按钮
                const Text(
                  '快速操作',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                ElevatedButton.icon(
                  onPressed: _isSupported ? _changeIconByDate : null,
                  icon: const Icon(Icons.date_range),
                  label: const Text('根据日期自动切换'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 12),

                ElevatedButton.icon(
                  onPressed: _isSupported ? _restoreDefault : null,
                  icon: const Icon(Icons.restore),
                  label: const Text('恢复默认图标'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 20),

                // 所有图标列表
                const Text(
                  '所有可用图标',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                ...AppIconConfig.availableIcons.map((iconName) {
                  final isActive = _currentIcon == iconName;
                  final displayName = AppIconConfig.iconNames[iconName] ?? iconName;

                  // 获取该图标的日期范围
                  final dateRule = AppIconConfig.dateRules.firstWhere(
                    (rule) => rule.iconName == iconName,
                    orElse: () => AppIconConfig.dateRules.first,
                  );

                  String dateInfo = '';
                  if (iconName != AppIconConfig.defaultIcon) {
                    dateInfo =
                        ' (${dateRule.startMonth}/${dateRule.startDay} - ${dateRule.endMonth}/${dateRule.endDay})';
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      elevation: isActive ? 4 : 1,
                      color: isActive ? Colors.blue.shade50 : null,
                      child: ListTile(
                        leading: Icon(
                          isActive ? Icons.radio_button_checked : Icons.circle_outlined,
                          color: isActive ? Colors.blue : Colors.grey,
                        ),
                        title: Text(
                          displayName,
                          style: TextStyle(
                            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: dateInfo.isNotEmpty
                            ? Text(
                                '显示时间$dateInfo',
                                style: const TextStyle(fontSize: 12),
                              )
                            : null,
                        trailing: ElevatedButton(
                          onPressed: _isSupported && !isActive
                              ? () => _changeIcon(iconName)
                              : null,
                          child: Text(isActive ? '当前' : '切换'),
                        ),
                      ),
                    ),
                  );
                }).toList(),

                const SizedBox(height: 20),

                // 说明卡片
                Card(
                  color: Colors.orange.shade50,
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange),
                            SizedBox(width: 8),
                            Text(
                              '使用说明',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          '• iOS 和 Android 都支持动态图标切换\n'
                          '• 切换后需要返回主屏幕查看效果\n'
                          '• iOS 切换时会显示系统提示弹窗\n'
                          '• 可以根据日期自动切换节日图标\n'
                          '• 图标文件需要提前准备并配置',
                          style: TextStyle(fontSize: 14, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
