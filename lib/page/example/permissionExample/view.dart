import 'package:flutter/material.dart';
import 'package:flutter_tem/utils/permission/index.dart';
import 'package:permission_handler/permission_handler.dart';

/// 权限工具示例页面
class PermissionExampleView extends StatelessWidget {
  const PermissionExampleView({super.key});

  /// 拍照示例
  Future<void> _takePhoto() async {
    final granted = await PermissionUtil.requestCamera(
      tip: '需要相机权限以拍摄照片',
    );

    if (granted) {
      debugPrint('✅ 相机权限已授予，可以打开相机');
      // TODO: 打开相机拍照
    } else {
      debugPrint('❌ 相机权限被拒绝');
    }
  }

  /// 选择照片示例
  Future<void> _pickPhoto() async {
    final granted = await PermissionUtil.requestPhotos(
      tip: '需要访问相册以选择照片',
    );

    if (granted) {
      debugPrint('✅ 相册权限已授予，可以选择照片');
      // TODO: 打开相册选择照片
    } else {
      debugPrint('❌ 相册权限被拒绝');
    }
  }

  /// 获取位置示例
  Future<void> _getLocation() async {
    await PermissionUtil.checkAndExecute(
      Permission.location,
      onGranted: () {
        debugPrint('✅ 位置权限已授予，开始获取位置');
        // TODO: 获取位置信息
      },
      onDenied: () {
        debugPrint('❌ 位置权限被拒绝');
      },
      tipMessage: '需要位置权限以提供附近的服务',
    );
  }

  /// 录制音频示例
  Future<void> _recordAudio() async {
    final granted = await PermissionUtil.requestMicrophone(
      tip: '需要麦克风权限以录制音频',
    );

    if (granted) {
      debugPrint('✅ 麦克风权限已授予，可以录音');
      // TODO: 开始录音
    } else {
      debugPrint('❌ 麦克风权限被拒绝');
    }
  }

  /// 录制视频示例（需要相机+麦克风）
  Future<void> _recordVideo() async {
    final results = await PermissionUtil.requestMultiplePermissions([
      Permission.camera,
      Permission.microphone,
    ]);

    final allGranted = results.values.every((granted) => granted);
    if (allGranted) {
      debugPrint('✅ 所有权限已授予，可以录制视频');
      // TODO: 开始录制视频
    } else {
      debugPrint('❌ 部分权限未授予');
      results.forEach((permission, granted) {
        final name = PermissionUtil.getPermissionName(permission);
        debugPrint('$name: ${granted ? "已授予" : "被拒绝"}');
      });
    }
  }

  /// 保存文件示例
  Future<void> _saveFile() async {
    final granted = await PermissionUtil.requestStorage(
      tip: '需要相册权限以保存图片到相册',
    );

    if (granted) {
      debugPrint('✅ 相册权限已授予，可以保存图片');
      // TODO: 保存图片到相册
      // 提示：在 Android 13+ 上，这个方法会请求 photos 权限
      // 如果需要保存视频，请使用 PermissionUtil.requestVideos()
      // 如果只需要保存到应用目录，不需要任何权限
    } else {
      debugPrint('❌ 相册权限被拒绝');
    }
  }

  /// 开启通知示例
  Future<void> _enableNotification() async {
    final granted = await PermissionUtil.requestNotification(
      tip: '需要通知权限以接收消息提醒',
    );

    if (granted) {
      debugPrint('✅ 通知权限已授予');
      // TODO: 开启推送通知
    } else {
      debugPrint('❌ 通知权限被拒绝');
    }
  }

  /// 检查权限状态
  Future<void> _checkCameraStatus() async {
    final status = await PermissionUtil.checkPermission(Permission.camera);

    String statusText;
    if (status.isGranted) {
      statusText = '已授予';
    } else if (status.isDenied) {
      statusText = '已拒绝';
    } else if (status.isPermanentlyDenied) {
      statusText = '永久拒绝';
    } else if (status.isRestricted) {
      statusText = '受限';
    } else if (status.isLimited) {
      statusText = '受限访问（iOS 14+）';
    } else {
      statusText = '未知';
    }

    debugPrint('📱 相机权限状态：$statusText');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('权限工具示例'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSection(
            title: '单个权限请求',
            children: [
              _buildButton(
                label: '拍照（相机权限）',
                icon: Icons.camera_alt,
                onPressed: _takePhoto,
              ),
              const SizedBox(height: 12),
              _buildButton(
                label: '选择照片（相册权限）',
                icon: Icons.photo_library,
                onPressed: _pickPhoto,
              ),
              const SizedBox(height: 12),
              _buildButton(
                label: '获取位置（位置权限）',
                icon: Icons.location_on,
                onPressed: _getLocation,
              ),
              const SizedBox(height: 12),
              _buildButton(
                label: '录制音频（麦克风权限）',
                icon: Icons.mic,
                onPressed: _recordAudio,
              ),
              const SizedBox(height: 12),
              _buildButton(
                label: '保存图片（相册权限）',
                icon: Icons.save,
                onPressed: _saveFile,
              ),
              const SizedBox(height: 12),
              _buildButton(
                label: '开启通知（通知权限）',
                icon: Icons.notifications,
                onPressed: _enableNotification,
              ),
            ],
          ),
          const SizedBox(height: 30),
          _buildSection(
            title: '批量权限请求',
            children: [
              _buildButton(
                label: '录制视频（相机 + 麦克风）',
                icon: Icons.videocam,
                onPressed: _recordVideo,
                color: Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 30),
          _buildSection(
            title: '权限状态检查',
            children: [
              _buildButton(
                label: '检查相机权限状态',
                icon: Icons.info_outline,
                onPressed: _checkCameraStatus,
                color: Colors.blue,
              ),
            ],
          ),
          const SizedBox(height: 30),
          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text(
                '使用说明',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoItem('1. 点击按钮会触发权限请求'),
          _buildInfoItem('2. 首次请求会显示系统权限弹窗'),
          _buildInfoItem('3. Android 会显示顶部权限说明提示'),
          _buildInfoItem('4. 永久拒绝后会引导跳转设置'),
          _buildInfoItem('5. 查看控制台日志了解权限状态'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange[700], size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Android 13+ 权限变更',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '存储权限 (storage) 已废弃，现使用:\n'
                  '• photos - 访问图片\n'
                  '• videos - 访问视频\n'
                  '• audio - 访问音频',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
