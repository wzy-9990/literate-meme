# DeveloperOptions 开发者选项组件

提供连续点击进入开发者选项的功能，支持修改 API 地址和配置抓包代理。**生产环境自动禁用所有开发者功能。**

## ✨ 特性

- ✅ 连续点击 7 次进入开发者选项（2秒内有效）
- ✅ 修改 API 地址（测试/生产环境切换）
- ✅ 配置抓包代理（Charles、Fiddler、Proxyman 等）
- ✅ **生产环境自动禁用**（不显示入口、不允许配置代理）
- ✅ 支持恢复默认配置
- ✅ 配置后自动退出登录并重启应用

## 🔒 安全机制

### 环境检测

```dart
// 通过编译时常量检测环境
const env = String.fromEnvironment('ENV', defaultValue: 'development');

// 生产环境判断
static bool get isProduction => env == 'production';
```

### 生产环境限制

1. **开发者选项入口禁用**
   - 点击版本号不会触发计数
   - 不会显示"再点击 X 次"提示
   - 无法进入开发者选项弹窗

2. **代理功能禁用**
   - 即使 Storage 中有代理配置也不会生效
   - ApiService.init() 中会跳过代理配置读取
   - 日志显示：`🔒 生产环境：代理功能已禁用`

## 🚀 使用方式

### 1. 基础集成

```dart
import 'package:flutter_tem/components/DeveloperOptions/index.dart';

class MySettingLogic extends GetxController {
  // 创建开发者选项实例
  final developerOptions = DeveloperOptions();

  /// 处理版本号点击
  void onVersionTap() {
    developerOptions.onTap();
  }
}
```

### 2. View 层使用

```dart
// 在设置页面添加可点击区域
GestureDetector(
  onTap: logic.onVersionTap,
  child: Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 12,
    ),
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.info_outline, size: 18),
        const SizedBox(width: 8),
        Text('版本号 v1.0.0'),
      ],
    ),
  ),
)
```

## 🛠 功能说明

### 1. 修改 API 地址

**使用场景：**
- 开发/测试/生产环境切换
- 临时切换到本地服务器
- 连接不同地区的服务器

**配置示例：**
```
生产环境: https://api.prod.com
测试环境: https://api.test.com
开发环境: https://api.dev.com
本地环境: http://192.168.1.100:8080
```

**存储位置：**
```dart
await Storage.setString('custom_api_url', apiUrl);
```

### 2. 抓包代理配置

**使用场景：**
- 使用 Charles 抓包调试网络请求
- 使用 Fiddler 抓包分析接口
- 使用 Proxyman 查看 API 数据

**常用代理工具端口：**
- Charles: 8888
- Fiddler: 8888
- Proxyman: 9090
- Whistle: 8899

**配置示例：**
```
启用代理: ✅
代理地址: 192.168.1.100
代理端口: 8888
```

**存储位置：**
```dart
await Storage.setBool('proxy_enabled', true);
await Storage.setString('proxy_host', '192.168.1.100');
await Storage.setInt('proxy_port', 8888);
```

**代理实现原理：**
```dart
// 在 ApiService 中配置代理
(_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
  final client = HttpClient();
  client.findProxy = (uri) => 'PROXY $_proxyHost:$_proxyPort';
  // 抓包时忽略证书验证
  client.badCertificateCallback = (cert, host, port) => true;
  return client;
};
```

## 📋 配置流程

### 用户操作流程

1. 进入**设置页面**
2. 找到**版本号区域**
3. **连续快速点击 7 次**（2秒内）
4. 弹出开发者选项弹窗
5. 修改配置
6. 点击"应用配置"
7. 自动退出登录并重启应用

### 系统处理流程

```
点击版本号
  ↓
检查是否生产环境 → 是 → 直接返回（不处理）
  ↓ 否
计数器 +1
  ↓
检查时间间隔 → 超过2秒 → 重置计数器
  ↓ 否
显示剩余次数提示
  ↓
达到 7 次？ → 是 → 显示开发者选项弹窗
  ↓ 否
等待下次点击
```

### 配置应用流程

```
点击"应用配置"
  ↓
验证输入（API地址、代理配置）
  ↓
保存到 Storage
  ↓
显示提示："配置已保存，正在退出登录..."
  ↓
延迟 1 秒
  ↓
清除 token 和 userInfo
  ↓
跳转到 Guide 页面
  ↓
Guide 页面调用 Global.init()
  ↓
ApiService.init() 读取新配置
  ↓
使用新配置创建 Dio 实例
```

## 🎨 UI 界面

### 弹窗界面组成

```
┌─────────────────────────────────────┐
│ 开发者选项          [DEVELOPMENT]   │ ← 显示当前环境
├─────────────────────────────────────┤
│ 1. 修改 API 地址                    │
│ 修改后将退出登录，下次请求将使用新地址│
│                                     │
│ ┌─────────────────────────────────┐│
│ │ 🔗 https://api.example.com      ││ ← API 地址输入框
│ └─────────────────────────────────┘│
│ 当前地址：https://test.ledug.cn/v2  │
│                                     │
│ ─────────────────────────────────  │
│                                     │
│ 2. 抓包代理配置                     │
│ 配置抓包代理后，所有请求将通过代理发送│
│                                     │
│ ☑ 启用代理                          │ ← 代理开关
│                                     │
│ ┌─────────────────────────────────┐│
│ │ 🌐 192.168.1.100                ││ ← 代理地址
│ └─────────────────────────────────┘│
│                                     │
│ ┌─────────────────────────────────┐│
│ │ 🔢 8888                         ││ ← 代理端口
│ └─────────────────────────────────┘│
│                                     │
│ 提示：常用抓包工具端口 Charles(8888)│
├─────────────────────────────────────┤
│  [取消]  [恢复默认]  [应用配置]     │
└─────────────────────────────────────┘
```

## 🔧 技术实现

### ApiService 初始化

```dart
// lib/api/http.dart
class ApiService {
  static Future<void> init() async {
    // 读取自定义 API 地址
    _customBaseUrl = await Storage.getString('custom_api_url');

    // 仅非生产环境读取代理配置
    const env = String.fromEnvironment('ENV');
    if (env != 'production') {
      _proxyEnabled = await Storage.getBool('proxy_enabled') ?? false;
      if (_proxyEnabled) {
        _proxyHost = await Storage.getString('proxy_host');
        _proxyPort = await Storage.getInt('proxy_port');
      }
    }
  }
}
```

### Global 初始化

```dart
// lib/services/index.dart
class Global {
  static Future<void> init() async {
    // 先初始化 API 配置
    await ApiService.init();

    // 其他服务初始化...
  }
}
```

## 📝 环境构建命令

### 开发环境（默认）

```bash
flutter run
# 或
flutter run --dart-define=ENV=development
```

### 测试环境

```bash
flutter run --dart-define=ENV=test
```

### 生产环境

```bash
flutter run --dart-define=ENV=production
# 或打包
flutter build apk --dart-define=ENV=production
flutter build ios --dart-define=ENV=production
```

## ⚠️ 注意事项

1. **生产环境限制**
   - 生产环境编译后，开发者选项完全不可用
   - 即使有 Storage 配置也不会生效
   - 确保发布前使用 `--dart-define=ENV=production`

2. **代理配置**
   - 代理仅用于调试，不要在生产环境使用
   - 启用代理时会忽略 HTTPS 证书验证
   - 确保代理工具（如 Charles）已正确配置

3. **配置持久化**
   - 所有配置保存在本地 Storage
   - 清除应用数据会重置所有配置
   - "恢复默认"会清除所有自定义配置

4. **重启应用**
   - 修改配置后会自动退出登录
   - 跳转到 Guide 页面重新初始化
   - 新配置在重启后生效

## 🐛 调试日志

```dart
// API 初始化日志
🌐 API Base URL: https://api.test.com
🔧 检测到自定义 API 地址: https://api.test.com
🔧 检测到代理配置: 192.168.1.100:8888
✅ 代理已启用: 192.168.1.100:8888

// 生产环境日志
🌐 API Base URL: https://api.prod.com
🔒 生产环境：代理功能已禁用
```

## 💡 最佳实践

1. **开发阶段**：使用开发环境，可自由切换 API 和配置代理
2. **测试阶段**：使用测试环境，连接测试服务器
3. **发布前**：确保使用生产环境编译，禁用所有调试功能
4. **抓包调试**：配置代理后，使用 Charles/Fiddler 查看网络请求
