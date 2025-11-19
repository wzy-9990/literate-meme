import 'package:flutter/material.dart';
import 'package:flutter_tem/components/BaseImage/index.dart';

/// 图片组件示例页面
class ImageExampleView extends StatelessWidget {
  const ImageExampleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BaseImage 组件示例'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: '网络图片 - 默认效果',
              child: BaseImage(
                imageUrl: 'https://picsum.photos/400/300',
                width: double.infinity,
                height: 200,
                borderRadius: 12,
              ),
            ),
            const SizedBox(height: 30),
            _buildSection(
              title: '圆形头像',
              child: Row(
                children: [
                  BaseImage(
                    imageUrl: 'https://picsum.photos/200',
                    width: 60,
                    height: 60,
                    isCircle: true,
                  ),
                  const SizedBox(width: 20),
                  BaseImage(
                    imageUrl: 'https://picsum.photos/201',
                    width: 60,
                    height: 60,
                    isCircle: true,
                  ),
                  const SizedBox(width: 20),
                  BaseImage(
                    imageUrl: 'https://picsum.photos/202',
                    width: 60,
                    height: 60,
                    isCircle: true,
                  ),
                  const SizedBox(width: 20),
                  BaseImage(
                    imageUrl: 'https://picsum.photos/203',
                    width: 60,
                    height: 60,
                    isCircle: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildSection(
              title: '不同圆角大小',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      BaseImage(
                        imageUrl: 'https://picsum.photos/300/400',
                        width: 80,
                        height: 80,
                        borderRadius: 0,
                      ),
                      const SizedBox(height: 5),
                      const Text('0', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  Column(
                    children: [
                      BaseImage(
                        imageUrl: 'https://picsum.photos/301/401',
                        width: 80,
                        height: 80,
                        borderRadius: 8,
                      ),
                      const SizedBox(height: 5),
                      const Text('8', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  Column(
                    children: [
                      BaseImage(
                        imageUrl: 'https://picsum.photos/302/402',
                        width: 80,
                        height: 80,
                        borderRadius: 16,
                      ),
                      const SizedBox(height: 5),
                      const Text('16', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  Column(
                    children: [
                      BaseImage(
                        imageUrl: 'https://picsum.photos/303/403',
                        width: 80,
                        height: 80,
                        borderRadius: 40,
                      ),
                      const SizedBox(height: 5),
                      const Text('40', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildSection(
              title: '不同裁剪模式 (BoxFit)',
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildFitExample('cover', BoxFit.cover),
                      _buildFitExample('contain', BoxFit.contain),
                      _buildFitExample('fill', BoxFit.fill),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildFitExample('fitWidth', BoxFit.fitWidth),
                      _buildFitExample('fitHeight', BoxFit.fitHeight),
                      _buildFitExample('none', BoxFit.none),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildSection(
              title: '自定义占位图背景色',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BaseImage(
                    imageUrl: 'https://httpstat.us/200?sleep=2000',
                    width: 100,
                    height: 100,
                    borderRadius: 8,
                    placeholderColor: Colors.blue[50],
                  ),
                  BaseImage(
                    imageUrl: 'https://httpstat.us/200?sleep=2000',
                    width: 100,
                    height: 100,
                    borderRadius: 8,
                    placeholderColor: Colors.green[50],
                  ),
                  BaseImage(
                    imageUrl: 'https://httpstat.us/200?sleep=2000',
                    width: 100,
                    height: 100,
                    borderRadius: 8,
                    placeholderColor: Colors.orange[50],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildSection(
              title: '禁用淡入动画',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      BaseImage(
                        imageUrl: 'https://picsum.photos/400',
                        width: 150,
                        height: 100,
                        borderRadius: 8,
                        enableFadeIn: true,
                      ),
                      const SizedBox(height: 5),
                      const Text('动画开启', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  Column(
                    children: [
                      BaseImage(
                        imageUrl: 'https://picsum.photos/401',
                        width: 150,
                        height: 100,
                        borderRadius: 8,
                        enableFadeIn: false,
                      ),
                      const SizedBox(height: 5),
                      const Text('动画关闭', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildSection(
              title: '错误处理 - 加载失败',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      BaseImage(
                        imageUrl: 'https://invalid-url.com/image.jpg',
                        width: 100,
                        height: 100,
                        borderRadius: 8,
                      ),
                      const SizedBox(height: 5),
                      const Text('默认错误图', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  Column(
                    children: [
                      BaseImage(
                        imageUrl: 'https://invalid-url.com/image.jpg',
                        width: 100,
                        height: 100,
                        borderRadius: 8,
                        errorWidget: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, color: Colors.red[300]),
                              const SizedBox(height: 4),
                              Text(
                                '自定义',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red[300],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text('自定义错误图', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  Column(
                    children: [
                      BaseImage(
                        imageUrl: 'invalid_local_path.png',
                        width: 100,
                        height: 100,
                        borderRadius: 8,
                      ),
                      const SizedBox(height: 5),
                      const Text('本地图片错误', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildSection(
              title: '自定义占位图',
              child: BaseImage(
                imageUrl: 'https://httpstat.us/200?sleep=3000',
                width: double.infinity,
                height: 150,
                borderRadius: 12,
                placeholder: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple[100]!, Colors.blue[100]!],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_download, size: 40, color: Colors.white),
                        SizedBox(height: 8),
                        Text(
                          '正在加载中...',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }

  Widget _buildFitExample(String label, BoxFit fit) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: BaseImage(
            imageUrl: 'https://picsum.photos/300/400',
            width: 100,
            height: 100,
            fit: fit,
            borderRadius: 8,
          ),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
