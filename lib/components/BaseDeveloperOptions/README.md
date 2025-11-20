# BaseDeveloperOptions 开发者选项组件

一个通用的开发者选项组件，提供便捷的配置修改功能。

## 功能特性

- ✅ 连续点击进入开发者选项（7次点击）
- ✅ API 地址动态修改
- ✅ 抓包代理配置
- ✅ 生产环境自动禁用
- ✅ 配置保存与恢复

## 使用方法

### 基础用法

```dart
import 'package:flutter/material.dart';
import 'package:flutter_tem/components/BaseDeveloperOptions/index.dart';

class MyAppBar extends StatelessWidget {
  final BaseDeveloperOptions developerOptions = BaseDeveloperOptions();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('应用标题'),
      actions: [
        // 版本号文本，用于触发开发者选项
        GestureDetector(
          onTap: () => developerOptions.onTap(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Text('v1.0.0'),
          ),
        ),
      ],
    );
  }
}
```

### 环境检测

```dart
// 检查当前是否为生产环境
if (BaseDeveloperOptions.isProduction) {
  // 生产环境不会触发开发者选项
  print('当前为生产环境');
}
```

## API 文档

### BaseDeveloperOptions

#### onTap()
处理点击事件（通常用于版本号文本上），实现连续点击进入开发者选项的功能。

- 在非生产环境：连续点击7次进入开发者选项
- 在生产环境：无任何效果

#### isProduction
静态属性，返回当前是否为生产环境。

## 功能说明

### API 地址修改
- 修改 API 地址后会自动退出登录
- 下次请求将使用新的 API 地址
- 支持完整 URL 格式（如：https://example.com/api）

### 抓包代理配置
- 支持启用/关闭代理
- 配置代理地址和端口
- 支持常见抓包工具：Charles(8888)、Fiddler(8888)、Proxyman(9090)
- 启用代理后，所有请求将通过指定代理发送

## 注意事项

1. **安全考虑**：生产环境（ENV=production）会自动禁用开发者选项
2. **配置生效**：修改配置后会重启应用以确保新配置生效
3. **权限要求**：无特殊权限要求
4. **存储**：配置信息保存在本地存储中，卸载应用后将清除

## 存储键值

- `customApiUrl`: 自定义 API 地址
- `proxyEnabled`: 代理启用状态
- `proxyHost`: 代理主机地址
- `proxyPort`: 代理端口

## 最佳实践

```dart
class MyVersionWidget extends StatelessWidget {
  final BaseDeveloperOptions _developerOptions = BaseDeveloperOptions();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _developerOptions.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          'v1.0.0',
          style: TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}
```